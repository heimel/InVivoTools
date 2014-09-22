function results_lfptestrecord( record )
%RESULTS_LFPTESTRECORD
%
%  RESULTS_LFPTESTRECORD( record )
%
%  2009-2012, Alexander Heimel
%
global measures analysed_stimulus powerm channels waves_time

measures = record.measures;

% channels = get_channels2analyze( record );

NUMLFP = length(measures);

datapath = ecdatapath(record);
stims = getstimsfile(record);
% stimsfile = fullfile(datapath,record.test,'stims.mat');
% if exist(stimsfile,'file')
%     stims = load(stimsfile);
% else
%     stims = [];
% end

switch record.electrode
    case 'CSO'
        MatFile=fullfile(datapath,record.test,'CSO_data.mat'); % contact point distance for SC 0.05, for VC 0.10
        load(MatFile)
        F=length(CSO);
        figure
        for i=1:F
            subplot(F,1,i);imagesc(-1:1,8:1,CSO{1,i},[-0.0001 0.0001]);
        end
        return
    case 'coherence'
        return
    case 'wtcrosscorr'
        return
end
% channels = [1,2];
saved_data = fullfile(ecdatapath(record),record.test,['saved_data',num2str(channels)]);
if exist([saved_data,'.mat'],'file')
    load(saved_data);
end

for lfpch=1:NUMLFP
    
    tit = ['LFP ' ' ' num2str(lfpch) ' ' record.stim_type ' ' record.mouse ' ' record.date ' ' record.test ];
    tit(tit=='_') = '-';
    
    
    subheight=150; % pixel
    subwidth=200; % pixel
    titleheight=40; %pixel
    
    screensize=get(0,'ScreenSize');
    
    
    
    % open figure
    h.fig=figure;
    height=subheight;
    width=3*subwidth;
    pos=[ fix( [(screensize(3)-width)/2  (screensize(4)-height-titleheight)/2]) ...
        width height+titleheight];
    set(gcf,'Position',pos);
    
    % write title above graph
    reltitlepos=(subheight)/(subheight+titleheight);
    subplot('position',[0 reltitlepos 1 1-reltitlepos]);
    axis off
    h.title=text(0.5,0.5,tit,'HorizontalAlignment','center');
    
    relsubheight=reltitlepos;
    
    % text info
    subplot('position',...
        [ 0 reltitlepos-1*relsubheight 1/4 relsubheight]);
    axis off
    
    
    switch record.stim_type
        case 'io'
        case 'pp'
            y=printtext(subst_ctlchars(['first pulse: ' num2str(measures.curve(2,1),2) ' mV']));
            y=printtext(subst_ctlchars(['paired pulse ratio: ' num2str(measures.paired_pulse_ratio,2)]),y);
            y=printtext(subst_ctlchars(['last pulse ratio: ' num2str(measures.last_pulse_ratio,2)]),y);
    end
    
    
    if exist('waves','var') && ~isempty(waves)
        % raw traces
        subplot('position',...
            [ 1/3+0.01 reltitlepos-(1-0.2)*relsubheight 1/3*0.96 relsubheight*0.8]);
        hold on
        
        % zero at t=0
        ind_nul=findclosest(waves_time,0);
        
        if ~iscell(waves)
            waves = {waves};
        end
        
        clr = 'kbrg';
        for i = 1:length(waves)
            wavs=waves{1,i}{lfpch,1}';
            wavs=wavs-repmat(wavs(ind_nul,:),size(wavs,1),1);
            mean_wavs=mean(wavs,2);
            h.mean=plot(waves_time,mean_wavs,clr(i));
        end
        
        ind_post_stim=findclosest(waves_time,0.005);
        
        ax=axis;
        ax([1 2])=[waves_time(1),waves_time(end)]; %#ok<COLND>
        ax(3)=min(min(wavs(ind_post_stim:end,:)))-0.1;
        ax(4)=max(max(wavs(ind_post_stim:end,:)))+0.1;
        
        axis(ax);
        xlabel('Time (s)');
        ylabel('Mean response (mV)');
    end
    
    % response graph
    subplot('position',...
        [ 2/3+0.01 reltitlepos-(1-0.2)*relsubheight 1/3*0.96 relsubheight*0.8]);
    hold on;box off
    
    switch record.mouse(1:min(5,end))
        case {'12.28','11.51'}
            triggername{1} = ', Light off';
            triggername{2} = ', Light on';
        otherwise
            if exist('powerm','var') && length(powerm)>1
                for t=1:length(powerm)
                    triggername{t} = [', Trigger ' num2str(t)];
                end
            else
                triggername{1} = '';
            end
    end
    
    band_names = fields(oscillation_bands);
    n_bands = length(band_names);
    
    switch record.stim_type
        case 'io'
            plot( measures.curve(1,:), measures.curve(2,:),'k');
            errorbar( measures.curve(1,:), measures.curve(2,:),measures.curve(3,:),'k');
            xlabel('Stimulus intensity (mA)');
        case 'pp'
            plot( measures.norm_curve(1,:), measures.norm_curve(2,:),'ok');
            errorbar( measures.norm_curve(1,:), measures.norm_curve(2,:),measures.norm_curve(3,:),'k');
            xlabel('Stimulus number');
            axis([ 1 size(measures.norm_curve,2) 0 2]);
            axis square
            set(gca,'XTick',(1:size(measures.norm_curve,2)));
        otherwise
            if exist('waves','var')
                set(h.fig,'Name',[record.test ' - VEP'],'Numbertitle','off');
                
                clr = 'kbrg';
                % plot again, shorter period, different y-offsets
                for i = 1:length(waves)
                    wavs=waves{i}{lfpch,1}';
                    wavs=wavs-repmat(wavs(ind_nul,:),size(wavs,1),1);
                    wavs = wavs + repmat( (1:size(wavs,2))*0.3,size(wavs,1),1);
                    plot(waves_time,wavs,clr(i));
                    hold on;
                end
                xlim([-0.1 1]);
                set(gca,'ytick',[]);
                
            end
    end
