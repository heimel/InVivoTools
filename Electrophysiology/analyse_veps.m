function record = analyse_veps(record,verbose)
%ANALYSE_VEPS analyses lfp record for power spectra
%
%  record = analyse_veps(record,verbose)
%
%      VERBOSE if 0 no graphical output at all, if 1 progress bar, if 2
%         many figures
%
% 2012-2015, Alexander Heimel, Mehran Ahmadlou
%

if nargin<2
    verbose = [];
end
if isempty(verbose)
    verbose = 1;
end

measures = [];
meanwaves = {};
powers = {};
powerm = [];

bands = oscillation_bands;
band_names = fields(oscillation_bands);

[stims,stimsfile] = getstimsfile(record);
if isempty(stims)
    if ~exist(stimsfile,'file')
        errormsg(['Cannot find stims file ' stimsfile]);
    else
        errormsg(['Empty stims file ' stimsfile]);
    end
    return
end


switch strtrim(record.analysis)
    case ''
        % just run default analysis
    case 'CSO'
        analyse_CSO(record,stimsfile,50,verbose); % contact point distance for SC 50, for VC 100
        results_lfptestrecord( record );
        return
    case 'coherence'
        analyse_wavecoh(record,stimsfile); % contact point distance for SC 50, for VC 100
        return
    case 'wspectrum'
        analyse_waveletlfp(record,stimsfile); % contact point distance for SC 50, for VC 100
        return
    case  'wtcrosscorr'
        analyse_wavecrosscorr(record,stimsfile,60,90,5,8)
        return
    otherwise
        errormsg(['Analysis ' record.analysis ' is not implemented.']);
        return
end

switch record.stim_type
    case 'sg'
        logmsg('LFP analysis of sg is not implemented.');
        record.measures = [];
        return
end

process_params = ecprocessparams(record);

[recorded_channels,area] = get_recorded_channels( record );
channels2analyze = get_channels2analyze( record );
if isempty(channels2analyze)
    channels2analyze = recorded_channels;
end

% note, taking all times from stims.mat because the number of samples
% should be equal
max_duration = 0;
max_pretime = 0;
max_posttime = 0;
for i=1:length(stims.MTI2)
    pretime = stims.MTI2{i}.startStopTimes(2)-stims.MTI2{i}.startStopTimes(1);
    if pretime>max_pretime
        max_pretime = pretime;
    end
    duration = stims.MTI2{i}.startStopTimes(3)-stims.MTI2{i}.startStopTimes(2);
    if duration>max_duration
        max_duration = duration;
    end
    posttime = stims.MTI2{i}.startStopTimes(4)-stims.MTI2{i}.startStopTimes(3);
    if posttime>max_posttime
        max_posttime = posttime;
    end
end

% first stimulus to get dimensions
stimulus_start = (stims.MTI2{1}.startStopTimes(2)-stims.start);
pre_ttl = max_pretime-stimulus_start;
post_ttl = stimulus_start+max_duration+max_posttime;

% loading first only to get n_samples and sampletime
switch lower(record.setup)
    case 'antigua'
        clear EVENT
        EVENT.Mytank = experimentpath(record,false);
        EVENT.Myblock = record.test;
        EVENT = load_tdt(EVENT);

        numchannel = max([EVENT.strms.channels]);
        if any(channels2analyze>EVENT.snips.Snip.channels)
            errormsg(['Did not record more than ' num2str(numchannel) ' channels.']);
            return
        end
        
        if isempty(channels2analyze)
            channels2analyze = 1:numchannel;
        end
        logmsg(['Analyzing channels: ' num2str(channels2analyze)]);
        
        EVENT.Myevent = 'LFPs';
        EVENT.Start =  -max_pretime;
        EVENT.Triallngth =  post_ttl+pre_ttl;
        EVENT.CHAN = channels2analyze(1);

        sample_interval = 1/EVENT.strms(1,3).sampf;
        EVENT.strons.tril(1) = use_right_trigger(record,EVENT);
        
        if process_params.ec_temporary_timeshift~=0 % to check gad2 cells
            errormsg(['Shifted time by ' num2str(process_params.ec_temporary_timeshift) ' s to check laser response']);
            EVENT.strons.tril(1) = EVENT.strons.tril(1) + processparams.ec_temporary_timeshift;
        end
        
