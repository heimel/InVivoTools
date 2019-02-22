function perfplots(exp)

% Makes performance figures for mice 14.13 group 2 and 172002
% works in 2016a
% Azadeh October 2017

switch exp
    case 14.13
        mice = {
            '14.13.2.01', '14.13.2.02'...
            '14.13.2.03', '14.13.2.04'...
            '14.13.2.05', '14.13.2.06'...
            '14.13.2.07', '14.13.2.08'...
            '14.13.2.09', '14.13.2.10'...
            '14.13.2.11', '14.13.2.12'...
            '14.13.2.15', '14.13.2.14'...
            };
        n_mice = length(mice);
        
        mean_dur = NaN(1, 30, 2, n_mice);
        % val_pos_theta = NaN(200,n_mice);
        % val_head_theta = NaN(200,n_mice);
        
        for i = 14
            %     1:n_mice
            subj = mice(i);
            exp = 14.13;
            manualfrzdata(subj, exp)
            
            if exist (['man_frz_dur_14.13.2.0' num2str(i) '.mat'], 'file')~= 0
                load(['man_frz_dur_14.13.2.0' num2str(i) '.mat']);
            elseif exist (['man_frz_dur_14.13.2.' num2str(i) '.mat'], 'file')~= 0
                load(['man_frz_dur_14.13.2.' num2str(i) '.mat']);
                
                if exist (['pos_theta_14.13.2.0' num2str(i) '.mat'], 'file')~= 0
                    load(['pos_theta_14.13.2.0' num2str(i) '.mat']);
                elseif exist (['pos_theta_14.13.2.' num2str(i) '.mat'], 'file')~= 0
                    load(['pos_theta_14.13.2.' num2str(i) '.mat']);
                else
                    errormsg('Angle file does not exist. Get angle data from manualfrzdata.m');
                end
                if exist (['head_theta_14.13.2.0' num2str(i) '.mat'], 'file')~= 0
                    load(['head_theta_14.13.2.0' num2str(i) '.mat'])
                elseif exist (['head_theta_14.13.2.' num2str(i) '.mat'], 'file')~= 0
                    load(['head_theta_14.13.2.' num2str(i) '.mat'])
                else
                    errormsg('Head angle file does not exist. Get angle data from manualfrzdata.m');
                end
                
            else
                errormsg('Freeze duration file does not exist. Get data from manualfrzdata.m');
            end
            
            in_trials =  man_frz_dur((1:23),:,:); %#ok<*NODEF> %dimensions: trial, day, stim
            mean_dur(:,:,:,(i)) = nanmean(in_trials);
            if i == max(i)
                save (['meanduration_14.13.2.' num2str(i) '.mat'], 'mean_dur') % dimentions: 1, days, stimuli, mice
            end
            
            for j = 1:numel(in_trials)
                if ~isnan(in_trials(j)) && in_trials(j)> 0
                    in_trials(j) = 1;
                end
            end
            
            perf = nanmean(in_trials);
            perf_col = reshape(perf,[30,2]);
            ses_num = sum(~isnan(perf_col));
            save (['performance_14.13.2.' num2str(i) '.mat'], 'perf_col')
            figure(i);
            my_colours;
            hab_only_trials = perf_col(1:5,1);
            a = bar(hab_only_trials, 'FaceColor', my_burlywood,...
                'edgecolor', grey_30, 'barwidth', 0.3);
            hold on
            b = plot(mean_dur(:,1:5,1,i), '-.h', 'color',my_peru, 'linewidth', 1.2);
%             if any(~isnan(perf_col(:,2)))
%                 bhand_perf = bar(perf_col);
%                 set(bhand_perf(1),'FaceColor',my_burlywood, 'edgecolor', grey_30);
%                 set(bhand_perf(2),'FaceColor',my_turquoiseblue, 'edgecolor', grey_30);
%             else
%                 bhand_perf = bar(perf_col(:,1));
%                 set(bhand_perf,'FaceColor',my_burlywood, 'edgecolor', 'none');
%             end
%             
            ylim([0, 1])
            %     ax1 = gca;
            %     ax1.YTick = 0:0.05:1;
            %     ax1.YGrid = 'on';
            %     ax1.GridLineStyle = ':';
