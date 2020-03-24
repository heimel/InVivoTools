function cells = importtdt(record, channels2analyze, allowchanges)
%IMPORTTDT
%
% CELLS = IMPORTTDT( RECORD, CHANNELS2ANALYZE, ALLOWCHANGES=true )
%
% 2015-2017, Alexander Heimel
%

if nargin<3 || isempty(allowchanges)
    allowchanges = true;
end

processparams = ecprocessparams(record);

if processparams.always_use_matlab_tdt || isunix
    use_matlab_tdt = true;
else
    try
        F = figure('WindowStyle','normal','Visible', 'off');
        actxcontrol('TTANK.X', [20 20 60 60], F);
        close(F)
        use_matlab_tdt = false;
    catch me
        if ~strcmp(me.identifier,'MATLAB:COM:InvalidProgid')
            logmsg(me.identifier);
        end
        use_matlab_tdt = true;
    end
end

datapath=experimentpath(record,false);

EVENT.Mytank = datapath;
EVENT.Myblock = record.test;
EVENT = load_tdt(EVENT, use_matlab_tdt,allowchanges);
if ~isfield(EVENT,'strons')
    errormsg(['No triggers present in ' recordfilter(record)]);
    cells = [];
    return
end

EVENT.strons.tril(1) = use_right_trigger(record,EVENT);

if 0 && strncmp(record.stim_type,'background',10)==1
    EVENT.strons.tril(1) = EVENT.strons.tril(1) + 1.55;
end
if processparams.ec_temporary_timeshift~=0 % to check gad2 cells
    errormsg(['Shifted time by ' num2str(processparams.ec_temporary_timeshift) ' s to check laser response']);
    EVENT.strons.tril(1) = EVENT.strons.tril(1) + processparams.ec_temporary_timeshift;
end

%clean data struct
clear('WaveTime_Fpikes');
WaveTime_Fpikes = struct('time',[],'data',[]);

if ~strcmpi(processparams.spike_sorting_routine, 'Kilosort')
    EVENT.Myevent = 'Snip';
    EVENT.type = 'snips';
    EVENT.Start = 0;
else
    %check if npy-matlab is in path
    pathCell = regexp(path, pathsep, 'split');
    if ~any(contains(pathCell, 'npy-matlab'))
        f=msgbox('Kilosort requires npy-matlab! Add it to your path or get it from https://github.com/kwikteam/npy-matlab');
    end
    strTarget = fullfile(EVENT.Mytank, EVENT.Myblock);
    fs = dir(fullfile(strTarget, '*groups.csv'));
    if isempty(fs) %no sorted/curated files in folder
        % make file that kilosort can use and sort it!
        [~] = make_kilosort_data(EVENT, strTarget);
        return
    else  %load the sorted data
        WaveTime_Fpikes = load_kilosort_data(strTarget, EVENT);
    end
end


if any(channels2analyze>EVENT.snips.Snip.channels)
    errormsg(['Did not record more than ' num2str(EVENT.snips.Snip.channels) ' channels.']);
    return
end


if isempty(channels2analyze)
    channels2analyze = 1:EVENT.snips.Snip.channels;
end
EVENT.CHAN = channels2analyze;

WaveTime_Spikes = struct([]);

%remove sorted spikes that are not on channels2analyze
if strcmpi(processparams.spike_sorting_routine, 'Kilosort') %kilosort
    chanLocs = [WaveTime_Fpikes.channel];
    WaveTime_Fpikes(~ismember(chanLocs,channels2analyze)) = [];
    chanLocs_new = [WaveTime_Fpikes.channel];
    [sorted, idx] = sort(chanLocs_new);
    WaveTime_Spikes = WaveTime_Fpikes(idx);
else %load snips (non-kilosort)
    logmsg(['Analyzing channels: ' num2str(channels2analyze)]);
    total_length = EVENT.timerange(2)-EVENT.strons.tril(1);
    
    if ~use_matlab_tdt
        % cut in 60s blocks
        for i=1:length(channels2analyze)
            WaveTime_Fpikes(i,1) = struct('time',[],'data',[]);
        end
        for kk=1:ceil(total_length/60)
            EVENT.Triallngth = min(60,total_length-60*(kk-1));
            WaveTime_chspikes = ExsnipTDT(EVENT,EVENT.strons.tril(1)+60*(kk-1),use_matlab_tdt);
            for i=1:length(channels2analyze)
                WaveTime_Fpikes(i,1).time = [WaveTime_Fpikes(i,1).time; WaveTime_chspikes(i,1).time];
                WaveTime_Fpikes(i,1).data = [WaveTime_Fpikes(i,1).data; WaveTime_chspikes(i,1).data];
            end
        end
    else
        WaveTime_Fpikes = ExsnipTDT(EVENT,EVENT.strons.tril(1),use_matlab_tdt);
    end
    for ii=1:length(channels2analyze)
        %logmsg(['Sorting channel ' num2str(channels2analyze(ii))]);
        %clear kll
        if isempty(WaveTime_Fpikes(ii).time)
            continue
        end
        %kll.sample_interval = 1/EVENT.snips.Snip.sampf;
        %kll.data = WaveTime_Fpikes(ii,1).time;
        
        wtime_sp.data =  WaveTime_Fpikes(ii).data;
        wtime_sp.time = WaveTime_Fpikes(ii).time;
        wtime_sp.channel = channels2analyze(ii);
        WaveTime_Spikes = [WaveTime_Spikes wtime_sp]; %#ok<AGROW>
    end %% channel channels2analyze(ii)
end


n_cells = length(WaveTime_Spikes);

% load stimulus starttime
stimsfile = getstimsfile( record );

if isempty(stimsfile)
    errormsg(['No stimsfile for record ' recordfilter(record) '. Use ''stiminterview(global_record)'' to generate stimsfile. Now no analysis']);
    intervals = [EVENT.timerange(1) EVENT.timerange(2)]; % arbitrary, no link to real stimulus
elseif isempty(stimsfile.MTI2{end}.frameTimes)
    intervals = [stimsfile.start stimsfile.start+60*60];
else
    intervals = [stimsfile.start stimsfile.MTI2{end}.frameTimes(end)+10];
end

EVENT.strons.tril = EVENT.strons.tril * processparams.secondsmultiplier;

if 0 % to check alignment of triggers with stimulus times
    stims = getstimsfile(record); %#ok<UNRCH>
    ss = cellfun(@(x) getfield(x(1),'startStopTimes'),stims.MTI2,'UniformOutput',false);
    ss = cellfun(@(x) x(1),ss);
    figure;
    plot(EVENT.strons.tril(2:end)-ss(1:2:end)+stims.start,'.');
end

% shift time to fit with TTL and stimulustimes

timeshift = intervals(1)-EVENT.strons.tril(1);
timeshift = timeshift+ processparams.trial_ttl_delay; % added on 24-1-2007 to account for delay in ttl

cells = struct([]);
cll.name = '';
cll.intervals = intervals;
cll.sample_interval = 1/EVENT.snips.Snip.sampf;
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
    cll.data = WaveTime_Spikes(c).time * processparams.secondsmultiplier + timeshift;
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




