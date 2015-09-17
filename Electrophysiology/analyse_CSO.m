function CSO = analyse_CSO(record,stimsfile,contdist,verbose)
%ANALYSE_CSO, works just if record.setup is antigua
%
% 2014 Mehran Ahmadlou

if nargin<5
    verbose = [];
end
if isempty(verbose)
    verbose = 1;
end

process_params = ecprocessparams(record);
% params.pre_window = [-0.5 0];
% params.post_window = [0 1.5];

if strcmp(record.setup,'antigua')~=1 && ~exist(stimsfile,'file')
    errormsg(['Cannot find ' stimsfile ]);
    return
end

stims = load(stimsfile);
par = getparameters(stims.saveScript);
% do = getDisplayOrder(stims.saveScript);

% note, taking all times from stims.mat because the number of samples should be equal
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


datapath = experimentpath(record,false);
%         chnorder = 1:numchannel;
%         Tankname = 'Mouse';
blocknames = [record.test];
clear EVENT
EVENT.Mytank = datapath;
EVENT.Myblock = blocknames;
EVENT = importtdt(EVENT);
EVENT.strons.tril(1) = use_right_trigger(record,EVENT);
numchannel = max([EVENT.strms.channels]);
%         channels_to_read = 1:numchannel;
if isfield(record, 'channels') &&  ~isempty(record.channels)
    channels_to_read = record.channels;
else
    channels_to_read = 1:numchannel;
end
disp(['ANALYSE_CSO: ONLY FOR CHANNELS  ',num2str(channels_to_read)]);
%         numchannel = 2;
EVENT.Myevent = 'LFPs';
EVENT.Start =  -max_pretime;
EVENT.Triallngth =  post_ttl+pre_ttl;
results.sample_interval=1/EVENT.strms(1,3).sampf;
startindTDT=EVENT.strons.tril(1)-pre_ttl;
Sigs = signalsTDT(EVENT,stimulus_start+startindTDT);
for j=1:length(channels_to_read)
    results.waves{1,j}=Sigs{channels_to_read(j),1};
end

% [results.waves,line2data] = remove_line_noise(results.waves,1/results.sample_interval);

if isempty(results) || isempty(results.waves)
    disp('ANALYSE_VEPS: No data present');
    return
end
sample_interval = results.sample_interval; % s
Fs = 1/sample_interval; % Hz sample frequency

trigger = getTrigger(stims.saveScript);

if any(diff(trigger)) % i.e. more than one type of trigger
    stimss = split_stimscript_by_trigger( stims );
else
    stimss= stims;
end

% Analyze per varied variable

[analyse_params,parameter_salues] = varied_parameters( stims.saveScript );
if ~isempty(isletter(record.stim_parameters))
    analyse_parameter = record.stim_parameters;
    parameter_values = {parameter_salues{strmatch(record.stim_parameters,analyse_params)}};
else
    analyse_parameter = 'contrast'; % nothing varied, defaulting to contrast
    parameter_values = {par.contrast};
end

if ~isempty(isletter(record.stim_type))
    analyse_second_parameter = record.stim_type;
    parameter_second_values = {parameter_salues{strmatch(record.stim_type,analyse_params)}};
else
    analyse_second_parameter = '';
end;

parameter_values = parameter_values{1};

numLFPchannels=length(results.waves);
n_conditions = length(parameter_values);

disp(['ANALYSE_VEPS: Analyzing ' analyse_parameter  ' and averaging over other parameters.']);

for t = 1:length(stimss) % run over triggers
stims = stimss(t);
for i=1:length(stims.MTI2)
    stimulus_start = (stims.MTI2{i}.startStopTimes(2)-stims.start);
    if all(stims.MTI2{i}.startStopTimes==0)
        disp('ANALYSE_VEPS: Corrupt stims.mat file or not all stimuli shown?');
        return
    end
    pre_ttl = max_pretime-stimulus_start;
    post_ttl = stimulus_start+max_duration+max_posttime;
    if pre_ttl>0
        keyboard
    end
    EVENT.Start =  -max_pretime;
    EVENT.Triallngth =  post_ttl+pre_ttl;
    Sigs = signalsTDT(EVENT,stimulus_start+startindTDT);
    RW=[];
    for j=channels_to_read
       RW = [RW,Sigs{j,1}];
    end
    results.waves=RW';
    waves{i} = 2000*results.waves;
    %             waves_time(i,:) = -stimulus_start-pre_ttl+(0:length(waves(i,:))-1)*results.sample_interval;
end

[a_low,b_low] = butter(7,100/(.5*Fs),'low'); % lowpass
[a_high,b_high] = butter(3,1/(.5*Fs),'high'); % highpass

% Computing cso, Pooling repetitions
do = getDisplayOrder(stims.saveScript);
stims = get(stims.saveScript);
CSO={};
for i = 1:n_conditions
    val = parameter_values(i);
    ind = [];
    for j = 1:length(stims)
        pars = getparameters(stims{j});
        if ~isempty(analyse_second_parameter)
            if pars.(analyse_parameter) == val && pars.(analyse_second_parameter) == parameter_second_values{1}(1) % Mehran
                ind = [ind find(do==j)];
            end
        else
            if pars.(analyse_parameter) == val
                ind = [ind find(do==j)];
            end
        end
        
    end
%     WAVE_CSO=0;
%     for k=ind
%         wave_cso = CSOcompute(waves{k},contdist);
%         WAVE_CSO = WAVE_CSO + wave_cso;
%     end;
%     WAVE_CSO = WAVE_CSO/length(ind);
%     CSO = [CSO,WAVE_CSO];
    wave_cso=0;
    for k=ind
            w = filter(a_low,b_low,waves{k});
%         w = filter(a_high,b_high,w);
        wave_cso = wave_cso + w;
    end;
    wave_cso = wave_cso/length(ind);
    WAVE_CSO = CSOcompute(wave_cso,contdist);
    
    CSO = [CSO,WAVE_CSO];
%     waves_std(i,:) = std(waves(ind,:),1);
end
if t > 1
wavefile=fullfile(experimentpath(record),['CSO_data',num2str(t),'.mat']);
save(wavefile,'CSO');
else
wavefile=fullfile(experimentpath(record),'CSO_data.mat');
save(wavefile,'CSO');
end
end
display('finished!')

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