%         EVENT.strons.tril(1) = EVENT.strons.tril(3);
        startindTDT = EVENT.strons.tril(1)-pre_ttl;
        SIG = signalsTDT(EVENT,stimulus_start+startindTDT);
        n_samples = length(SIG{1,1});
    otherwise % CED spike2
        if isempty(channels2analyze)
            channels2analyze = 1;
        end
        smrfile=fullfile(experimentpath(record),'data.smr');
        results = importspike2_lfp(smrfile,record.stim_type,pre_ttl,post_ttl,true,record.amplification,verbose);
        n_samples = length(results.waves{1,channels2analyze(1)});
        sample_interval = results.sample_interval;
end

if isempty(n_samples) || n_samples==0
    logmsg('No data present');
    return
end
Fs = 1/sample_interval; % Hz sample frequency

analyse_params = varied_parameters( stims.saveScript);
if isempty(analyse_params)
    logmsg('No parameter varied');
    if isempty(record.stim_type)
        analyse_params = {'imageType'};
    else
        analyse_params = {record.stim_type};
    end
end

if isempty(record.stim_type)
    ind = [];
else
    ind = strmatch(record.stim_type,analyse_params);  
end
if isempty(ind)
    measures.variable = analyse_params{1};
else
    measures.variable = analyse_params{ind};
end
pars = getparameters(stims.saveScript);
parameter_values = pars.(measures.variable);
n_conditions = length(parameter_values);

logmsg(['Analyzing ' measures.variable  ', with ' record.stim_parameters ' averaging over other parameters.']);

% split by trigger
trigger = getTrigger(stims.saveScript);
if any(diff(trigger)) % i.e. more than one type of trigger
    stimss = split_stimscript_by_trigger( stims );
else
    stimss= stims;
end

% loading lfp data
if verbose
    h_wait = waitbar(0,'Loading LFPs...');
end

