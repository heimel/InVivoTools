function cells = importintan(record, channels2analyze, verbose)
%IMPORTINTAN filters and detects spikes in intan-acquired data
%
%  CELLS = IMPORTTAN(RECORD,CHANNELS2ANALYZE,VERBOSE)
%
% 2016-2019, Mehran Ahmadlou, Alexander Heimel
%

if nargin<3 || isempty(verbose)
    verbose = true;
end
if nargin<2
    channels2analyze = [];
end

processparams = ecprocessparams(record);
datapath = experimentpath(record,false);
EVENT.Mytank = datapath;
EVENT.Myblock = record.test;
matfilename = fullfile(EVENT.Mytank,EVENT.Myblock,[EVENT.Myblock '.mat']);

if ~exist(matfilename,'file')
    EVENT = load_intan(EVENT);
    if isempty(EVENT)
        cells = [];
        return
    end
else
    logmsg(['Loading precomputed event file ' matfilename]);
    load(matfilename,'EVENT');
end
logmsg(['Loaded event file for ' recordfilter(record)]);

if isempty(channels2analyze)
    channels2analyze = EVENT.snips.Snip.channels;
end
EVENT.CHAN = channels2analyze;

if verbose && processparams.ec_show_spikedetection
    plot_data(EVENT.Snips.rawtime,EVENT.Snips.rawsig,EVENT,'Raw')
end

if ~isfield(EVENT,'strons')
    errormsg(['No triggers present in ' recordfilter(record)]);
    cells = [];
    return
end

if strncmp(record.analysis,'OFF',3)==1 && strncmp(record.stim_type,'bglumin',10)==1
    logmsg('Analyzing OFF response. Shifted time by 1.55 s');
    EVENT.strons.tril(1) = EVENT.strons.tril(1) + 1.55;
end

if processparams.ec_temporary_timeshift~=0 % to check gad2 cells
    errormsg(['Shifted time by ' num2str(processparams.ec_temporary_timeshift) ' s to check laser response']);
    EVENT.strons.tril(1) = EVENT.strons.tril(1) + processparams.ec_temporary_timeshift;
end

logmsg(['Analyzing channels: ' num2str(channels2analyze)]);

%% Rereferencing