%             xlim([0 max(ses_num)+1]);
            box off
            title(['Hawk vs Disc mouse 2.' num2str(i)], 'FontSize', 18);
            ylabel('Propotion freezing', 'FontSize', 18);
            xlabel('Time(sessions)', 'FontSize', 18);
            hold on
            yyaxis 'right';
%             phand_dur = plot(mean_dur(:,:,1,i), '-.h', 'color',my_peru, 'linewidth', 1.2);
            ax2 = gca;
            ax2.YColor = 'k';
            ylim(ax2,[0 1]);
            ylabel('freezing duration(s)', 'FontSize', 18);
            legend([a(1),b],'habituating stim', 'mean freezing duration');
%             legend([bhand_perf(1),phand_dur],'hab', 'mean dur hab');
            legend('boxoff');
%             
%             if any(~isnan(mean_dur(:,:,2,i)))
%                 plot(mean_dur(:,:,2,i), '-.*', 'color',my_darkturquoise, 'linewidth', 1.2);
%                 legend('hab','novel', '\mu dur hab', '\mu dur nov');
%                 legend('boxoff');
%             end
        end
 
        
        %     frz_trial_ind = find(in_trials~=0 & isnan(in_trials)==0);
        %     tot_head_theta = head_theta((1:23),:,:);
        %     tot_pos_theta = pos_theta((1:23),:,:);
        %     in_pos_theta = tot_pos_theta(frz_trial_ind);
        %     in_head_theta = tot_head_theta(frz_trial_ind);
        %
        %     for l= 1:300
        %         if tot_pos_theta(frz_trial_ind)==0
        %             in_pos_theta(l) = tot_pos_theta(frz_trial_ind(l));
        %         end
        %         if tot_head_theta(frz_trial_ind)==0
        %             in_head_theta(l) = tot_head_theta(frz_trial_ind(l));
        %         end
        %     end
        
        %   %% angles
        %     for k = 1:numel(in_pos_theta)
        %         angle = ~isnan(in_pos_theta{k,1});
        %         if ~isempty(in_pos_theta{k,1}(angle)) && sum(angle) <= 1
        %             val_pos_theta(k,i) = in_pos_theta{k,1}(angle);
        %         elseif sum(angle) > 1
        %             disp('check the angles manually, taking first entry here')
        %             ddd = in_pos_theta{k,1}(angle);
        %             val_pos_theta(k,i) = ddd(1);
        %         else
        %             val_pos_theta(k,i) = NaN;
        %         end
        %     end
        % % Position angles
        %     Nbins = histcounts(val_pos_theta(:,i),(20:21:numel(val_pos_theta)));
        %    for o = 1:numel(find(Nbins))
        %     if o == 1
        %        indz = frz_trial_ind(1:Nbins(o));
        %     else
        %     indz = frz_trial_ind((Nbins(o-1)+1):(Nbins(o)+Nbins(o-1)));
        %     end
        %     if numel(indz) >= 4
        %     fl_indz = [indz(1:4), indz(end-3:end)];
        %     fl_angles = val_pos_theta(fl_indz);
        %     figure
        %     subplot(1,2,1)
        %     rose(degtorad(fl_angles(:,1)))
        % %     title(['First four freeze angles mouse 2.0' num2str(i) ', day ' num2str(d)])
        %     subplot(1,2,2)
        %     rose(degtorad(fl_angles(:,2)))
        %     else
        %         fl_indz = indz;
        %     fl_angles = val_pos_theta(fl_indz);
        %     figure
        %     rose(degtorad(fl_angles(:,1)))
        %     end
        %    end
        % % head angles
        %     for m = 1:numel(in_head_theta)
        %         h_angle = ~isnan(in_head_theta{m,1});
        %         if ~isempty(in_head_theta{m,1}(h_angle)) && sum(h_angle) <= 1
        %             val_head_theta(m,i) = in_head_theta{m,1}(h_angle);
        %         elseif sum(h_angle) > 1
        %             disp('check the angles manually, taking first entry here')
        %             dddd = in_head_theta{m,1}(h_angle);
        %             val_head_theta(m,i) = dddd(1);
        %         else
        %             val_head_theta(m,i) = NaN;
        %         end
        %     end
    case 172002
        mice = {
            '172002.1.01', '172002.1.02'...
            '172002.1.03', '172002.1.04'...
            '172002.1.05', '172002.1.06'...
            '172002.1.07', '172002.1.08'...
            '172002.1.09', '172002.1.10'...
            '172002.1.11', '172002.1.12'...
            '172002.1.13', '172002.1.14'...
            '172002.1.15', '172002.1.16'...
            '172002.1.17', '172002.1.18'...
            '172002.1.19', '172002.1.20'...
            '172002.1.21', '172002.1.22'...
            '172002.1.23', '172002.1.24'...
            '172002.1.25', '172002.1.26'...
            '172002.1.27', '172002.1.28'...
            '172002.1.29', '172002.1.30'...
            '172002.1.31', '172002.1.32'...
            };
        n_mice = length(mice);
        
        mean_dur = NaN(1, 30, 2, n_mice);
        % val_pos_theta = NaN(200,n_mice);
        % val_head_theta = NaN(200,n_mice);
        
        for i = 13
            