for ch = 1:length(channels2analyze)    
    measures(ch).depth = record.depth-record.surface; %#ok<*AGROW>
    measures(ch).channel = channels2analyze(ch);
    if ~isempty(area)
        for a=1:length(area)
            if ismember(measures(ch).channel,area(a).channels)
                measures(ch).area = area(a).name;
                measures(ch).relative_channel =  measures(ch).channel - min(area(a).channels) + 1;
            end
        end
    end
    
    for t = 1:length(stimss) % run over triggers
        stims = stimss(t);
        n_stims = length(stims.MTI2);
        
        measures(ch).range{1,t} = parameter_values;
        
        waves = zeros(n_stims,n_samples);
        waves_time = zeros(n_stims,n_samples);
        
        for i=1:length(stims.MTI2)
            if verbose
                waitbar( (i-1)/length(stims.MTI2));
            end
            stimulus_start = (stims.MTI2{i}.startStopTimes(2)-stims.start);
            if all(stims.MTI2{i}.startStopTimes==0)
                errormsg('Corrupt stims.mat file or not all stimuli shown?');
                return
            end
            
            pre_ttl = max_pretime-stimulus_start;
            post_ttl = stimulus_start+max_duration+max_posttime;
            
            switch lower(record.setup)
                case 'antigua'
                    EVENT.Start = -max_pretime;
                    EVENT.Triallngth =  post_ttl+pre_ttl;
                    EVENT.CHAN = channels2analyze(ch);
                    SIG = signalsTDT(EVENT,stimulus_start+startindTDT);
                    if size(SIG{1,1},1)<n_samples
                        SIG{1,1}(end+1:n_samples) = SIG{1,1}(end);
                    elseif size(SIG{1,1},1)>n_samples
                        SIG{1,1}(n_samples+1:end) = [];
                    end
                    waves(i,:) = SIG{1,1} * record.amplification;
                    waves_time(i,:) = -pre_ttl+(0:n_samples-1)*sample_interval  - stimulus_start;
                otherwise
                    if ch>1
                        errormsg('Spike2 import only works for 1 channel');
                        return
                    end
                    results = importspike2_lfp(smrfile,record.stim_type,...
                        pre_ttl,post_ttl,true,record.amplification,verbose);
                    waves(i,:) = results.waves{1,1};
                    waves_time(i,:) = results.waves_time{1,1} - stimulus_start;
            end
        end % stim i
        %read all stimulus data
        
        % Computing spectra, Pooling repetitions
        do = getDisplayOrder(stims.saveScript);
        stims = get(stims.saveScript);
        stim_pars = cellfun(@getparameters,stims);
        if verbose
            waitbar( 0,'Computing spectra');
        end
        for i = 1:n_conditions
            % select stimuli matching condition
            crit = [measures.variable '=' num2str(parameter_values(i))];
            if ~isempty(record.stim_parameters)
                crit = [crit ',' record.stim_parameters]; 
            end
            ind_matching = find_record( stim_pars,crit);
            ind = [];
            for j=ind_matching
                ind = [ind find(do==j)];
            end
            
            onsettime = -mean(waves_time(ind,1));
            if std(waves_time(ind,1))>0.001 % i.e. jitter in onser
                logmsg('Jitter in onset times larger than 1 ms.');
            end
            
            waves_mean(i,:) = mean(waves(ind,:),1);
            
            if process_params.entropy_analysis
                measures(ch) = entropy_analysis( waves, waves_time, Fs, ind, measures(ch), i);
            end
            
            data = reshape(waves(ind,:)',size(waves,2),1,length(ind));
            
            if strcmp(process_params.vep_remove_line_noise,'temporal_domain')
                data = remove_line_noise(data,Fs);
            end
            if process_params.vep_remove_vep_mean
                data = remove_vep_mean( data );
            end
            [powerm.power(:,:,i),powerm.freqs,powerm.time] = get_power(data,Fs,onsettime,process_params,verbose);
            
            if verbose
                waitbar(i/length(parameter_values));
            end
        end % condition i
        
        
        % set pre and postwindows
        pre_ind = (powerm.time>process_params.pre_window(1) & ...
            powerm.time<=process_params.pre_window(2) & ...
            powerm.time>(powerm.time(1)+process_params.separation_from_prev_stim_off)  );
        post_ind = (powerm.time>process_params.post_window(1) & ...
            powerm.time<process_params.post_window(2));
        
        % Integrate power        
        powerm.power_post = mean(powerm.power(:,post_ind,:),2); % freqs x channels x conditions
        powerm.power_pre = mean(powerm.power(:,pre_ind,:),2); % freqs x channels x conditions
        powerm.postdivpre = powerm.power_post ./ powerm.power_pre;
        powerm.decpostdivpre = 10*log10(powerm.postdivpre);
        powerm.power_evoked = powerm.postdivpre-1;
        
        for f = 1:length(band_names)
            band = band_names{f};
            ind_band = find(powerm.freqs>bands.(band)(1) & powerm.freqs<bands.(band)(2));
            measures(ch).([band '_power_pre']){1,t} = mean( powerm.power_pre(ind_band,:,:),1);
            measures(ch).([band '_power_post']){1,t} = mean( powerm.power_post(ind_band,:,:),1);
            
            for c = 1:n_conditions
                [measures(ch).([band '_peak_freq_pre']){1,t}(c), ...
                    measures(ch).([band '_peak_power_pre']){1,t}(c) ] = ...
                    extract_peak(powerm.freqs(ind_band),powerm.power_pre(ind_band,:,c)');
                [measures(ch).([band '_peak_freq_post']){1,t}(c), ...
                    measures(ch).([band '_peak_power_post']){1,t}(c)] = ...
                    extract_peak(powerm.freqs(ind_band),powerm.power_post(ind_band,:,c)');
            end
            
            measures(ch).([band '_evoked_power']){1,t} = mean( powerm.power_evoked(ind_band,:,:),1);
            
            for c = 1:n_conditions
                [measures(ch).([band '_evoked_peak_power']){1,t}(c),ind_m] = max(powerm.power_evoked(ind_band,1,c));
                measures(ch).([band '_evoked_peak_freq']){1,t}(c) = powerm.freqs(ind_band(ind_m));
            end
        end % bands f
        
        % store mean wave
        waves_time = mean(waves_time,1);
        meanwaves{ch}{t} = waves_mean;
        powers{ch}{t} = powerm;
    end % t trigger
    
    if length(stimss)>1 % i.e. multiple triggers
        for i = 1:n_conditions
            for t1 = 1:length(stimss)
                for t2 = (t1+1):length(stimss)
                    for f = 1:length(band_names)
                        band = band_names{f};
                        measures(ch).([band '_evoked_power_trig' num2str(t2) 'to' num2str(t1) ])(:,i) = ...
                            measures(ch).([band '_evoked_power']){1,t2}(:,i) ./ ...
                            measures(ch).([band '_evoked_power']){1,t1}(:,i);
                        
                        measures(ch).([band '_evoked_peak_power_trig' num2str(t2) 'to' num2str(t1) ])(i) = ...
                            measures(ch).([band '_evoked_peak_power']){1,t2}(:,i) ./ ...
                            measures(ch).([band '_evoked_peak_power']){1,t1}(:,i);
                        
                        measures(ch).([band '_evoked_peak_freq_trig' num2str(t2) 'to' num2str(t1)])(i) = ...
                            measures(ch).([band '_evoked_peak_freq']){1,t2}(:,i) ./ ...
                            measures(ch).([band '_evoked_peak_freq']){1,t1}(:,i);
                    end % band f
                end % trigger t2
            end % trigger t1
        end % condition i
    end % if multiple triggers

end % channel ch

if verbose
    close(h_wait);
end

for ch=1:length(channels2analyze)
    waves = meanwaves{ch}; %#ok<NASGU>
    powerm = powers{ch}; %#ok<NASGU>
    wavefile = fullfile(experimentpath(record),['saved_data_veps_ch',num2str(channels2analyze(ch)),'.mat']);
    save(wavefile,'waves','waves_time','powerm');
end

for ch=1:length(channels2analyze)
    measures(ch).waves_time = waves_time;
    measures(ch).waves = meanwaves{ch};
    measures(ch).powerm = powers{ch};
end


% insert measures into record.measures
record.measures = merge_measures_from_disk(record); % to include omitted fields
if (length(channels2analyze)==length(recorded_channels) && all( sort(channels2analyze)==sort(recorded_channels)))...
        || ~isfield(measures,'channel')|| ~isfield(record.measures,'channel')
    record.measures = measures;
else
    try
        record.measures(ismember([record.measures.channel],channels2analyze)) = []; % remove old
        record.measures = [record.measures measures];
        [dummy,ind] = sort([record.measures.channel]); %#ok<ASGLU>
        record.measures = record.measures(ind);
    catch me % in case measures struct definition has changed
        logmsg(me.message);
        record.measures = measures;
    end
end

% save measures file
measuresfile = fullfile(experimentpath(record),[record.datatype '_measures.mat']);
measures = record.measures; %#ok<NASGU>
try
    save(measuresfile,'measures');
catch me
    errormsg(['Could not write measures file ' measuresfile '. ' me.message]);
end

% remove fields that take too much memory
record.measures = rmfields(record.measures,{'powerm','waves'});

record.analysed = datestr(now);




function [pxx,freqs,time] = get_power(waves,Fs,onsettime,params,verbose)
% Fs is sampling frequency
% waves is samples x channels=1 x trials
% pxx is (frequencies x samples x channels)
% freqs gives the vector of calculated frequencies in Hz
% t gives the vector of sample times

switch params.vep_poweranalysis_type
    case 'wavelet'
        [pxx,freqs,time] = GetPowerWavelet(waves,Fs,onsettime,verbose);
    case 'spectrogram'
        segmentwidth = 0.05;%0.2; % s
        window = ceil(segmentwidth *Fs);
        noverlap = ceil(window/4); %100;%[];
        nfft = 512;
        [s,freqs,time,pxx] = spectrogram(waves(:,:,1),window,noverlap,nfft,Fs); %#ok<ASGLU>
        for i=2:size(waves,3)
            [s,freqs,time,pxxt] = spectrogram(waves(:,:,i),window,noverlap,nfft,Fs); %#ok<ASGLU>
            pxx = pxx +  pxxt;
        end
        pxx = pxx/size(waves,3);
        freqs = freqs';
        time = time - onsettime;
    otherwise
        errormsg(['Power analysis ' params.vep_poweranalysis_type ' is not implemented. Should be ''wavelet'' or ''spectrogram'''],true);
end

function  data = remove_vep_mean( data )
data = data - repmat(mean(data,3),[1 1 size(data,3)]);

function [px,py] = extract_peak(x,y)
% subtract slope of y and the get max
ys = y - (x-x(1))*(y(end)-y(1))/(x(end)-x(1));
[alaki,f_ind] = max(ys); %#ok<ASGLU>
px = x(f_ind);
py = y(f_ind);

function [recorded_channels,area] = get_recorded_channels( record )
recorded_channels = [];
area = [];
if isfield(record,'channel_info') && ~isempty(record.channel_info)
    channel_info = split(record.channel_info);
    if length(channel_info)==1
        recorded_channels = sort(str2num(channel_info{1})); %#ok<ST2NM>
    else
        for i=1:2:length(channel_info)
            area( (i+1)/2 ).channels = sort(str2num(channel_info{i})); %#ok<ST2NM>
            area( (i+1)/2 ).name = lower(channel_info{i+1});
            if ~isempty(intersect(recorded_channels,area( (i+1)/2 ).channels))
                errormsg('There is a channel assigned to two areas');
                return
            end
            recorded_channels = [recorded_channels area( (i+1)/2 ).channels];
        end
        recorded_channels = sort( recorded_channels );
    end
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
    end
end

if isfield(EVENT.strons,'OpOn')
    n_optotrigs = length(EVENT.strons.OpOn);
else
    n_optotrigs = 0;
end

if usetril == -1 % use last
    tril = EVENT.strons.tril(max(1,end-n_optotrigs));
    if (isfield(EVENT.strons,'OpOn')==1 && (length(EVENT.strons.OpOn))<10)
            EVENT.strons.tril(1) = EVENT.strons.tril(end);
    end
else
    if usetril > length(EVENT.strons.tril)
        errormsg('Only 1 trigger available. Check ''tril='' in comment field.');
        tril = EVENT.strons.tril(end);
        return
    end
    tril = EVENT.strons.tril(usetril);
end


function  measures = entropy_analysis( waves, waves_time, Fs, ind, measures,i )
bands = oscillation_bands;
band_names = fields(oscillation_bands);

preind = (waves_time(1,:)<0);
postind = (waves_time(2,:)>=0);
for b = 1:length(band_names)
    band = band_names{b};
    switch band
        case 'delta'
            n = 5;
        case 'theta'
            n = 7;
        otherwise
            n = 9;
    end
    
    [a_low,b_low] = butter(n,bands.(band)(2)/(.5*Fs),'low'); % lowpass
    [a_high,b_high] = butter(n,bands.(band)(1)/(.5*Fs),'high'); % highpass
    for f=ind
        w = filter(a_low,b_low,waves(f,:));
        w = filter(a_high,b_high,w);
        Wpre = w(preind);
        Wpost = w(postind);
        
        Kfd{b}(f) = katz(Wpost)-katz(Wpre);
        WENT{b}(f) = wentropy(Wpost,'shannon')-wentropy(Wpre,'shannon');
        
        Dpre = DFA(Wpre);
        Dpost = DFA(Wpost);
        Dfa{b}(f) = Dpost(1)-Dpre(1); % so only first DFA is used
    end
    
    measures.([band '_KfdM']){t}(i) = mean(Kfd{b}(ind));
    measures.([band '_KfdS']){t}(i) = std(Kfd{b}(ind));
    
    measures.([band '_WENTM']){t}(i) = mean(WENT{b}(ind));
    measures.([band '_WENTS']){t}(i) = std(WENT{b}(ind));
    
    measures.([band '_DfaM']){t}(i) = mean(Dfa{b}(ind));
    measures.([band '_DfaS']){t}(i) = std(Dfa{b}(ind));
end % band b


