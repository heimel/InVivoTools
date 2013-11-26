function [measures,meanwaves,waves_time,powers] = analyse_lfp_oscillations(record,smrfile,stimsfile,measures)
%ANALYSE_LFP_OSCILLATIONS analyses lfp record for power spectra
%
%  [measures,waves,waves_time,powerm] =  analyse_lfp_oscillations(record,smrfile,stimsfile,measures)
%
% 2012, Alexander Heimel
%

error('ANALYSE_LFP_OSCILLATIONS: Deprecated. Use ANALYSE_VEPS instead');


measures = [];
waves = [];
waves_time = [];
powerm = [];

if ~exist(stimsfile,'file')
    errordlg(['Cannot find ' stimsfile ],'ANALYSE_LFPTESTRECORD');
    return
end

verbose = false;
if verbose
    figure
end

stims = load(stimsfile);
%save('ST.mat','stims')

par = getparameters(stims.saveScript);
n_angles = length(par.angle);
n_contrasts = length(par.contrast);

measures.contrast = par.contrast;
do = getDisplayOrder(stims.saveScript);
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
results = importspike2_lfp(smrfile,record.stim_type,pre_ttl,post_ttl,true);
if isempty(results)
    return
end
sample_interval = results.sample_interval; % s
freq = 1/sample_interval; % Hz



trigger = getTrigger(stims.saveScript);

if any(diff(trigger)) % i.e. more than one type of trigger
    stimss = split_stimscript_by_trigger( stims );
else
    stimss= stims;
end

% Analyze per varied variable

[analyse_params,parameter_values] = varied_parameters( stims.saveScript );
analyse_parameter = analyse_params{1};
parameter_values = parameter_values{1};


    bands = oscillation_bands;
    band_names = fields(oscillation_bands);


disp(['ANALYSE_LFP_OSCILLATIONS: Analyzing ' analyse_parameter  ' and averaging over other parameters.']);

