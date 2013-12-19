function [measures,meanwaves,waves_time,powers] = analyse_veps(record,smrfile,stimsfile,measures,verbose)
%ANALYSE_VEPS analyses lfp record for power spectra
%
%  [measures,meanwaves,waves_time,powers] =  analyse_veps(record,smrfile,stimsfile,measures,verbose)
%
%      VERBOSE if 0 no graphical output at all, if 1 progress bar, if 2
%         many figures
%
% 2012-2013, Alexander Heimel
%

if nargin<5
    verbose = [];
end
if isempty(verbose)
    verbose = 1;
end

measures = [];
meanwaves = {};
powers = {};
waves_time = [];
powerm = [];


bands = oscillation_bands;
band_names = fields(oscillation_bands);

switch record.electrode
    case 'CSO'
        CSO = analyse_CSO(record,stimsfile,50,verbose); % contact point distance for SC 50, for VC 100
        return
            case 'coherence'
        WCoh = analyse_wavecoh(record,stimsfile); % contact point distance for SC 50, for VC 100
        return
end

switch record.stim_type
    case 'sg'
        disp([upper(mfilename) ': LFP analysis of sg is not implemented.']);
        return
end

process_params = ecprocessparams(record);

if strcmp(record.setup,'antigua')~=1 && ~exist(stimsfile,'file')
    errordlg(['Cannot find ' stimsfile ],'ANALYSE_VEPS');
    return
end

stims = load(stimsfile);
%save('ST.mat','stims')

par = getparameters(stims.saveScript);

%do = getDisplayOrder(stims.saveScript);
%save('orders_cont_orient.mat','do')

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

switch lower(record.setup)
    case 'antigua'
        datapath=ecdatapath(record);
        %         chnorder = 1:numchannel;
        %         Tankname = 'Mouse';
        blocknames = [record.test];
        clear EVENT
        EVENT.Mytank = datapath;
        EVENT.Myblock = blocknames;
        EVENT = importtdt(EVENT);
        numchannel = max([EVENT.strms.channels]);
        if isfield(record, 'channels') &&  ~isempty(record.channels)
            channels_to_read = record.channels;
        else
            channels_to_read = 1:numchannel;
        end
        disp(['ANALYSE_VEPS: FOR DEBUGGING ONLY CHANNELS # ',num2str(channels_to_read)]);
        %         numchannel = 2;
        EVENT.Myevent = 'LFPs';
        EVENT.Start =  -max_pretime;
        EVENT.Triallngth =  post_ttl+pre_ttl;
        results.sample_interval=1/EVENT.strms(1,3).sampf;
        startindTDT=EVENT.strons.tril(1)-pre_ttl;
        SIG = signalsTDT(EVENT,stimulus_start+startindTDT);
        for j=1:length(channels_to_read)
            results.waves{1,j}=SIG{channels_to_read(j),1};
        end
    otherwise
        results = importspike2_lfp(smrfile,record.stim_type,pre_ttl,post_ttl,true,record.amplification,verbose);
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

if ~isempty(isletter(record.stim_type)) && ~strcmp(record.stim_type,'ps')  && ~strcmp(record.stim_type,'sg') 
    analyse_second_parameter = record.stim_type;
    parameter_second_values = {parameter_salues{strmatch(record.stim_type,analyse_params)}};
else
    analyse_second_parameter = '';
end;

% pars2 = getparameters(pars.ps_add);

parameter_values = parameter_values{1};

measures.variable = analyse_parameter;

numLFPchannels=length(results.waves);
n_conditions = length(parameter_values);
% measures.LFPnumbers=numLFPchannels;