switch processparams.ec_rereference
    case 'subtract_average_channel'
        logmsg('Subtracting common signal from all channels (params.ec_rereference = ''subtract_average_channel''');
        commonsignal = mean(EVENT.Snips.rawsig,1);
        for i=1:size(EVENT.Snips.rawsig,1)
            EVENT.Snips.rawsig(i,:) = EVENT.Snips.rawsig(i,:) - commonsignal;
        end
    case {'remove_first_pc','remove_first_two_pcs'}
        logmsg(['Removing first principal component as rerefercing (params.ec_rereference = ''' processparams.ec_rereference '''']);
        n= 100000;
        ind = 1:n;
        
        [coeff,score]= pca(EVENT.Snips.rawsig(:,ind)');
%         plot_data(EVENT.Snips.rawtime,EVENT.Snips.rawsig,EVENT,'Rereferenced')
        pca1 = coeff(1,:)*EVENT.Snips.rawsig(:,1:n);
        pca2 = coeff(2,:)*EVENT.Snips.rawsig(:,1:n);
%         subplot(1,2,1);
%         hold on;
%         plot(EVENT.Snips.rawtime(1:n),-pca1);
%         plot(EVENT.Snips.rawtime(1:n),pca2);

        score2 = (EVENT.Snips.rawsig' * coeff);
        switch processparams.ec_rereference
            case 'remove_first_two_pcs'
                score2(:,3:end) = 0; % remove everything except first two PCs
            otherwise
                score2(:,2:end) = 0; % remove everything except first  PCs
        end
        
        pcas = coeff * score2';
        EVENT.Snips.rawsig = EVENT.Snips.rawsig - pcas;
    otherwise
        logmsg('Not rereferencing');
end


if verbose && processparams.ec_show_spikedetection
    plot_data(EVENT.Snips.rawtime,EVENT.Snips.rawsig,EVENT,'Rereferenced')
end




%% Filtering
% 50 Hz Notch filter
filtsig = zeros(length(channels2analyze),size(EVENT.Snips.rawsig,2));
if processparams.ec_apply_notchfilter
    logmsg('50 Hz notch filter');
    d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',49,'HalfPowerFrequency2',51, ...
               'DesignMethod','butter','SampleRate',EVENT.Freq);
           
    for j = 1:length(channels2analyze) % to avoid prealloc
        filtsig(j,:) = filtfilt(d,EVENT.Snips.rawsig(channels2analyze(j),:));
    end
else
    filtsig = EVENT.Snips.rawsig(channels2analyze,:);
end

logmsg('High pass filtering from 300 Hz');
% signal is already lowpass filtered by intan
if ~isempty(record.filter)
    highpass = record.filter(1);
end
[b,a] = butter(5,highpass/(0.5*EVENT.Freq),'High');
for j = length(channels2analyze):-1:1 % to avoid prealloc
    filtsig(j,:) = filter(b,a,filtsig(j,:));
end

%% adjust time to stimulus 
stimsfile = getstimsfile( record );
if isempty(stimsfile)
    errormsg(['No stimsfile for record ' recordfilter(record) '. Use ''stiminterview(global_record)'' to generate stimsfile. Now no analysis']);
    intervals = [EVENT.Snips.rawtime(1) EVENT.Snips.rawtime(end)]; % arbitrary, no link to real stimulus
elseif isempty(stimsfile.MTI2{end}.frameTimes)
    intervals = [stimsfile.start stimsfile.start+60*60]; % use one hour
else
    intervals = [stimsfile.start stimsfile.MTI2{end}.frameTimes(end)+10]; % end of stim + 10s
end

if isempty(EVENT.strons.tril)
    errormsg(['Missing trigger in ' recordfilter(record)]);
    cells = {};
    return
end
tril = use_right_trigger(record,EVENT)* processparams.secondsmultiplier;
timeshift = intervals(1) - tril;
timeshift = timeshift + processparams.trial_ttl_delay;
time = EVENT.Snips.rawtime * processparams.secondsmultiplier + timeshift;


%% Spike detection
%clear('spikedata');
spikedata = struct('time',[],'data',[]);

HalfW = 16; % samples in downsampled data
WinWidth = 2*HalfW;
common_threshold = processparams.ec_intan_spikethreshold; % threshold of spike detection

logmsg(['Detecting spikes on channels ' mat2str(channels2analyze)]);

if ~isempty(record.channels)
    manual_thresholds = record.channels;
else
    manual_thresholds = [NaN NaN];
end

for j = 1:length(channels2analyze)
    ind = find(manual_thresholds(:,1)==channels2analyze(j));
    if ~isempty(ind)
        threshold = manual_thresholds(ind,2);
    else
        threshold = common_threshold;
    end
    
    if abs(threshold)<10 % assume stds
        chanthreshold = std(filtsig(j,1:100000))*threshold;
    else
        chanthreshold = threshold;
    end
    
    if chanthreshold<0
        [~,locs] = findpeaks_fast(-filtsig(j,:)','minpeakheight',abs(chanthreshold),'minpeakdistance',HalfW);
    else
        [~,locs] = findpeaks_fast(filtsig(j,:)','minpeakheight',abs(chanthreshold),'minpeakdistance',HalfW);
    end
    if ~isempty(locs) && locs(1)<HalfW
        locs(1) = [];
    end
    if ~isempty(locs) && locs(end)>size(filtsig,2)-HalfW
        locs(end) = [];
    end
    if ~isempty(locs)
        ind = repmat(locs,1,WinWidth) + repmat(1-HalfW:HalfW,length(locs),1);
    else
        ind = [];
    end
    x = filtsig(j,:);
    spikedata(j).data = x(ind);
    spikedata(j).time = time(locs);
    spikedata(j).channel = channels2analyze(j);
    spikedata(j).threshold = chanthreshold;
    logmsg(['Detected ' num2str(length(locs)) ]);
end

if verbose && processparams.ec_show_spikedetection
    plot_spike_data(time,filtsig,spikedata,record,intervals(1))
end

cells = struct([]);
cll.name = '';
cll.intervals = intervals;
cll.sample_interval = 1/EVENT.Freq;
cll.detector_params = [];
cll.trial = record.test;
cll.desc_long = fullfile(datapath,record.test);
cll.desc_brief = record.test;
channels_new_index = (0:1000)*10+1; % works for up to 1000 channels, and max 10 cells per channel
for c = 1:length(spikedata)
    if isempty(spikedata(c).data) %only include channels with spikes
        logmsg(['No spikes on channel ' num2str(spikedata(c).channel)]);
        continue
    end
    cll.channel = spikedata(c).channel;
    cll.index = channels_new_index(cll.channel); % used to identify cell
    channels_new_index(cll.channel) = channels_new_index(cll.channel) + 1;
    cll.name = sprintf('cell_%s_%.3d',...
        subst_specialchars(record.test),cll.index);
    cll.data = spikedata(c).time';
    spikes = spikedata(c).data; % spikes x samples
    cll.wave = mean(spikes,1);
    cll.std = std(spikes,1);
    cll.spikes = spikes;
    cll.ind_spike = [];
    cells = [cells,cll]; %#ok<AGROW>
end




function  tril = use_right_trigger(record,EVENT)
usetril=regexp(record.comment,'usetril=(\s*\d+)','tokens');
if ~isempty(usetril)
    usetril = str2double(usetril{1}{1});
else
    usetril = -1; % i.e. last
end

if usetril == -1
    if (isfield(EVENT.strons,'OpOn')==0 && length(EVENT.strons.tril)>1) || ...
            (isfield(EVENT.strons,'OpOn')==1 && (length(EVENT.strons.tril)-length(EVENT.strons.OpOn))>1)
        errormsg(['More than one trigger in ' recordfilter(record) '. Taking last. Set usetril=XX in comment to overrule']);
        logmsg(['Triggers at ' mat2str(EVENT.strons.tril)]);
    end
end

if isfield(EVENT.strons,'OpOn')
    n_optotrigs = length(EVENT.strons.OpOn);
else
    n_optotrigs = 0;
end

if usetril == -1 % use last
    if length(EVENT.strons.tril)>(n_optotrigs+1)
        tril = EVENT.strons.tril(end-n_optotrigs);
    else
        tril = EVENT.strons.tril(1);
    end
    if (isfield(EVENT.strons,'OpOn')==1 && (length(EVENT.strons.OpOn))<12)
        EVENT.strons.tril(1) = EVENT.strons.tril(end);
    end
else
    if usetril > length(EVENT.strons.tril)
        errormsg(['Only ' num2str(length(EVENT.strons.tril)) ' triggers available. Check ''tril='' in comment field.']);
        tril = EVENT.strons.tril(end);
        return
    end
    tril = EVENT.strons.tril(usetril);
end




function plot_spike_data(time,filtsig,spikedata,record,stimstart)
figure('Name','Spikes','Numbertitle','off');
n_channels = length(spikedata);
for j = 1:n_channels
    % Example filtered data
    if ~isempty(spikedata(j).time) % some spikes
        example_spiketime = spikedata(j).time(ceil(end/2));
    else
        example_spiketime = time(ceil(end/2));
    end
    width = 5; % s
    ind1 = find(time(:)>example_spiketime-width,1,'first');
    ind2 = find(time(:)<example_spiketime+width,1,'last');
    subplot(n_channels,3,1+(j-1)*3)
    hold on
    plot(time(ind1:ind2)-stimstart,filtsig(j,ind1:ind2));
    plot(time([ind1 ind2])-stimstart,[1 1]*spikedata(j).threshold,'color',0.7*[1 1 1]);
    ind = find(spikedata(j).time>time(ind1) & ...
        spikedata(j).time<time(ind2));
    if ~isempty(ind)
        plot(spikedata(j).time(ind)-stimstart,spikedata(j).data(ind,ceil(end/2)),'o');
    end
    if j == n_channels
        xlabel('Time (s)');
    end
    ylabel(num2str(spikedata(j).channel));
    xlim(time([ind1 ind2])-stimstart);
    
    % Example spike zoom
    subplot(n_channels,3,2+(j-1)*3)
    width = 0.010; % s
    ind1 = find(time > example_spiketime-width,1,'first');
    ind2 = find(time < example_spiketime+width,1,'last');
    plot(time(ind1:ind2)-stimstart,filtsig(j,ind1:ind2));
    hold on
    plot(time([ind1 ind2])-stimstart,[1 1]*spikedata(j).threshold,'color',0.7*[1 1 1]);
    if j == n_channels
        xlabel('Time (s)');
    end
    xlim(time([ind1 ind2])-stimstart);
    
    % Relative spike rate during trial
    if length(spikedata(j).time)>1
        subplot(n_channels,3,3+(j-1)*3);
        hold off
        isi = diff(spikedata(j).time);
        t = (spikedata(j).time(1:end-1)+spikedata(j).time(2:end))/2 - stimstart;
        if length(isi)>1
            [isi,t] = slidingwindowfunc(t, isi, [], 0.2, [], 4,'mean',0);
        end
        plot(t,1./isi);
        hold on
        set(gca,'yscale','log');
        plot_stimulus_timeline(record);
        hold on
        ylabel('Rate (Hz)');
        % h = plot_stimulus_timeline(record,xlims,variable,show_icons,stepped)
        xlim([t(1)-0.5 t(end)+0.5]);
        ylim([min(1./isi) max(1.05 ./isi)]);
    end
    if j == n_channels
        xlabel('Time (s)');
    end
end


function plot_data(rawtime,sig,EVENT,label)
figure('Name',label,'Numbertitle','off');
subplot(1,2,1);
hold on;
for i = setdiff(EVENT.snips.Snip.channels,EVENT.CHAN)
    plot(rawtime(1,1:100000),sig(i,1:100000),'color',0.7*[1 1 1]);
end
for i = EVENT.CHAN
    plot(rawtime(1,1:100000),sig(i,1:100000));
end
xlabel('Time (s)');
ylabel('Voltage (?)');

subplot(1,2,2);
hold on;
ind1 = round(EVENT.Freq * 1); % from 1s
ind2 = round(EVENT.Freq * 1.2); % to 1.2s
for i = setdiff(EVENT.snips.Snip.channels,EVENT.CHAN)
    plot(rawtime(1,ind1:ind2),sig(i,ind1:ind2),'color',0.7*[1 1 1]);
end
for i = EVENT.CHAN
    plot(rawtime(1,ind1:ind2),sig(i,ind1:ind2));
end
xlabel('Time (s)');
ylabel('Voltage (?)');