for t = 1:length(stimss) % run over triggers
    stims = stimss(t);
    
    waves = zeros(length(stims.MTI2),length(results.waves));
    waves_time = zeros(length(stims.MTI2),length(results.waves));
    waves(1,:) = results.waves;
    waves_time(1,:) = results.waves_time - stimulus_start;
    
    h_wait = waitbar(0,'Loading LFPs...');
    for i=2:length(stims.MTI2)
        stimulus_start = (stims.MTI2{i}.startStopTimes(2)-stims.start);
        pre_ttl = max_pretime-stimulus_start;
        post_ttl = stimulus_start+max_duration+max_posttime;
        
        results = importspike2_lfp(smrfile,record.stim_type,pre_ttl,post_ttl,true);
        waves(i,:) = results.waves;
        waves_time(i,:) = results.waves_time - stimulus_start;
        waitbar(i/length(stims.MTI2));
    end
    close(h_wait);
    
    if ~isempty(record.amplification)
        amplification = record.amplification;
    else
        amplification = 1000;
        warning('ANALYSE_LFP_OSCILLATIONS:BLANK_AMPLIFICATION',...
            'ANALYSE_LFP_OSCILLATIONS: Blank amplification field in record. Defaulting to 1000x');
        warning('OFF','ANALYSE_LFP_OSCILLATIONS:BLANK_AMPLIFICATION');
    end
    waves = waves / amplification *1000;
    
    pre_ind = (waves_time(1,:)<0);
    post_ind = (waves_time(2,:)>=0);
    
    h_wait = waitbar(0,'Analyzing LFPs...');
    for i=1:length(stims.MTI2)
        
        % for Mehran, temporarily turned off, data should be loaded from
        % saved_data = fullfile(ecdatapath(record),record.test,'saved_data.mat');
        %     Wpre=waves(i,pre_ind);
        %     Wpost=waves(i,post_ind);
        %     n1=['LFPpre',num2str(i),'.mat'];save(n1,'Wpre');
        %     n2=['LFPpost',num2str(i),'.mat'];save(n2,'Wpost');
        %
            Wpre=waves(i,pre_ind);
            Wpost=waves(i,post_ind);
            Kpre=katz(Wpre);
            Kpost=katz(Wpost);
            Kfd=Kpost-Kpre;
            WEpre=wentropy(Wpre);
            WEpost=wentropy(Wpost);
            WENT=WEost-WEpre;
            Dpre=DFA(Wpre);
            Dpost=DFA(Wpost);
            Dfa=Dpost-Dpre;
            
        if verbose % plot waves
            figure('Name','Wave');
            hold on
            plot(waves_time(i,pre_ind),waves(i,pre_ind),'b');
            plot(waves_time(i,post_ind),waves(i,post_ind),'k');
            ylabel('Voltage (mV)');
            xlabel('Time (s)');
            xlim([waves_time(i,1) waves_time(i,end)]);
        end
        
        [pxx_pre,freqs_pre] = get_power(waves(i,pre_ind),freq);
        [pxx_post,freqs_post] = get_power(waves(i,post_ind),freq);
        power.freqs(:,i)=freqs_post;
        power.power(:,i)=pxx_post;
        
        power.freqs_pre(:,i)=freqs_pre;
        power.power_pre(:,i)=pxx_pre;
        
        power.postdivpre(:,i) = pxx_post./pxx_pre(findclosest(freqs_pre,freqs_post));
        power.decpostdivpre(:,i) = 10*log10(power.postdivpre(:,i));
        
        if verbose % show power
            subplot(1,3,2);
            hold on
            plot(freqs_pre,pxx_pre,'b');
            plot(freqs_post,pxx_post,'k');
            set(gca,'YScale','log');
            xlabel('Frequency (Hz)');
            ylabel('Power');
            xlim([0 90]);
        end
        
        if 0 % compute spectograms
            window = 300;
            [y,f_pre,t_pre,p_pre] = spectrogram(results.waves(i,pre_ind),window,[],[],freq,'yaxis');
            p_pre = mean(abs(p_pre),2);
            [y,f_post,t_post,p_post] = spectrogram(results.waves(i,post_ind),window,[],[],freq,'yaxis');
            [y,f,t,p] = spectrogram(waves(i,:),window,[],[],freq,'yaxis');
            p_pre = repmat( p_pre,1,size(p,2));
        end
        
        % show spectrogram
        if 0
            figure
            hold on
            surf(t-bgpretime,f,10*log10(abs(p)./abs(p_pre)),'EdgeColor','none');
            axis xy; axis tight; colormap(gray); view(0,90);
            ylim([0 100])
        end
        waitbar(i/length(stims.MTI2));
    end %i stims.MTI2{i}
    close(h_wait);
    
    
    disp('ANALYSE_LFP_OSCILLATIONS: Still need to average over other parameters');
    
    % Pooling repetitions
    do = getDisplayOrder(stims.saveScript);
    stims = get(stims.saveScript);
    %stimnrs = uniq(sort(do));
    for i = 1:length(parameter_values)
        val = parameter_values(i);
        ind = [];
        for j = 1:length(stims)
            pars = getparameters(stims{j});
            if pars.(analyse_parameter) == val
                ind = [ind find(do==j)];
            end
        end
        % only store average power spectrum
        powerm.freqs(:,i) = mean(power.freqs(:,ind),2);
        powerm.power(:,i) = mean(power.power(:,ind),2);
        
        powerm.freqs_pre(:,i) = mean(power.freqs_pre(:,ind),2);
        powerm.power_pre(:,i) = mean(power.power_pre(:,ind),2);
        
        powerm.decpostdivpre(:,i) = mean(power.decpostdivpre(:,ind),2);
        powerm.postdivpre(:,i) = mean(power.postdivpre(:,ind),2);

        powerm.freqs_post = powerm.freqs(:,1);
        powerm.freqs_pre = powerm.freqs_pre(:,1);
        powerm.power_post = powerm.power;
        

        powerm.power_evoked(:,i) = ...
            powerm.power(:,i)./powerm.power_pre(findclosest(powerm.freqs_pre,powerm.freqs_post),i);
        for f = 1:length(band_names)
            band = band_names{f};
            ind_band = find(powerm.freqs_post>bands.(band)(1) & powerm.freqs_post<bands.(band)(2));
            
            measures.([band '_evoked_power']){t}(:,i) = mean( powerm.power_evoked(ind_band,i));
            [measures.([band '_evoked_peak_power']){t}(i),ind_m] = max(powerm.power_evoked(ind_band,i));
            measures.([band '_evoked_peak_freq']){t}(i) = powerm.freqs(ind_band(ind_m));
        end
        
        
        
        waves_mean(i,:) = mean(waves(ind,:),1);
        waves_std(i,:) = std(waves(ind,:),1);
    end
    waves_time = mean(waves_time,1);
    
    %figure;
    %plot(waves_time,waves_mean);
    
    

    
    
    
%    for c = 1:n_contrasts
%        index = n_contrasts*([1:n_angles]-1)+c;
 %       powerm.power_pre(:,c) = mean(powerm.power_pre(:,index),2);
  %      powerm.power_post(:,c) = mean(powerm.power(:,index),2);
%         powerm.power_evoked(:,c) = ...
%             powerm.power_post(:,c)./powerm.power_pre(findclosest(powerm.freqs_pre,powerm.freqs_post),c);
%         for f = 1:length(band_names)
%             band = band_names{f};
%             ind_band = find(powerm.freqs_post>bands.(band)(1) & powerm.freqs_post<bands.(band)(2));
%             
%             measures.([band '_evoked_power']){t}(:,c) = mean( powerm.power_evoked(ind_band,c));
%             [measures.([band '_evoked_peak_power']){t}(c),ind] = max(powerm.power_evoked(ind_band,c));
%             measures.([band '_evoked_peak_freq']){t}(c) = powerm.freqs_post(ind_band(ind));
%         end
%     end %c
    
    
    % store mean wave
    meanwaves{t} = waves_mean;
    powers{t} = powerm;
end % t trigger




function [pxx,freqs] = get_power(waves,freq)
[pxx,freqs]=periodogram(waves,[],[],freq);
%[pxx,freqs]=periodogram(waves,[],1:150,freq);

% interested only in first 100 Hz but take more for smoothening
ind=find(freqs<200 );
freqs=freqs(ind);
pxx=pxx(ind);

if 1 % remove 50 Hz and higher harmonics
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

if 0 %smoothen
    pxx=smooth(pxx,round(length(pxx)/30));
end

% now only take first 150 Hz
ind=find(freqs<150 );
freqs=freqs(ind);
pxx=pxx(ind);