disp(['ANALYSE_VEPS: Analyzing ' analyse_parameter  ' and averaging over other parameters.']);
for lfpch=1:numLFPchannels
    for t = 1:length(stimss) % run over triggers
        stims = stimss(t);
        measures(lfpch).range{1,t} = parameter_values;

        switch lower(record.setup)
            case 'antigua'
                waves = zeros(length(stims.MTI2),length(results.waves{1,lfpch}));
                waves_time = zeros(length(stims.MTI2),length(results.waves{1,lfpch}));
            otherwise
                waves = zeros(length(stims.MTI2),length(results.waves{1,lfpch}));
                waves_time = zeros(length(stims.MTI2),length(results.waves{1,lfpch}));
        end

        %    waves(1,:) = results.waves;
        %    waves_time(1,:) = results.waves_time - stimulus_start;

        % loading lfp data
        if verbose
            h_wait = waitbar(0,'Loading LFPs...');
        end
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

            %             clear importspike2_lfp

            switch lower(record.setup)
                case 'antigua'

                    EVENT.Start =  -max_pretime;
                    EVENT.Triallngth =  post_ttl+pre_ttl;
                    SIG = signalsTDT(EVENT,stimulus_start+startindTDT);
                    for j=channels_to_read
                        results.waves{1,j}=SIG{j,1};
                    end
                    waves(i,:) = 2000*results.waves{1,channels_to_read(lfpch)};
                    waves_time(i,:) = -stimulus_start-pre_ttl+(0:length(waves(i,:))-1)*results.sample_interval;
                otherwise
                    results = importspike2_lfp(smrfile,record.stim_type,...
                        pre_ttl,post_ttl,true,record.amplification,verbose);
                    waves(i,:) = results.waves{1,lfpch};
                    waves_time(i,:) = results.waves_time{1,lfpch} - stimulus_start;
            end
            % [results.waves,line2data] = remove_line_noise(results.waves,1/results.sample_interval);


            if verbose
                waitbar(i/length(stims.MTI2));
            end
        end
        if verbose
            close(h_wait);
        end

        % Computing spectra, Pooling repetitions
        do = getDisplayOrder(stims.saveScript);
        stims = get(stims.saveScript);
        if verbose
            h_wait = waitbar(0,['Computing LFP [', num2str(lfpch) ,'] spectra...']);
        end

        if 0 % notch 50 Hz
            w0 = 50/(0.5*Fs);
            bw = w0/15;
            [bb,aa] = iirnotch(w0,bw);
        end
        IND={};
        for i = 1:n_conditions % temp only doing high contrasts
            val = parameter_values(i);
            ind = [];
            for j = 1:length(stims)
                pars = getparameters(stims{j});
                if ~isempty(analyse_second_parameter)
                    if pars.(analyse_parameter) == val && pars.(analyse_second_parameter) == parameter_second_values{1}(5) % Mehran
                        ind = [ind find(do==j)];
                    end
                else
                    if pars.(analyse_parameter) == val
                        ind = [ind find(do==j)];
                    end
                end
                
            end
