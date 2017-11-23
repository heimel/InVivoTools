function cells = importintan(record, channels2analyze)
%IMPORTINTAN
%
% 2016, Mehran Ahmadlou, Alexander Heimel
%

processparams = ecprocessparams(record);

datapath=experimentpath(record,false);

EVENT.Mytank = datapath;
EVENT.Myblock = record.test;
% IsFile = fullfile(EVENT.Mytank,EVENT.Myblock,EVENT.Myblock);
if 1
    EVENT = load_intan(EVENT);
else
    load(['D:\Data\InVivo\Electrophys\Intan\2016\04\12\Mouse\t-1\t-1.mat'])
end

if ~isfield(EVENT,'strons')
    errormsg(['No triggers present in ' recordfilter(record)]);
    cells = [];
    return
end

% EVENT.strons.tril(1) = use_right_trigger(record,EVENT);
% EVENT.strons.tril(1) =EVENT.strons(1,1);

if 0 && strncmp(record.stim_type,'background',10)==1
    EVENT.strons.tril(1) = EVENT.strons.tril(1) + 1.55;
end
if processparams.ec_temporary_timeshift~=0 % to check gad2 cells
    errormsg(['Shifted time by ' num2str(processparams.ec_temporary_timeshift) ' s to check laser response']);
    EVENT.strons.tril(1) = EVENT.strons.tril(1) + processparams.ec_temporary_timeshift;
end

% EVENT.Myevent = 'Snip';
% EVENT.type = 'snips';
% EVENT.Start = 0;

% Chans = [];
% for i=1:length(EVENT.ChanInfo)
% Chans = [Chans,EVENT.ChanInfo(i).custom_order];
% end

% EVENT.ChanInfo = Chans;
% EVENT.snips.Snip.channels = Chans;
% if any(channels2analyze>max(EVENT.ChanInfo)) || any(channels2analyze<min(EVENT.ChanInfo))
%     errormsg(['Did not record more than ' num2str(EVENT.snips.Snip.channels) ' channels.']);
%     return
% end


% if isempty(channels2analyze)
%     channels2analyze = 1:EVENT.ChanInfo;
% end
if isempty(channels2analyze)
    channels2analyze = EVENT.snips.Snip.channels;
end
EVENT.CHAN = channels2analyze;

WaveTime_Spikes = struct([]);

logmsg(['Analyzing channels: ' num2str(channels2analyze)]);
total_length = EVENT.Snips.rawtime(end)-EVENT.strons.tril(1);
clear('WaveTime_Fpikes');
WaveTime_Fpikes = struct('time',[],'data',[]);
%% Spike detection
sF = EVENT.Freq;
[b,a] = butter(5,300/(0.5*sF),'High');
y=filter(b,a,EVENT.Snips.rawsig(channels2analyze,:));
[b,a] = butter(5,10000/(0.5*sF),'Low');
y=filter(b,a,y);
k = 2; % k times downsampling
HalfW = 7;
WinWidth = 2*HalfW;

z=[];
for j = 1:length(channels2analyze)
    y(j,:) = sgolayfilt(y(j,:),3,11);
    z(j,:) = downsample(y(j,:),k);
end

%%
threshold = -50; % threshold of spike detection

for j = 1:length(channels2analyze)
    Spikes =[];
    for i = 15:WinWidth:length(z)-15
        if sum(z(j,i-HalfW:i+HalfW)<threshold)>0
            [~,m2] = min(y(j,k*(i-HalfW):k*(i+HalfW)));
            Spikes = [Spikes;[y(j,-(k*HalfW-m2)+k*(i-HalfW):-(k*HalfW-m2)+k*(i+HalfW)) -(k*HalfW-m2)+k*i]];
        end
    end
    WaveTime_Fpikes(j,1).data = Spikes(:,1:end-1);
    WaveTime_Fpikes(j,1).time = EVENT.Snips.rawtime(Spikes(:,end));
end

% %%
% threshold = +80; % threshold of spike detection
% 
% for j = 1:length(channels2analyze)
%     Spikes =[];
%     for i = 15:WinWidth:length(z)-15
%         if sum(z(j,i-HalfW:i+HalfW)>threshold)>0
%             [~,m2] = min(y(j,k*(i-HalfW):k*(i+HalfW)));
%             Spikes = [Spikes;[y(j,-(k*HalfW-m2)+k*(i-HalfW):-(k*HalfW-m2)+k*(i+HalfW)) -(k*HalfW-m2)+k*i]];
%         end
%     end
%     WaveTime_Fpikes(j,1).data = Spikes(:,1:end-1);
%     WaveTime_Fpikes(j,1).time = EVENT.Snips.rawtime(Spikes(:,end));
% end

%%
       
for ii=1:length(channels2analyze)
    %logmsg(['Sorting channel ' num2str(channels2analyze(ii))]);
    %clear kll
    if isempty(WaveTime_Fpikes(ii,1).time)
        continue
    end
    %kll.sample_interval = 1/EVENT.snips.Snip.sampf;
    %kll.data = WaveTime_Fpikes(ii,1).time;

    wtime_sp.data =  WaveTime_Fpikes(ii,1).data;
    wtime_sp.time = WaveTime_Fpikes(ii,1).time;
    wtime_sp.channel = channels2analyze(ii);
    WaveTime_Spikes = [WaveTime_Spikes wtime_sp]; %#ok<AGROW>
end %% channel channels2analyze(ii)
n_cells = length(WaveTime_Spikes);

% load stimulus starttime
stimsfile = getstimsfile( record );


if isempty(stimsfile) 
    errormsg(['No stimsfile for record ' recordfilter(record) '. Use ''stiminterview(global_record)'' to generate stimsfile. Now no analysis']);
    intervals = [EVENT.Snips.rawtime(1) EVENT.Snips.rawtime(end)]; % arbitrary, no link to real stimulus
elseif isempty(stimsfile.MTI2{end}.frameTimes)
    intervals = [stimsfile.start stimsfile.start+60*60];
else
    intervals = [stimsfile.start stimsfile.MTI2{end}.frameTimes(end)+10];
end


EVENT.strons.tril = EVENT.strons.tril * processparams.secondsmultiplier;

% shift time to fit with TTL and stimulustimes

timeshift = intervals(1)-EVENT.strons.tril(1);
timeshift = timeshift+ processparams.trial_ttl_delay; % added on 24-1-2007 to account for delay in ttl

cells = struct([]);
cll.name = '';
cll.intervals = intervals;
cll.sample_interval = 1/EVENT.Freq;
cll.detector_params = [];
cll.trial = record.test;
cll.desc_long = fullfile(datapath,record.test);
cll.desc_brief = record.test;
channels_new_index = (0:1000)*10+1; % works for up to 1000 channels, and max 10 cells per channel
for c = 1:n_cells
    if isempty(WaveTime_Spikes(c))
        continue
    end
    cll.channel = WaveTime_Spikes(c).channel;
    cll.index = channels_new_index(cll.channel); % used to identify cell
    channels_new_index(cll.channel) = channels_new_index(cll.channel) + 1;
    cll.name = sprintf('cell_%s_%.3d',...
        subst_specialchars(record.test),cll.index);
    GG = WaveTime_Spikes(c).time * processparams.secondsmultiplier + timeshift;
    cll.data = GG';
    spikes = WaveTime_Spikes(c).data; % spikes x samples
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
