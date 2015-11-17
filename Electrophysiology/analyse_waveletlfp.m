function Wlfp = analyse_waveletlfp(record,stimsfile)

process_params = ecprocessparams(record);

if strcmp(record.setup,'antigua')~=1 && ~exist(stimsfile,'file')
    errordlg(['Cannot find ' stimsfile ],'ANALYSE_VEPS');
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


datapath=experimentpath(record,false);
%         chnorder = 1:numchannel;
%         Tankname = 'Mouse';
blocknames = [record.test];
clear EVENT
EVENT.Mytank = datapath;
EVENT.Myblock = blocknames;
EVENT = load_tdt(EVENT);
numchannel = max([EVENT.strms.channels]);
%         channels_to_read = 1:numchannel;
if isfield(record, 'channels') &&  ~isempty(record.channels)
    channels_to_read = record.channels;
else
    channels_to_read = 1:numchannel;
end
% channels_to_read = [2:3];
disp(['ANALYSE_WAVELETLFP:   channels ',num2str(channels_to_read)]);
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
    disp('ANALYSE_COH: No data present');
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

numLFPchannels1=length(results.waves);
n_conditions = length(parameter_values);

disp(['ANALYSE_WAVELETLFP: Analyzing ' analyse_parameter  ' and averaging over other parameters.']);

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
    end
    
    waves_time = -stimulus_start-pre_ttl+(0:length(waves{1}(1,:))-1)*results.sample_interval;
    
    % Computing cso, Pooling repetitions
    do = getDisplayOrder(stims.saveScript);
    stims = get(stims.saveScript);
    Wlfp={};
    gammapower=[];
    hh = waitbar(0,'wavelet spectrum...');
    for i = 1:n_conditions
        waitbar(i/n_conditions);
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
        WAVE_COH=0;
        for k=ind
            [wave_coh,period] = wt([waves_time',waves{k}'],'Maxscale',32);
            WAVE_COH = WAVE_COH + (abs(wave_coh)).^2;
        end;
        WAVE_COH = WAVE_COH/length(ind);
        Wlfp = [Wlfp,WAVE_COH];
        gpow=mean(mean(abs(WAVE_COH(30:41,floor(length(WAVE_COH)/2):3*floor(length(WAVE_COH)/4)))))-mean(mean(abs(WAVE_COH(30:41,floor(length(WAVE_COH)/4):floor(length(WAVE_COH)/2)))));
        gammapower=[gammapower,gpow];
        %     waves_std(i,:) = std(waves(ind,:),1);
    end
    close(hh)
    fname = ['waveletspectrum_data_trig',num2str(t),'channels',num2str(channels_to_read),'.mat'];
    wavefile=fullfile(experimentpath(record),fname);
    save(wavefile,'Wlfp','gammapower','period','waves_time','channels_to_read');
end
% figure;
% for i=1:n_conditions
%     subplot(1,n_conditions,i);imagesc(abs(Wlfp{1,i}),[0 5])
% end
figure;
for i=1:n_conditions
    G=(repmat((1./period),[length(Wlfp{1,i}),1]))'.*Wlfp{1,1};
    subplot(1,n_conditions,i);imagesc(abs(G(1:60,:)),[0 1.2])
end

% C1=mean(G(21:60,1:771)');
% C2=mean(G(21:60,772:end)');
% figure;plot(1./period(60:-1:21),C1(end:-1:1),'b');hold on;plot(1./period(60:-1:21),C2(end:-1:1),'r');
