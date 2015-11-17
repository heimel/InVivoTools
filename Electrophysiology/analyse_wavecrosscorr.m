function analyse_wavecrosscorr(record,stimsfile,a1,b1,a2,b2)
%ANALYSE_CSO, works just if record.setup is antigua

% if nargin<3
%     verbose = [];
% end
% if isempty(verbose)
%     verbose = 1;
% end
cc=0;
WTcorr=[];
for kk = [5 6]
    for ll = [13 14]
        channels_to_read1=kk;
        channels_to_read2=ll;
        cc=cc+1;
        
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
        
        disp(['ANALYSE_COH:   channels ',num2str(channels_to_read1),' versus channels ',num2str(channels_to_read2)]);
        %         numchannel = 2;
        EVENT.Myevent = 'LFPs';
        EVENT.Start =  -max_pretime;
        EVENT.Triallngth =  post_ttl+pre_ttl;
        results.sample_interval=1/EVENT.strms(1,3).sampf;
        if length(EVENT.strons.tril)>1
            errormsg(['More than one trigger in ' recordfilter(record) '. Taking last']);
            EVENT.strons.tril(1)=EVENT.strons.tril(end);
        end
        startindTDT=EVENT.strons.tril(1)-pre_ttl;
        Sigs = signalsTDT(EVENT,stimulus_start+startindTDT);
        %         for j=1:length(channels_to_read1)
        %             results.waves1{1,j}=Sigs{channels_to_read1(j),1};
        %         end
        %         for j=1:length(channels_to_read2)
        %             results.waves2{1,j}=Sigs{channels_to_read2(j),1};
        %         end
        results.waves1=Sigs{channels_to_read1,1};
        results.waves2=Sigs{channels_to_read2,1};
        % [results.waves,line2data] = remove_line_noise(results.waves,1/results.sample_interval);
        
        if isempty(results) || isempty(results.waves1)  || isempty(results.waves2)
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
        
        %         numLFPchannels1=length(results.waves1);
        %         numLFPchannels2=length(results.waves2);
        numLFPchannels1=1;
        numLFPchannels2=1;
        n_conditions = length(parameter_values);
        
        disp(['ANALYSE_COH: Analyzing ' analyse_parameter  ' and averaging over other parameters.']);
        
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
                %                 if length(EVENT.strons.tril)>1
                %                     errormsg(['More than one trigger in ' recordfilter(record) '. Taking last']);
                %                     EVENT.strons.tril(1)=EVENT.strons.tril(end);
                %                 end
                %                 startindTDT=EVENT.strons.tril(1)-pre_ttl;
                Sigs = signalsTDT(EVENT,stimulus_start+startindTDT);
                RW=[];
                for j=channels_to_read1
                    RW = [RW,Sigs{j,1}];
                end
                results.waves1=RW';
                waves1{i} = 2000*results.waves1;
                RW=[];
                for j=channels_to_read2
                    RW = [RW,Sigs{j,1}];
                end
                results.waves2=RW';
                waves2{i} = 2000*results.waves2;
            end
            
            waves_time = -stimulus_start-pre_ttl+(0:length(waves1{1}(1,:))-1)*results.sample_interval;
            
            % Computing cso, Pooling repetitions
            do = getDisplayOrder(stims.saveScript);
            stims = get(stims.saveScript);
            Wcoh={};
            for i = n_conditions %1:n_conditions
                val = parameter_values(i);
                ind = [];
                for j = 1:length(stims)
                    pars = getparameters(stims{j});
                    if ~isempty(analyse_second_parameter)
                        if pars.(analyse_parameter) == val && pars.(analyse_second_parameter) == parameter_second_values{1}(2) % Mehran
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
                    [wave_coh,period] = WTCORRcompute(waves1{k},waves2{k},a1,b1,a2,b2,waves_time);
                    WAVE_COH = WAVE_COH + wave_coh;
                end;
                WAVE_COH = WAVE_COH/length(ind);
                Wcoh = [Wcoh,WAVE_COH];
                %     waves_std(i,:) = std(waves(ind,:),1);
            end
        end
        WTcorr=[WTcorr;Wcoh];
        
        waitbar(cc/4);
    end
end

fname = ['wtcorr_data,',num2str(a1),',',num2str(b1),',',num2str(a2),',',num2str(b2),'.mat'];
wavefile=fullfile(experimentpath(record),fname);
save(wavefile,'WTcorr','period','waves_time','a1','b1','a2','b2');

pause(10)