%             1:n_mice
            i
            %     1:n_mice
            subj = mice(i);
            exp = 172002.1;
            manualfrzdata(subj, exp)
            
            if exist (['man_frz_dur_172002.1.0' num2str(i) '.mat'], 'file')~= 0
                load(['man_frz_dur_172002.1.0' num2str(i) '.mat']);
            elseif exist (['man_frz_dur_172002.1.' num2str(i) '.mat'], 'file')~= 0
                load(['man_frz_dur_172002.1.' num2str(i) '.mat']);
                
                if exist (['pos_theta_172002.1.0' num2str(i) '.mat'], 'file')~= 0
                    load(['pos_theta_172002.1.0' num2str(i) '.mat']);
                elseif exist (['pos_theta_172002.1.' num2str(i) '.mat'], 'file')~= 0
                    load(['pos_theta_172002.1.' num2str(i) '.mat']);
                else
                    errormsg('Angle file does not exist. Get angle data from manualfrzdata.m');
                end
                if exist (['head_theta_172002.1.0' num2str(i) '.mat'], 'file')~= 0
                    load(['head_theta_172002.1.0' num2str(i) '.mat'])
                elseif exist (['head_theta_172002.1.' num2str(i) '.mat'], 'file')~= 0
                    load(['head_theta_172002.1.' num2str(i) '.mat'])
                else
                    errormsg('Head angle file does not exist. Get angle data from manualfrzdata.m');
                end
                
            else
                errormsg('Freeze duration file does not exist. Get data from manualfrzdata.m');
                continue
            end
            
            in_trials = man_frz_dur((1:23),:,:); %dimensions: trial, day, stim
            mean_dur(:,:,:,(i)) = nanmean(in_trials);
            
            for j = 1:numel(in_trials)
                if ~isnan(in_trials(j)) && in_trials(j)> 0
                    in_trials(j) = 1;
                end
            end
            
            perf = nanmean(in_trials);
            perf_col = reshape(perf,[30,2]);
            ses_num = find(~isnan(perf_col(:,1)), 1, 'last' );