end;

switch record.stim_type
    case 'io'
    case 'pp'
    otherwise
        powerms = powerm;
        if ~iscell(powerms)
            powerms = {powerms};
        end
        for lfpch=1:NUMLFP
            n_conditions = length(measures(lfpch).range{1,1});
            xlabs = cell(1,n_conditions);
            for t = 1:length(powerms)
                name = [record.test ' - Power' triggername{t} ,' LFP # ', num2str(lfpch)];
                powerm = powerms{1,t}{lfpch,1};
                for c=1:n_conditions
                    switch measures(1).variable
                        case 'contrast'
                            xlabs{c} = [num2str(measures(lfpch).range{1,t}(c)*100) '%'];
                        otherwise
                            xlabs{c} = [num2str(measures(lfpch).range{1,t}(c)) '%'];
                    end
                end
                plotpower(name,powerm,xlabs,measures,t,lfpch)
            end % trigger t
            
            
            if length(powerms)==1
                name = [record.test ' - Tuning',' LFP # ',num2str(lfpch)];
                plottuning(name,measures,1,lfpch);
            else
                for t1 = 1:length(powerms)
                    for t2 = t1+1:length(powerms)
                        name = [record.test ' - Power' triggername{t2} ' vs ' triggername{t1}];
                        plottuning(name,measures,[t1 t2],lfpch);
                    end %trigger t2
                end % trigger t1
            end
            
            if isfield(measures,'gamma_KfdM')
                for t = 1:length(powerms)
                    figure('Name',['Complexity, randomness, LFP # ' num2str(lfpch) ' ' triggername{t}],'NumberTitle','off')
                    for b=1:n_bands
                        band = band_names{b};
                        subplot(5,3,3*(b-1)+1);plot(measures(lfpch).range{t},measures(lfpch).([band '_KfdM']){t},'b');title('KFD');ylabel(band)
                        subplot(5,3,3*(b-1)+2);plot(measures(lfpch).range{t},measures(lfpch).([band '_WENTM']){t},'b');title('WENT')
                        subplot(5,3,3*(b-1)+3);plot(measures(lfpch).range{t},measures(lfpch).([band '_DfaM']){t},'b');title('DFA')
                    end;
                end
            end

            
            % figure;
            % for f = 1:length(band_names)
            %     band = band_names{f};
            %     subplot(length(band_names),1,f);
            %     plot(measures.range,squeeze(measures.([band '_power_ers']){1,1}));
            %     title(['ERD/ERS ',band])
            % end;
            
            if isfield(measures,'evoked_crossfreq_post')
                for t = 1:length(powerms)
                    figure('Name',['evoked_crossfreq_post'' LFP # ' num2str(lfpch)],'NumberTitle','off')
                    sij=0;
                    numplot=(length(band_names)^2-length(band_names))/2;
                    for i=1:length(band_names)-1
                        for j=i+1:length(band_names)
                            sij=sij+1;
                            banda = band_names{i};
                            bandb = band_names{j};
                            subplot(numplot,1,sij);plot(measures(lfpch).range{1,t},squeeze(measures(lfpch).evoked_crossfreq_post{1,t}(i,j,:)));
                            title(['crossfrequency dependence (post)',banda,bandb])
                        end
                    end
                end
            end
            
            
            
            if isfield(measures,'evoked_crossfreq_prepost')
                for t = 1:length(powerms)
                    figure('Name',['evoked_crossfreq_prepost'' LFP # ' num2str(lfpch)],'NumberTitle','off')
                    sij=0;
                    numplot=(length(band_names)^2-length(band_names))/2;
                    for i=1:length(band_names)-1
                        for j=i+1:length(band_names)
                            sij=sij+1;
                            banda = band_names{i};
                            bandb = band_names{j};
                            subplot(numplot,1,sij);plot(measures(lfpch).range{1,t},squeeze(measures(lfpch).evoked_crossfreq_prepost{1,t}(i,j,:)));
                            title(['crossfrequency dependence (post-pre)',banda,bandb])
                        end
                    end
                end
            end
            
        end