%             waves_timeVC=waves_time(ind,:);waves_VC=waves(ind,:);wavefile = ['waves_3',num2str(i),'_',num2str(channels_to_read),'.mat'];
%             Wavepath=fullfile(datapath,EVENT.Myblock,wavefile);
%             save(Wavepath,'waves_VC','waves_timeVC');
%         end
            IND=[IND,ind];

            waves_mean(i,:) = mean(waves(ind,:),1);
            waves_std(i,:) = std(waves(ind,:),1);

            if process_params.entropy_analysis
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

                    measures(lfpch).([band '_KfdM']){t}(i) = mean(Kfd{b}(ind));
                    measures(lfpch).([band '_KfdS']){t}(i) = std(Kfd{b}(ind));

                    measures(lfpch).([band '_WENTM']){t}(i) = mean(WENT{b}(ind));
                    measures(lfpch).([band '_WENTS']){t}(i) = std(WENT{b}(ind));

                    measures(lfpch).([band '_DfaM']){t}(i) = mean(Dfa{b}(ind));
                    measures(lfpch).([band '_DfaS']){t}(i) = std(Dfa{b}(ind));
                end % band b
            end

            onsettime = -mean(waves_time(ind,1));
            if std(waves_time(ind,1))>0.001 % i.e. jitter in onser
                disp('ANALYSE_VEPS: Jitter in onset times larger than 1 ms.');
            end

            if 0 % work on Daubechies wavelet analysis
                figure;
                amax = 8;
                a = 1:2^amax;
                coefs=0;
                for j=1:length(ind)
                    Coefs = cwt(waves(ind(j),:),a,'db4','scal');
                    coefs=coefs+Coefs;
                end
                coefs=coefs/length(ind);
                f = scal2frq(a,'db4',1/Fs);
                ff=f';FF=repmat(ff,[1,size(coefs,2)]);
                coefs=FF.*coefs;
                figure; SCimg = wscalogram('image',coefs);
                figure;surf((1:size(coefs,2)),f,abs(coefs),'EdgeColor','none');axis tight; axis square; view(0,90);ylim([0 100])
            end

            data = reshape(waves(ind,:)',size(waves,2),1,length(ind));
            if strcmp(process_params.vep_remove_line_noise,'temporal_domain')
                data = remove_line_noise(data,Fs);
            end
            if process_params.vep_remove_vep_mean
                data = remove_vep_mean( data );
            end
            Fs = 380; % temporarily Mehran
            [powerm.power(:,:,i),powerm.freqs,powerm.time] = ...
                GetPowerWavelet(data,Fs,onsettime,verbose);

            if verbose
                waitbar(i/length(parameter_values));
            end
        end
        if verbose
            close(h_wait);
        end
        % set pre and postwindows
        pre_ind = (powerm.time>process_params.pre_window(1) & ...
            powerm.time<=process_params.pre_window(2) & ...
            powerm.time>(powerm.time(1)+process_params.separation_from_prev_stim_off)  );
        post_ind = (powerm.time>process_params.post_window(1) & ...
            powerm.time<process_params.post_window(2));

        onsetP=find(diff(post_ind)~=0);
        postnum=length(post_ind(post_ind~=0));

        % Integrate power
        powerm.freqs_pre = powerm.freqs;
        powerm.freqs_post = powerm.freqs;
        powerm.power_post = mean(powerm.power(:,post_ind,:),2); % freqs x channels x conditions
        powerm.power_pre = mean(powerm.power(:,pre_ind,:),2); % freqs x channels x conditions
        powerm.postdivpre = powerm.power_post ./ powerm.power_pre;
        %     powerm.ers = 100*((powerm.power_pre-powerm.power_post) ./ powerm.power_pre);
        powerm.decpostdivpre = 10*log10(powerm.postdivpre);
        powerm.power_evoked = powerm.postdivpre-1;

        for f = 1:length(band_names)
            band = band_names{f};
            ind_band = find(powerm.freqs>bands.(band)(1) & powerm.freqs<bands.(band)(2));
            measures(lfpch).([band '_power_pre']){1,t} = mean( powerm.power_pre(ind_band,:,:),1);
            measures(lfpch).([band '_power_post']){1,t} = mean( powerm.power_post(ind_band,:,:),1);



            for c = 1:n_conditions
                [measures(lfpch).([band '_peak_freq_pre']){1,t}(c) ...
                    measures(lfpch).([band '_peak_power_pre']){1,t}(c) ] = ...
                    extract_peak(powerm.freqs(ind_band),powerm.power_pre(ind_band,:,c)');
                [measures(lfpch).([band '_peak_freq_post']){1,t}(c) ...
                    measures(lfpch).([band '_peak_power_post']){1,t}(c)] = ...
                    extract_peak(powerm.freqs(ind_band),powerm.power_post(ind_band,:,c)');
            end
            %         [m,ind_peak]=findpeaks(powerm.power_pre(ind_band,:,end));
            %        powerm.freqs(ind_band(ind))

            measures(lfpch).([band '_evoked_power']){1,t} = mean( powerm.power_evoked(ind_band,:,:),1);

            %         measures.([band '_evoked_time']){t} = squeeze(mean(powerm.power(ind_band,post_ind,:),1))-repmat(squeeze(mean(powerm.power_pre(ind_band,1,:),1))',[postnum,1]);
            % measures(lfpch).([band '_evoked_pretime']){1,t} = squeeze(mean(powerm.power(ind_band,pre_ind,:),1));
            %         measures.([band '_power_ers']){t} = 100*((mean(powerm.power_pre(ind_band,:,:),1)-mean(powerm.power_post(ind_band,:,:),1)) ./ ...
            %             mean(powerm.power_pre(ind_band,:,:),1));
            for c = 1:n_conditions
                [measures(lfpch).([band '_evoked_peak_power']){1,t}(c),ind_m] = max(powerm.power_evoked(ind_band,1,c));
                measures(lfpch).([band '_evoked_peak_freq']){1,t}(c) = powerm.freqs(ind_band(ind_m));
            end
        end % bands f

        %     Cr_post=ones(length(band_names),length(band_names),n_conditions);
        %     Cr_pre=ones(length(band_names),length(band_names),n_conditions);
        %     for f1 = 1:length(band_names)-1
        %         for f2 = f1+1:length(band_names)
        %             banda = band_names{f1};
        %             bandb = band_names{f2};
        %             for c = 1:n_conditions
        %                 cr_post=corrcoef(measures.([banda '_evoked_time']){t}(:,c),measures.([bandb '_evoked_time']){t}(:,c));
        %                 cr_pre=corrcoef(measures.([banda '_evoked_pretime']){t}(:,c),measures.([bandb '_evoked_pretime']){t}(:,c));
        %                 Cr_post(f1,f2,c)=cr_post(1,2);Cr_post(f2,f1,c)=Cr_post(f1,f2,c);
        %                 Cr_pre(f1,f2,c)=cr_pre(1,2);Cr_pre(f2,f1,c)=Cr_pre(f1,f2,c);
        %             end
        %         end
        %     end
        %     measures.('evoked_crossfreq_post'){t}=Cr_post;
        %     measures.('evoked_crossfreq_pre'){t}=Cr_pre;
        %     measures.('evoked_crossfreq_prepost'){t}=abs(Cr_post)-abs(Cr_pre);
        % store mean wave
        waves_time = mean(waves_time,1);
        meanwaves{t}{lfpch,1} = waves_mean;
        powers{t}{lfpch,1} = powerm;
    end % t trigger

    if length(stimss)>1 % i.e. multiple triggers
        for i = 1:n_conditions
            for t1 = 1:length(stimss)
                for t2 = (t1+1):length(stimss)
                    for f = 1:length(band_names)
                        band = band_names{f};
                        measures(lfpch).([band '_evoked_power_trig' num2str(t2) 'to' num2str(t1) ])(:,i) = ...
                            measures(lfpch).([band '_evoked_power']){1,t2}(:,i) ./ ...
                            measures(lfpch).([band '_evoked_power']){1,t1}(:,i);

                        measures(lfpch).([band '_evoked_peak_power_trig' num2str(t2) 'to' num2str(t1) ])(i) = ...
                            measures(lfpch).([band '_evoked_peak_power']){1,t2}(:,i) ./ ...
                            measures(lfpch).([band '_evoked_peak_power']){1,t1}(:,i);

                        measures(lfpch).([band '_evoked_peak_freq_trig' num2str(t2) 'to' num2str(t1)])(i) = ...
                            measures(lfpch).([band '_evoked_peak_freq']){1,t2}(:,i) ./ ...
                            measures(lfpch).([band '_evoked_peak_freq']){1,t1}(:,i);
                    end % band f
                end % trigger t2
            end % trigger t1
        end % condition i
    end
end % stimulusscript i

waves = meanwaves;
powerm = powers;
for ch=1:numLFPchannels
    for t=1:length(powerm) % triggers
        for i=1:n_conditions
            val = parameter_values(i);
            eval(['powerm{t}{ch}.power_' subst_specialchars(num2str(val)) '=powerm{t}{ch}.power(:,:,i);']);
        end
    end
end


wavefile=fullfile(ecdatapath(record),record.test,'saved_data.mat');
save(wavefile,'waves','waves_time','powerm');




function [pxx,freqs,time] = get_power(waves,Fs,params,verbose)
% Fs is sampling frequency
% waves is trials x samples
% pxx is (frequencies x samples x channels)
% freqs gives the vector of calculated frequencies in Hz
% t gives the vector of sample times

if strcmp( params.vep_remove_line_noise,'temporal_domain')
    disp('ANALYSE_VEPS: Still to implement removal of line noise in temporal domain')
end

switch params.vep_poweranalysis_type
    case 'wavelet'
        Fs = 380;
        [pxx,freqs,time] = GetPowerWavelet(reshape(waves,numel(waves),1,1),Fs,verbose);
    case 'periodogram'
        [pxx,freqs]=periodogram(waves,[],[],Fs);

        % interested only in first 100 Hz but take more for smoothening
        ind=find(freqs<200 );
        freqs=freqs(ind);
        pxx=pxx(ind);

        if strcmp( params.vep_remove_line_noise,'frequency_domain')
            % remove 50 Hz line noise and higher harmonics
            ind=find(freqs>50.5 | freqs<49.5 );
            freqs=freqs(ind);
            pxx=pxx(ind);
            ind=find(freqs>100.5 | freqs<99.5 );
            freqs=freqs(ind);
            pxx=pxx(ind);
            ind=find(freqs>150.5 | freqs<149.5 );
            freqs=freqs(ind);
            pxx=pxx(ind);
        end

        if 1%smoothen
            if params.vep_log10_freqs
                [pxx,freqs]=slidingwindowfunc(log10(freqs),pxx,log10(1),...
                    (log10(150)-log10(1))/150,log10(150),(log10(150)-log10(1))/50,'mean',0);
                freqs=10.^freqs;
            else
                % pxx=smooth(freqs,pxx,0.02); %round(length(pxx)/50)
                [pxx,freqs] = slidingwindowfunc(freqs,pxx,1,1,150,150/50,'mean',0);
            end


        end

        % show spectrogram
        if verbose>1
            figure
            hold on
            %            surf(t-pretime,f,10*log10(abs(p)./abs(p_pre)),'EdgeColor','none');
            %             surf(time-pretime,freqs,10*log10(abs(p(:,:,i))),'EdgeColor','none');
            axis xy; axis tight; colormap(gray); view(0,90);
            ylim([0 100])

        end

end

% now only take first 150 Hz
ind=find(freqs<150 );
freqs=freqs(ind);
pxx=pxx(ind);

function  data = remove_vep_mean( data )
data = data - repmat(mean(data,3),[1 1 size(data,3)]);

function [px,py] = extract_peak(x,y)
% subtract slope of y and the get max
ys = y - (x-x(1))*(y(end)-y(1))/(x(end)-x(1));
%                 figure;
%                 plot(x,y);
%                 hold on
%                 plot(x,powerm.power_pre(ind_band,:,c),'r');
[alaki,f_ind] = max(ys);
px = x(f_ind);
py = y(f_ind);