%             ses_num = sum(~isnan(perf_col));
            save (['performance_172002.1.' num2str(i) '.mat'], 'perf_col')
            
            my_colours;
            
            figure(i);
            
            if any(~isnan(perf_col(:,2)))
                bhand_perf = bar(perf_col);
                set(bhand_perf(1),'FaceColor',my_burlywood, 'edgecolor', grey_30);
                set(bhand_perf(2),'FaceColor',my_turquoiseblue, 'edgecolor', grey_30);
            else
                bhand_perf = bar(perf_col(:,1));
                set(bhand_perf,'FaceColor',my_burlywood, 'edgecolor', grey_30);
            end
            
            ylim([0, 1.1])
            %     ax1 = gca;
            %     ax1.YTick = 0:0.05:1;
            %     ax1.YGrid = 'on';
            %     ax1.GridLineStyle = ':';
            xlim([0 max(ses_num)+1]);
            box off
            title(['Ellipse vs Disc, mouse 172002.1.0' num2str(i)], 'FontSize', 18);
            ylabel('Propotion freezing', 'FontSize', 18);
            xlabel('Time(sessions)', 'FontSize', 18);
            hold on
            yyaxis 'right';
            phand_dur = plot(mean_dur(:,:,1,i), '-.h', 'color',my_peru, 'linewidth', 1.2);
            ax2 = gca;
            ax2.YColor = 'k';
            ylim(ax2,[0 2.1]);
            ylabel('freezing duration(s)');
            legend([bhand_perf(1),phand_dur],'hab', '\mu dur hab', 'FontSize', 18);
            legend('boxoff');
            
            if any(~isnan(mean_dur(:,:,2,i)))
                plot(mean_dur(:,:,2,i), '-.*', 'color',my_darkturquoise, 'linewidth', 1.2);
                legend('hab','novel', '\mu dur hab', '\mu dur nov');
                legend('boxoff');
            end
        end
        
        %     frz_trial_ind = find(in_trials~=0 & isnan(in_trials)==0);
        %     tot_head_theta = head_theta((1:23),:,:);
        %     tot_pos_theta = pos_theta((1:23),:,:);
        %     in_pos_theta = tot_pos_theta(frz_trial_ind);
        %     in_head_theta = tot_head_theta(frz_trial_ind);
        %
        %     for l= 1:300
        %         if tot_pos_theta(frz_trial_ind)==0
        %             in_pos_theta(l) = tot_pos_theta(frz_trial_ind(l));
        %         end
        %         if tot_head_theta(frz_trial_ind)==0
        %             in_head_theta(l) = tot_head_theta(frz_trial_ind(l));
        %         end
        %     end
        
        %   %% angles
        %     for k = 1:numel(in_pos_theta)
        %         angle = ~isnan(in_pos_theta{k,1});
        %         if ~isempty(in_pos_theta{k,1}(angle)) && sum(angle) <= 1
        %             val_pos_theta(k,i) = in_pos_theta{k,1}(angle);
        %         elseif sum(angle) > 1
        %             disp('check the angles manually, taking first entry here')
        %             ddd = in_pos_theta{k,1}(angle);
        %             val_pos_theta(k,i) = ddd(1);
        %         else
        %             val_pos_theta(k,i) = NaN;
        %         end
        %     end
        % % Position angles
        %     Nbins = histcounts(val_pos_theta(:,i),(20:21:numel(val_pos_theta)));
        %    for o = 1:numel(find(Nbins))
        %     if o == 1
        %        indz = frz_trial_ind(1:Nbins(o));
        %     else
        %     indz = frz_trial_ind((Nbins(o-1)+1):(Nbins(o)+Nbins(o-1)));
        %     end
        %     if numel(indz) >= 4
        %     fl_indz = [indz(1:4), indz(end-3:end)];
        %     fl_angles = val_pos_theta(fl_indz);
        %     figure
        %     subplot(1,2,1)
        %     rose(degtorad(fl_angles(:,1)))
        % %     title(['First four freeze angles mouse 2.0' num2str(i) ', day ' num2str(d)])
        %     subplot(1,2,2)
        %     rose(degtorad(fl_angles(:,2)))
        %     else
        %         fl_indz = indz;
        %     fl_angles = val_pos_theta(fl_indz);
        %     figure
        %     rose(degtorad(fl_angles(:,1)))
        %     end
        %    end
        % % head angles
        %     for m = 1:numel(in_head_theta)
        %         h_angle = ~isnan(in_head_theta{m,1});
        %         if ~isempty(in_head_theta{m,1}(h_angle)) && sum(h_angle) <= 1
        %             val_head_theta(m,i) = in_head_theta{m,1}(h_angle);
        %         elseif sum(h_angle) > 1
        %             disp('check the angles manually, taking first entry here')
        %             dddd = in_head_theta{m,1}(h_angle);
        %             val_head_theta(m,i) = dddd(1);
        %         else
        %             val_head_theta(m,i) = NaN;
        %         end
        %     end

        case 172005
        mice = {
            '172005.1.01', '172005.1.02'...
%             '172002.1.03', '172002.1.04'...
%             '172002.1.05', '172002.1.06'...
%             '172002.1.07', '172002.1.08'...
            
            };
        n_mice = length(mice);
        
        mean_dur = NaN(1, 30, 2, n_mice);
        % val_pos_theta = NaN(200,n_mice);
        % val_head_theta = NaN(200,n_mice);
        
        for i = 1:n_mice
            i
            %     1:n_mice
            subj = mice(i);
            exp = 172005.1;
            manualfrzdata(subj, exp)
            
            if exist (['man_frz_dur_172005.1.0' num2str(i) '.mat'], 'file')~= 0
                load(['man_frz_dur_172005.1.0' num2str(i) '.mat']);
            elseif exist (['man_frz_dur_172005.1.' num2str(i) '.mat'], 'file')~= 0
                load(['man_frz_dur_172005.1.' num2str(i) '.mat']);
                
                if exist (['pos_theta_172005.1.0' num2str(i) '.mat'], 'file')~= 0
                    load(['pos_theta_172005.1.0' num2str(i) '.mat']);
                elseif exist (['pos_theta_172005.1.' num2str(i) '.mat'], 'file')~= 0
                    load(['pos_theta_172005.1.' num2str(i) '.mat']);
                else
                    errormsg('Angle file does not exist. Get angle data from manualfrzdata.m');
                end
                if exist (['head_theta_172005.1.0' num2str(i) '.mat'], 'file')~= 0
                    load(['head_theta_172005.1.0' num2str(i) '.mat'])
                elseif exist (['head_theta_172005.1.' num2str(i) '.mat'], 'file')~= 0
                    load(['head_theta_172005.1.' num2str(i) '.mat'])
                else
                    errormsg('Head angle file does not exist. Get angle data from manualfrzdata.m');
                end
                
            else
                errormsg('Freeze duration file does not exist. Get data from manualfrzdata.m');
                continue
            end
            
            in_trials = man_frz_dur((1:23),:,:); %dimensions: trial, day, stim
            mean_dur(:,:,:,(i)) = nanmean(in_trials);
            
            for j = 1:numel(in_trials)
                if ~isnan(in_trials(j)) && in_trials(j)> 0
                    in_trials(j) = 1;
                end
            end
            
            perf = nanmean(in_trials);
            perf_col = reshape(perf,[30,2]);
            ses_num = sum(~isnan(perf_col));
            save (['performance_172005.1.' num2str(i) '.mat'], 'perf_col')
            figure(i);
            
            if any(~isnan(perf_col(:,2)))
                bhand_perf = bar(perf_col);
                set(bhand_perf(1),'FaceColor',[0.4 0.0 0.4], 'edgecolor', 'none');
                set(bhand_perf(2),'FaceColor',[0.2 0.6 0.4], 'edgecolor', 'none');
            else
                bhand_perf = bar(perf_col(:,1));
                set(bhand_perf,'FaceColor',[0.4 0.0 0.4], 'edgecolor', 'none');
            end
            
            ylim([0, 1.1])
            %     ax1 = gca;
            %     ax1.YTick = 0:0.05:1;
            %     ax1.YGrid = 'on';
            %     ax1.GridLineStyle = ':';
            xlim([0 max(ses_num)+1]);
            box off
            title(['Hawk vs Disc, sSC inhibition, 172005.1.0' num2str(i)]);
            ylabel('Propotion freezing');
            xlabel('Time(sessions)');
            hold on
            yyaxis 'right';
            phand_dur = plot(mean_dur(:,:,1,i), '-.h', 'color',[0.6 0.0 0.6], 'linewidth', 1.2);
            ax2 = gca;
            ax2.YColor = 'k';
            ylim(ax2,[0 2.1]);
            ylabel('freezing duration(s)');
            legend([bhand_perf(1),phand_dur],'hab', '\mu dur hab');
            legend('boxoff');
            
            if any(~isnan(mean_dur(:,:,2,i)))
                plot(mean_dur(:,:,2,i), '-.*', 'color',[0.4 0.8 0.6], 'linewidth', 1.2);
                legend('hab','novel', '\mu dur hab', '\mu dur nov');
                legend('boxoff');
            end
        end
end