end
% Col=[0,0,1;1,0,0;0,1,0;.5,.2,0;0,0,0];
% figure;
% for i=1:length(band_names)
%     band = band_names{i};
%     subplot(2,2,i);
%     for c = 1:n_conditions
%         plot(measures.([band '_evoked_time']){1,1}(:,c),'Color',Col(c,:));hold on;
%         title(['event related potential ',band]);
%     end
%     legend('C1 (low)','C2','C3','C4','C5 (high');
% end


evalin('base','global measures');
evalin('base','global analysed_stimulus');
analysed_stimulus = getstimsfile(record);
disp('RESULTS_LFPESTRECORD: Measures available in workspace as ''measures'', stimulus as ''analysed_stimulus''.');



% plot functions

function plottuning(name,measures,triggers,lfpch)
%bandcolors = 'rgcby';
bands = oscillation_bands;
band_names = fields(bands);
n_bands = length(band_names);
triggercolors = 'kbry';
triggernames = {'Off','On'};
powerlim = 1;

if length(measures(lfpch).range{1})<2
    no_variation = true;
else
    no_variation = false;
end

figure('Name',name,'NumberTitle','off')
for t=1:length(triggers)
    for b=1:n_bands
        band = band_names{b};
        
        % evoked power
        subplot(n_bands,3,3*(b-1)+1);
        hold on
        if no_variation
            bar(t,measures(lfpch).([band '_evoked_power']){1,t}(:),triggercolors(t));
            set(gca,'xtick',[1 2]);
            set(gca,'xticklabel',triggernames);
            if b==n_bands
                xlabel('Light');
            end
        else
            plot(measures(lfpch).range{1,t},measures(lfpch).([band '_evoked_power']){1,t}(:),triggercolors(t))
            if b==n_bands
                xlabel(capitalize(measures(1).variable));
            else
                set(gca,'xtick',[]);
            end
            
        end
        
        ylabel(capitalize(band_names{b}));
        if b==1
            title('Evoked power');
        end
        ylim([0 powerlim]);
        
        
        % peak power post
        subplot(n_bands,3,3*(b-1)+2);
        hold on
        if no_variation
            bar(t,measures(lfpch).([band '_peak_power_post']){1,t}(:),triggercolors(t));
            set(gca,'xtick',[1 2]);
            set(gca,'xticklabel',triggernames);
            if b==n_bands
                xlabel('Light');
            end
        else
            plot(measures(lfpch).range{1,t},measures(lfpch).([band '_peak_power_post']){1,t}(:),triggercolors(t))
            if b==n_bands
                xlabel(capitalize(measures(1).variable));
            else
                set(gca,'xticklabel',[]);
            end
        end
        if b==1
            title('Peak power');
        end
        %ylim([0 powerlim]);
        
        % evoked peak freq
        subplot(n_bands,3,3*(b-1)+3);
        hold on
        if no_variation
            bar(t,measures(lfpch).([band '_peak_freq_post']){1,t}(:),triggercolors(t));
            set(gca,'xtick',[1 2]);
            set(gca,'xticklabel',triggernames);
            if b==n_bands
                xlabel('Light');
            end
        else
            plot(measures(lfpch).range{1,t},measures(lfpch).([band '_peak_freq_post']){1,t}(:),triggercolors(t))
        end
        if b==1
            title('Peak frequency');
        end
        if b==n_bands
            xlabel(capitalize(measures(1).variable));
        else
            set(gca,'xtick',[]);
        end
        ylim( bands.(band));
        
    end % band b
end % trigger t


function plotpower(name,powerm,xlabs,measures,t,lfpch)

figure('Name',name,'NumberTitle','off');

bandcolors = 'rgcby';
bands = oscillation_bands;
band_names = fields(bands);

n_conditions = size(powerm.power,3);

clim_min = inf;
clim_max = -inf;

power_min = inf;
power_max = -inf;

increase_min = inf;
increase_max = -inf;

for c=1:n_conditions
    % spectrum
    h.spectrum = subplot(3,n_conditions,c);
    hold on
    surf(powerm.time,powerm.freqs,powerm.power(:,:,c),'EdgeColor','none');
    axis xy; axis tight; view(0,90);
    ylim([0 100])
    
    if c>1
        set(h.spectrum,'YTick',[]);
    else
        ylabel('Frequency (Hz)');
    end
    
    % get limits to make them uniform
    clim = get(gca,'clim');
    if clim(1)<clim_min; clim_min=clim(1);end
    if clim(2)>clim_max; clim_max=clim(2);end
    
    % power curves
    h.power = subplot(3,n_conditions,1*n_conditions+c);
    hold on
    plot(powerm.freqs_pre,powerm.power_pre(:,c),'k')
    plot(powerm.freqs_post,powerm.power_post(:,c),'r')
    xlim([5 90]);
    set(gca,'xscale','log');
    set(gca,'xtick',[ 5 10 20 40 80]);
    xlabel(xlabs{c});
    set(gca,'Yscale','log');
    %ylim([10^-8 10^-2]);
    if c>1
        set(h.power,'YTick',[]);
    else
        ylabel('Power');
    end
    
    % get limits to make them uniform
    yl = ylim;
    if yl(1)<power_min; power_min=yl(1);end
    if yl(2)>power_max; power_max=yl(2);end
    
    % increase
    h.evoked = subplot(3,n_conditions,2*n_conditions+c);
    hold on
    plot([0 100],[1 1],'color',[0.5 0.5 0.5]);
    plot(powerm.freqs,powerm.power_evoked(:,c),'k')
    for f = 1:length(band_names)
        band = band_names{f};
        plot(measures(lfpch).([band '_evoked_peak_freq']){1,t}(c),...
            measures(lfpch).([band '_evoked_peak_power']){1,t}(c),...
            ['o' bandcolors(f)]);
        plot([min(bands.(band)) max(bands.(band)) ], ...
            [measures(lfpch).([band '_evoked_power']){1,t}(:,c) measures(lfpch).([band '_evoked_power']){1,t}(:,c)],bandcolors(f))
    end
    xlim([5 90]);
    set(gca,'xscale','log');
    set(gca,'xtick',[ 5 10 20 40 80]);
    %set(h.evoked,'Yscale','log')
    if c>1
        set(h.evoked,'YTick',[]);
    else
        %        set(h.evoked,'YTick',[1 2 4]);
        ylabel('Relative increase');
    end
    
    xlabel(xlabs{c});
    
    % get limits to make them uniform
    yl = ylim;
    if yl(1)<increase_min; increase_min=yl(1);end
    if yl(2)>increase_max; increase_max=yl(2);end
    
    
end % conditions

for c=1:n_conditions
    subplot(3,n_conditions,c);
    set(gca,'clim',[clim_min clim_max]);
    subplot(3,n_conditions,c+n_conditions);
    ylim([power_min power_max]);
    subplot(3,n_conditions,c+2*n_conditions);
    ylim([increase_min increase_max]);
end
