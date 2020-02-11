function [p_hawk, p_disc, p_all, p_comp_all] = allmicemean(exp)
%% Draws the bar plots of the data from group 2 mice 14.13 and 172002
% with the significance stars
% Azadeh September 2017
%
% might need to be preceded by call to MANUALFRZDATA
%
% 2019, pathchange by Alexander, adapted to octave

pathstr =fileparts(mfilename('fullpath'));
curdir = pwd;
cd(fullfile(pathstr,'Data'));

switch exp
    case 14.13
        for i = 1:14
            if exist (['performance_14.13.2.' num2str(i) '.mat'], 'file')~= 0
                load(['performance_14.13.2.' num2str(i) '.mat']);
            else
                errormsg('Freeze duration file does not exist. Get data from manualfrzdata.m');
            end
            hab_first(i) = perf_col(1,1);  %#ok<*AGROW>
            
            for j = 1:30
                if ~isnan(perf_col(j,2)) == 1
                    nov_first(i) = perf_col(j,2);
                    hab_2stim(i) = perf_col(j,1);
                    hab_last(i) = perf_col(j-1,1);
                    break
                else
                    hab_only_trials(j,i) = perf_col(j,1);
                end
            end
        end
        hab_first = hab_first*100;
        hab_last = hab_last*100;
        hab_2stim = hab_2stim*100;
        nov_first = nov_first*100;
        
        all_perfs = [hab_first; hab_last; hab_2stim; nov_first];
        
        m = 0;
        for k = 1:14
            if mod(k,2) == 0
                disc_first_perfs(:,k-m) = all_perfs(:,k);
                disc_hab_only(:,k-m) = hab_only_trials(:,k);
            else
                hawk_first_perfs(:,k-m) = all_perfs(:,k);
                hawk_hab_only(:,k-m) = hab_only_trials(:,k);
                m = m+1;
            end
        end
        %         disc_first_perfs = disc_first_perfs*100;
        %         hawk_first_perfs = hawk_first_perfs*100;
        %         disc_hab_only = disc_hab_only*100;
        %         hawk_hab_only = hawk_hab_only*100;
        
        % This bit determines the look of the graphs
        my_colours;
        bar_dist = [1:0.2:1.6]; % [1:0.5:2.5]
        bar_gap = diff(bar_dist);
        bar_specs = struct('FaceColor', 'flat', 'edgecolor', grey_30,...
            'LineWidth', 2, 'barwidth', 0.8);
        bar_col = [my_burlywood;my_burlywood;my_burlywood;my_turquoiseblue];

        er_specs = struct('Marker', '.','color', grey_30, 'LineWidth', 2);
        if ~isoctave
            er_specs.YNegativeDelta = [];
        end

        
        % calculate groups for sig star function
        groups = {[bar_dist(1), bar_dist(2)],[bar_dist(1), bar_dist(3)],...
            [bar_dist(2), bar_dist(3)], [bar_dist(3), bar_dist(4)]};
        
        x_label_str = 'Sessions';
        y_label_str = 'Freezing (%)';
        x_ax_st = struct('XTickLabel', [1,5,6,6], 'Xcolor',grey_30,...
            'Ycolor', grey_30,'LineWidth',3, 'FontName', 'Myriad Pro',...
            'FontWeight','normal', 'FontSize', 20);
        y_ax_st = struct('YTick',[10:20:100],'YTickLabel', [10:20:100],...
            'TickDir', 'out');
        title_specs = struct('FontName', 'Myriad Pro','FontSize', 10);
        y_lim = [0 100];
        x_lim = [bar_dist(1)-(bar_gap(1)*(3/4)), bar_dist(end)+(bar_gap(1)*(3/4))]; % xlim([0.75 2.75])
        
        %% hawk first mice
        [~,p_hawk_hab_first2last,ci,stats] = ttest(hawk_first_perfs(1,:),hawk_first_perfs(2,:)); %#ok<*ASGLU>
        [~,p_hawk_hab_first2stim,ci,stats] = ttest(hawk_first_perfs(1,:),hawk_first_perfs(3,:));
        [~,p_hawk_hablast_nov,ci,stats] = ttest(hawk_first_perfs(2,:),hawk_first_perfs(4,:));
        [~,p_hawk_hab2stim_nov,ci,stats] = ttest(hawk_first_perfs(3,:),hawk_first_perfs(4,:));
        [~,p_hawk_hab_last2stim,ci,stats] = ttest(hawk_first_perfs(2,:),hawk_first_perfs(3,:));
        [~,p_hawk_hab_first_nov_first,ci,stats] = ttest(hawk_first_perfs(1,:),hawk_first_perfs(4,:));
        
        p_hawk = [p_hawk_hab_first2last,p_hawk_hab_first2stim,p_hawk_hablast_nov,...
            p_hawk_hab2stim_nov,p_hawk_hab_last2stim,p_hawk_hab_first_nov_first];
        
        mean_hawk_first_days = mean(hawk_first_perfs,2);
        sem_hawk_first_days = sem(hawk_first_perfs,2);
        
        
        fig = figure;
        %         hold on
        
        subplot(1,3,1)
        
        han = bar(bar_dist,mean_hawk_first_days);
        set(han,bar_specs);
        if ~isoctave
            han.CData = bar_col;
        end
        
        % works in Matlab 2014
        %         for i = 1:2
        %             if i == 1
        %                 han(i) = bar(bar_dist,mean_hawk_first_days);
        %                 set(han(i),'FaceColor', my_burlywood, 'edgecolor', grey_30, 'LineWidth',2, 'barwidth', 0.4);
        %             else
        %                 han(i) = bar(bar_dist(4), mean_hawk_first_days(4));
        %                 set(han(i),'FaceColor', my_turquoiseblue, 'edgecolor', grey_30, 'LineWidth',2,  'barwidth', 0.2);
        %             end
        %         end
        
        
        hold on
        
        er_hawk = errorbar(bar_dist,mean_hawk_first_days,sem_hawk_first_days, 'o');
        set(er_hawk,er_specs);
        
        % individual mice data points
        for i = 1:length(mean_hawk_first_days)
            plot_points(bar_dist(i),hawk_first_perfs(i,:),3);
        end
        
        % To show the t-test stars of all possible comparisons
        star_hand_hawk = sigstar(groups,[p_hawk_hab_first2last,...
            p_hawk_hab_first2stim,p_hawk_hablast_nov,p_hawk_hab2stim_nov]);
        
        % To show the t-test stars of all possible comparisons
        % groups = {[1,2],[1,3],[2,4],[3,4],[2,3],[1,4]};
        % star_hand_hawk = sigstar(groups,[p_hawk_hab_first2last,p_hawk_hab_first2stim,p_hawk_hablast_nov,p_hawk_hab2stim_nov,p_hawk_hab_last2stim,p_hawk_hab_first_nov_first]);
        % star_hand_hawk(2,1) = star_hand_hawk(1,1)
        
        box off
        ti = title('Mean response, hawk first'); % 'Mean response of 7 mice, hawk first'
        set(ti,title_specs);
        ylabel(y_label_str)
        xlabel(x_label_str)
        ylim(y_lim)
        xlim(x_lim)
        
        %         legend({'hawk','disc'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30);
        %         legend('boxoff')
        
        ax_hawk = gca;
        set(ax_hawk,'XTick',bar_dist);
        set(gca, x_ax_st);
        set(gca, y_ax_st);
        if ~isoctave
            ytickangle(45)
        end
        %         set(fig, 'position', [360 171 396 751])
        
        hold off
        
        
        %% disc first mice
        [h,p_disc_hab_first2last,ci,stats]=ttest(disc_first_perfs(1,:),disc_first_perfs(2,:));
        [h,p_disc_hab_first2stim,ci,stats]=ttest(disc_first_perfs(1,:),disc_first_perfs(3,:));
        [h,p_disc_hablast_nov,ci,stats]=ttest(disc_first_perfs(2,:),disc_first_perfs(4,:));
        [h,p_disc_hab2stim_nov,ci,stats]=ttest(disc_first_perfs(3,:),disc_first_perfs(4,:));
        [h,p_disc_hab_last2stim,ci,stats]=ttest(disc_first_perfs(2,:),disc_first_perfs(3,:));
        [h,p_disc_hab_first_nov_first,ci,stats]=ttest(disc_first_perfs(1,:),disc_first_perfs(4,:));
        
        p_disc = [p_disc_hab_first2last,p_disc_hab_first2stim,p_disc_hablast_nov,...
            p_disc_hab2stim_nov,p_disc_hab_last2stim,p_disc_hab_first_nov_first];
        
        mean_disc_first_days = mean(disc_first_perfs,2);
        sem_disc_first_days = sem(disc_first_perfs,2);
        
        %         fig = figure;
        %         hold on
        subplot(1,3,2)
        
        han = bar(bar_dist,mean_disc_first_days);
        set(han,bar_specs);
        if ~isoctave
            han.CData = bar_col;
        end
        % works in Matlab 2014
        %         for i = 1:2
        %             if i == 1
        %                 han(i) = bar(bar_dist,mean_disc_first_days);
        %                 set(han(i),'FaceColor', my_burlywood, 'edgecolor', grey_30,...
        %                     'LineWidth',2, 'barwidth', 0.4);
        %             else
        %                 han(i) = bar(bar_dist(4), mean_disc_first_days(4));
        %                 set(han(i),'FaceColor', my_turquoiseblue, 'edgecolor', grey_30,...
        %                     'LineWidth',2,  'barwidth', 0.2);
        %             end
        %         end
        
        hold on
        
        er_disc = errorbar(bar_dist,mean_disc_first_days,sem_disc_first_days,'.');
        set(er_disc,er_specs);
        
        % individual mice data points
        for i = 1:length(mean_disc_first_days)
            plot_points(bar_dist(i),disc_first_perfs(i,:),3);
        end
        
        % To show the t-test stars of all possible comparisons
        star_hand_disc = sigstar(groups,[p_disc_hab_first2last,...
            p_disc_hab_first2stim,p_disc_hablast_nov,p_disc_hab2stim_nov]);
        
        % To show the t-test stars of all possible comparisons
        % groups = {[1,2],[1,3],[2,4],[3,4],[2,3],[1,4]};
        % star_hand_disc = sigstar(groups,[p_disc_hab_first2last,p_disc_hab_first2stim,p_disc_hablast_nov,p_disc_hab2stim_nov,p_disc_hab_last2stim,p_disc_hab_first_nov_first]);
        % star_hand_disc(2,1) = star_hand_disc(1,1)
        
        box off
        ti = title('Disc first'); % 'Mean response of 7 mice, disc first'
        set(ti,title_specs);
        %         ylabel(y_label_str)
        xlabel(x_label_str)
        ylim(y_lim)
        xlim(x_lim)
        
        ax_hawk = gca;
        set(ax_hawk,'XTick',bar_dist);
        set(gca, x_ax_st);
        set(gca, y_ax_st);
        if ~isoctave
            ytickangle(45)
        end
        
        %         legend({'disc','hawk'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30);
        %         legend('boxoff')
        
        %         set(fig, 'position', [360 171 396 751])
        
        
        hold off
        
        %% all mice
        [h,p_hab_first2last,ci,stats]=ttest(hab_first,hab_last);
        [h,p_hab_first2stim,ci,stats]=ttest(hab_first,hab_2stim);
        [h,p_hablast_nov,ci,stats]=ttest(hab_last,nov_first);
        [h,p_hab2stim_nov,ci,stats]=ttest(hab_2stim,nov_first);
        [h,p_hab_last2stim,ci,stats]=ttest(hab_last,hab_2stim);
        [h,p_hab_first_nov_first,ci,stats]=ttest(hab_first,nov_first);
        
        p_all = [p_hab_first2last,p_hab_first2stim,p_hablast_nov,p_hab2stim_nov,...
            p_hab_last2stim,p_hab_first_nov_first];
        
        mean_all_days = mean(all_perfs,2);
        sem_all_days = sem(all_perfs,2);
        
        %         fig = figure;
        %         hold on
        
        subplot(1,3,3)
        han = bar(bar_dist,mean_all_days);
        set(han, bar_specs);
        if ~isoctave
            han.CData = bar_col;
        end
        % works in Matlab 2014
        %         for i = 1:2
        %             if i == 1
        %                 han(i) = bar(bar_dist,mean_all_days);
        %                 set(han(i),'FaceColor', my_burlywood, 'edgecolor', grey_30, 'LineWidth',2, 'barwidth', 0.4);
        %             else
        %                 han(i) = bar(bar_dist(4), mean_all_days(4));
        %                 set(han(i),'FaceColor', my_turquoiseblue, 'edgecolor', grey_30, 'LineWidth',2,  'barwidth', 0.2);
        %             end
        %         end
        
        
        hold on
        
        er = errorbar(bar_dist,mean_all_days,sem_all_days,'.');
        set(er, er_specs);
        
        % individual mice data points
        for i = 1:length(mean_all_days)
            plot_points(bar_dist(i),all_perfs(i,:),3);
        end
        
        % draw comparison bars and significance stars
        star_hand = sigstar(groups,[p_hab_first2last,p_hab_first2stim,...
            p_hablast_nov,p_hab2stim_nov]); %#ok<*NASGU>
        
        % To show the t-test stars of all possible comparisons
        % groups = {[1,2],[1,3],[2,4],[3,4],[2,3],[1,4]};
        % star_hand = sigstar(groups,[p_hab_first2last,p_hab_first2stim,p_hablast_nov,p_hab2stim_nov,p_hab_last2stim,p_hab_first_nov_first]);
        % star_hand(2,1) = star_hand(1,1)
        
        box off
        ti = title('14 mice'); % 'Mean response of 14 mice'
        set(ti,title_specs);
        %         ylabel(y_label_str)
        xlabel(x_label_str)
        ylim(y_lim)
        xlim(x_lim)
        
        ax_hawk = gca;
        set(ax_hawk,'XTick',bar_dist);
        set(gca, x_ax_st);
        set(gca, y_ax_st);
        if ~isoctave
            ytickangle(45)
        end
        %         leg = legend(han,{'habituating','novel'},'FontName', 'Myriad Pro',...
        %             'FontSize',15,'FontWeight','normal', 'Textcolor', grey_30);
        %         legend('boxoff')
        
        %         set(fig, 'position', [360 171 396 751])
        hold off
        
        %% comparison between hawk first and disc first
        
        comp_data = [mean_disc_first_days, mean_hawk_first_days];
        sem_comp = [sem_disc_first_days, sem_hawk_first_days];
        
        [h,p_hab_first_d2h,ci,stats]=ttest(disc_first_perfs(1,:),hawk_first_perfs(1,:));
        [h,p_hab_last_d2h,ci,stats]=ttest(disc_first_perfs(2,:),hawk_first_perfs(2,:));
        [h,p_hab_2stim_d2h,ci,stats]=ttest(disc_first_perfs(3,:),hawk_first_perfs(3,:));
        [h,p_nov_d2h,ci,stats]=ttest(disc_first_perfs(4,:),hawk_first_perfs(4,:));
        p_comp_all = [p_hab_first_d2h,p_hab_last_d2h,p_hab_2stim_d2h,p_nov_d2h];
        
        figure;
        hold on
        for i = 1:length(comp_data)
            %             for i = 1
            han_comp(i) = bar(i-0.1429, comp_data(i,1)); %#ok<*SAGROW>
            if i<length(comp_data)
                set(han_comp(i),'FaceColor', my_burlywood, 'edgecolor', grey_30, 'LineWidth',2, 'barwidth', 0.2);
            else
                set(han_comp(i),'FaceColor', my_turquoiseblue, 'edgecolor', grey_30, 'LineWidth',2,  'barwidth', 0.2);
            end
            han_comp(i+length(comp_data)) = bar(i+0.1429, comp_data(i,2));
            if i<length(comp_data)
                set(han_comp(i+length(comp_data)),'FaceColor', my_wheat, 'edgecolor', grey_30, 'LineWidth',2, 'barwidth', 0.2);
            else
                set(han_comp(i+length(comp_data)),'FaceColor', my_lightturquoise, 'edgecolor', grey_30, 'LineWidth',2,  'barwidth', 0.2);
            end
        end
        % legend(han_comp([3:5 8]))
        % Finding the number of groups and the number of bars in each group
        ngroups = size(comp_data, 1);
        nbars = size(comp_data, 2);
        % Calculating the width for each bar group
        groupwidth = min(0.8, nbars/(nbars + 1.5));
        % Set the position of each error bar in the centre of the main bar
        % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
        for i = 1:nbars
            % Calculate center of each bar
            x_comp = ((1:ngroups) - groupwidth/2) + (2*i-1) * groupwidth / (2*nbars);
            er_comp = errorbar(x_comp, comp_data(:,i), sem_comp(:,i), 'linestyle', 'none');
            er_comp.Color = grey_30;
            er_comp.LineWidth = 2;
            sig_groups(i,(1:ngroups)) = x_comp;
        end
        
        plot_points(sig_groups(1,1),disc_first_perfs(1,:),3);
        plot_points(sig_groups(2,1),hawk_first_perfs(1,:),3);
        plot_points(sig_groups(1,2),disc_first_perfs(2,:),3);
        plot_points(sig_groups(2,2),hawk_first_perfs(2,:),3);
        plot_points(sig_groups(1,3),disc_first_perfs(3,:),3);
        plot_points(sig_groups(2,3),hawk_first_perfs(3,:),3);
        plot_points(sig_groups(1,4),disc_first_perfs(4,:),3);
        plot_points(sig_groups(2,4),hawk_first_perfs(4,:),3);
        
        groups = {(sig_groups(:,1)),(sig_groups(:,2)),(sig_groups(:,3)),(sig_groups(:,4))};
        star_hand = sigstar(groups,[p_hab_first_d2h,p_hab_last_d2h,p_hab_2stim_d2h,p_nov_d2h]);
        
        box off
        
        ti = title('14 mice, disc vs hawk'); % 'Mean responses of 14 mice, disc vs hawk'
        set(ti,title_specs);
        ylabel(y_label_str)
        xlabel(x_label_str)
        ylim(y_lim)
        %         xlim(x_lim) %         xlim([0.65 4.39])
        
        ax_comp = gca;
        ax_comp.XTick = 1:length(comp_data);
        set(gca, x_ax_st);
        set(gca, y_ax_st);
        if ~isoctave
            ytickangle(45)
        end
        
        leg_data = han_comp([3:5 8]);
        legend_str = {'dischab', 'hawknov','hawkhab', 'discnov'};
        columnlegend(leg_data, 2, legend_str);
        
        % [LEGH,OBJH,OUTH,OUTM] = legend(han_comp([3:5 8]), 'hab', 'nov', 'hab', 'nov','Orientation','horizontal')
        % legend('boxoff')
        %         ax_comp = gca;
        %         ax_comp.XAxis.FontSize = 18;
        %         ax_comp.XAxis.FontWeight = 'bold';
        %         ax_comp.YAxis.FontSize = 18;
        %         ax_comp.YAxis.FontWeight = 'bold';
        %         ax_comp.XTick = 1:length(comp_data);
        %         set(gca,'XTickLabel', {'1' ,'5', '6', '6'}, 'Xcolor', grey_30,'Ycolor', grey_30,'LineWidth',3, 'FontWeight','bold');
        %%   first session all mice
        figure;
        %         bar_2 = bar(comp_data(1,:));
        bar_2 = bar(comp_data(1,2));
        set(bar_2,'FaceColor', my_burlywood, 'edgecolor', grey_30, 'LineWidth',2, 'Barwidth',0.5);
        %         set(bar_2(2),'FaceColor', my_wheat, 'edgecolor', grey_30, 'LineWidth',2);
        hold on
        %         err_2 = errorbar([1:2],comp_data(1,:),sem_comp(1,:), 'linestyle', 'none');
        err_2 = errorbar([1],comp_data(1,2),sem_comp(1,2), 'linestyle', 'none');
        err_2.Color = grey_30;
        err_2.LineWidth = 2;
        hold on
        %         plot_points(1,disc_first_perfs(1,:),3);
        %         plot_points(2,hawk_first_perfs(1,:),3);
        plot_points(1,hawk_first_perfs(1,:),3);
        ylim([0 100])
        %         xlim([0.5 2.5])
        xlim([0.5 1.5])
        
        
        box off
        title('Mean response in 20 trials', 'FontSize', 19)
        ylabel('freezing (%)')
        %         xlabel('Time(sessions)')
        ylim([0 100])
        %         legend('disc', 'hawk')
        %         legend('boxoff')
        ax_comp = gca;
        ax_comp.XAxis.FontSize = 20;
        ax_comp.XAxis.FontWeight = 'bold';
        ax_comp.YAxis.FontSize = 20;
        ax_comp.YAxis.FontWeight = 'bold';
        %         ax_comp.XTick = 1:length(comp_data);
        %         set(gca,'XTickLabel', {'disc' ,'hawk'}, 'Xcolor', grey_30,'Ycolor', grey_30,'LineWidth',3, 'FontWeight','bold');
        set(gca,'XTickLabel', {'hawk'}, 'Xcolor', grey_30,'Ycolor', grey_30,'LineWidth',3, 'FontWeight','bold');
        
    case 172002.1
        expname = 'aspect_ratio';%'2ellipse';
        switch expname
            case 'aspect_ratio'
                allmice_num = [1:2,5:12];
                each_stim_mice = [1,4:7];
            case 'surface_area' %odd numbers ori disc first
                allmice_num = [13,15,17:24,35,36];
                each_stim_mice = [13:18];
            case 'acicularity'
                allmice_num = [25:34];
                each_stim_mice = [25:29];
            case '2d'
                allmice_num = [37:46];
                each_stim_mice = [37:41];
            case '2ellipse'
                allmice_num = [43:52];
                each_stim_mice = [43:47];
        end
        
        for i = allmice_num
            %allmice_num
            if exist (['performance_172002.1.' num2str(i) '.mat'], 'file')~= 0
                load(['performance_172002.1.' num2str(i) '.mat']);
            elseif exist (['performance_172002.1.0' num2str(i) '.mat'], 'file')~= 0
                load(['performance_172002.1.0' num2str(i) '.mat']);
            else
                errormsg('Freeze duration file does not exist. Get data from manualfrzdata.m');
            end
            hab_first(i) = perf_col(1,1);  %#ok<*AGROW>
            
            for j = 1:30
                if ~isnan(perf_col(j,2)) == 1
                    nov_first(i) = perf_col(j,2);
                    hab_2stim(i) = perf_col(j,1);
                    hab_last(i) = perf_col(j-1,1);
                    break
                else
                    hab_only_trials(j,i) = perf_col(j,1);
                end
            end
        end
        
        hab_first = hab_first*100;
        hab_last = hab_last*100;
        hab_2stim = hab_2stim*100;
        nov_first = nov_first*100;
        all_perfs = [hab_first; hab_last; hab_2stim; nov_first];
        
        switch expname
            case 'surface_area' %odd numbers ori disc first
                m=0;
                for k = allmice_num
                    if mod(k,2) == 0
                        if k == 36 %mouse 35 is small disc first unlike all odd numbers in this experiment
                            disc_first_perfs(:,18) = all_perfs(:,k);
                            disc_hab_only(:,18) = hab_only_trials(:,k);
                        else
                            disc_first_perfs(:,(k-2)-m) = all_perfs(:,k);
                            disc_hab_only(:,(k-2)-m) = hab_only_trials(:,k);
                        end
                    else
                        if k == 35 %mouse 35 is small disc first unlike all odd numbers in this experiment
                            disc_first_perfs(:,17) = all_perfs(:,k);
                            disc_hab_only(:,17) = hab_only_trials(:,k);
                        else
                            ellipse_first_perfs(:,k-m) = all_perfs(:,k);
                            ellipse_hab_only(:,k-m) = hab_only_trials(:,k);
                            m = m+1;
                        end
                    end
                end
            otherwise
                m=0;
                for k = allmice_num
                    if mod(k,2) == 0
                        disc_first_perfs(:,k-m) = all_perfs(:,k);
                        disc_hab_only(:,k-m) = hab_only_trials(:,k);
                    else
                        ellipse_first_perfs(:,k-m) = all_perfs(:,k);
                        ellipse_hab_only(:,k-m) = hab_only_trials(:,k);
                        m = m+1;
                    end
                end
        end
        %% To specify the look of graphs
        my_colours;
        bar_dist = [1:0.5:2.5];
        bar_gap = diff(bar_dist);
        bar_specs_h = struct('FaceColor', my_burlywood, 'edgecolor', grey_30,...
            'LineWidth', 2, 'barwidth', 0.8);
        bar_specs_n = struct('FaceColor', my_turquoiseblue, 'edgecolor', grey_30,...
            'LineWidth', 2, 'barwidth', 0.4);
        
        er_specs = struct('Marker', '.','color', grey_30, 'LineWidth', 2, 'YNegativeDelta', []);
        
        % calculate groups for sig star function
        groups = {[bar_dist(1), bar_dist(2)],[bar_dist(1), bar_dist(3)],...
            [bar_dist(2), bar_dist(3)], [bar_dist(3), bar_dist(4)]};
        
        x_label_str = 'Sessions';
        y_label_str = 'Freezing (%)';
        x_ax_st = struct('XTickLabel', [1,5,6,6], 'Xcolor',grey_30,...
            'Ycolor', grey_30,'LineWidth',3, 'FontName', 'Myriad Pro',...
            'FontWeight','normal', 'FontSize', 20);
        y_ax_st = struct('YTick',[10:20:100],'YTickLabel', [10:20:100],...
            'TickDir', 'out');
        title_specs = struct('FontName', 'Myriad Pro','FontSize', 10);
        y_lim = [0 100];
        x_lim = [bar_dist(1)-(bar_gap(1)*(3/4)), bar_dist(end)+(bar_gap(1)*(3/4))]; % xlim([0.75 2.75])
        leg_specs = struct('FontSize',15,'FontWeight','bold', 'Textcolor', grey_30);
        
        %% ellipse first mice
        % % for mice 1,2,5:12, big ellipse first
        % % for mice 13:24,35,36, original disc first
        % % for mice 25:34, hawk first
        % % for mice 37:46, original disc first
        
        [~,p_ellipse_hab_first2last,ci,stats] = ttest(ellipse_first_perfs(1,each_stim_mice),ellipse_first_perfs(2,each_stim_mice));
        [~,p_ellipse_hab_first2stim,ci,stats] = ttest(ellipse_first_perfs(1,each_stim_mice),ellipse_first_perfs(3,each_stim_mice));
        [~,p_ellipse_hablast_nov,ci,stats] = ttest(ellipse_first_perfs(2,each_stim_mice),ellipse_first_perfs(4,each_stim_mice));
        [~,p_ellipse_hab2stim_nov,ci,stats] = ttest(ellipse_first_perfs(3,each_stim_mice),ellipse_first_perfs(4,each_stim_mice));
        [~,p_ellipse_hab_last2stim,ci,stats] = ttest(ellipse_first_perfs(2,each_stim_mice),ellipse_first_perfs(3,each_stim_mice));
        [~,p_ellipse_hab_first_nov_first,ci,stats] = ttest(ellipse_first_perfs(1,each_stim_mice),ellipse_first_perfs(4,each_stim_mice));
        
        p_ellipse = [p_ellipse_hab_first2last,p_ellipse_hab_first2stim,p_ellipse_hablast_nov,...
            p_ellipse_hab2stim_nov,p_ellipse_hab_last2stim,p_ellipse_hab_first_nov_first];
        
        mean_ellipse_first_days = mean(ellipse_first_perfs(:,each_stim_mice),2);
        sem_ellipse_first_days = sem(ellipse_first_perfs(:,each_stim_mice),2);
        
        
        fig = figure;
        %         hold on
        
        subplot(1,3,1)
        
        han_h = bar(bar_dist (1:(end-1)),mean_ellipse_first_days(1:(end-1)));
        hold on
        han_n = bar (bar_dist(end), mean_ellipse_first_days(end));
        set(han_h,bar_specs_h);
        set(han_n,bar_specs_n);
        
        % works in Matlab 2014
        %         for i = 1:2
        %             if i == 1
        %                 han(i) = bar(bar_dist,mean_ellipse_first_days);
        %                 set(han(i),'FaceColor', my_burlywood, 'edgecolor', grey_30, 'LineWidth',2, 'barwidth', 0.4);
        %             else
        %                 han(i) = bar(bar_dist(4), mean_ellipse_first_days(4));
        %                 set(han(i),'FaceColor', my_turquoiseblue, 'edgecolor', grey_30, 'LineWidth',2,  'barwidth', 0.2);
        %             end
        %         end
        %
        
        er_ellipse = errorbar(bar_dist,mean_ellipse_first_days,...
            sem_ellipse_first_days,'.');
        set(er_ellipse,er_specs);
        
        % individual mice data points
        for i = 1:length(mean_ellipse_first_days)
            plot_points(bar_dist(i),ellipse_first_perfs(i,each_stim_mice),3);
        end
        
        star_hand_ellipse = sigstar(groups,[p_ellipse_hab_first2last,...
            p_ellipse_hab_first2stim,p_ellipse_hablast_nov,p_ellipse_hab2stim_nov]);
        
        box off
        
        ylabel(y_label_str)
        xlabel(x_label_str)
        ylim(y_lim)
        xlim(x_lim)
        
        ax_ellipse = gca;
        ax_ellipse.XTick = bar_dist;
        set(gca, x_ax_st);
        set(gca, y_ax_st);
        ytickangle(45)
        %         set(fig, 'position', [360 171 396 751])
        
        %         groups = {[1,2],[1,3],[2,4],[3,4],[2,3],[1,4]};
        %         star_hand_hawk = sigstar(groups,[p_hawk_hab_first2last,p_hawk_hab_first2stim,p_hawk_hablast_nov,p_hawk_hab2stim_nov,p_hawk_hab_last2stim,p_hawk_hab_first_nov_first]);
        %         star_hand_hawk(2,1) = star_hand_hawk(1,1)
        
        box off
        switch expname
            case 'aspect_ratio'
                ti = title('Mean responses of 5 mice, Ellipse first'); %1:12
                %                 leg = legend([han_h, han_n],{'large ellipse','original disc'});
            case 'surface_area'
                ti = title('Mean responses of 6 mice, original disc first'); % 13:24,35,36
                %                 leg = legend([han_h, han_n],{'ori disc','small disc'});
            case 'acicularity'
                ti = title('Mean responses of 5 mice, hawk first'); %25:34
                %                 leg = legend([han_h, han_n],{'hawk','ellipse'});
            case '2d'
                ti = title('Mean responses of 5 mice, original disc first'); %37:46
                %                 leg = legend([han_h, han_n],{'original disc','small ellipse'});
            case '2ellipse'
                ti = title('Mean responses of 5 mice, large ellipse first'); %47:56
                %                 leg = legend([han_h, han_n],{'large ellipse','small ellipse'});
        end
        % set(leg, leg_specs)
        set(ti,title_specs);
        %         legend('boxoff')
        
        hold off
        
        %% disc first mice
        % % for mice 1:12, original disc first
        % % for mice 13:24,35,36, small disc first
        % % for mice 25:34, small ellipse first
        % % for mice 37:46, small ellipse first
        
        [h,p_disc_hab_first2last,ci,stats]=ttest(disc_first_perfs(1,each_stim_mice),disc_first_perfs(2,each_stim_mice));
        [h,p_disc_hab_first2stim,ci,stats]=ttest(disc_first_perfs(1,each_stim_mice),disc_first_perfs(3,each_stim_mice));
        [h,p_disc_hablast_nov,ci,stats]=ttest(disc_first_perfs(2,each_stim_mice),disc_first_perfs(4,each_stim_mice));
        [h,p_disc_hab2stim_nov,ci,stats]=ttest(disc_first_perfs(3,each_stim_mice),disc_first_perfs(4,each_stim_mice));
        [h,p_disc_hab_last2stim,ci,stats]=ttest(disc_first_perfs(2,each_stim_mice),disc_first_perfs(3,each_stim_mice));
        [h,p_disc_hab_first_nov_first,ci,stats]=ttest(disc_first_perfs(1,each_stim_mice),disc_first_perfs(4,each_stim_mice));
        
        p_disc = [p_disc_hab_first2last,p_disc_hab_first2stim,p_disc_hablast_nov,...
            p_disc_hab2stim_nov,p_disc_hab_last2stim,p_disc_hab_first_nov_first];
        
        mean_disc_first_days = mean(disc_first_perfs(:,each_stim_mice),2);
        sem_disc_first_days = sem(disc_first_perfs(:,each_stim_mice),2);
        
        %         fig = figure;
        %         hold on
        subplot(1,3,2)
        
        han_h = bar(bar_dist (1:(end-1)),mean_disc_first_days(1:(end-1)));
        hold on
        han_n = bar (bar_dist(end), mean_disc_first_days(end));
        set(han_h,bar_specs_h);
        set(han_n,bar_specs_n);
        
        % works in Matlab 2014
        %         for i = 1:2
        %             if i == 1
        %                 han(i) = bar(bar_dist, mean_disc_first_days);
        %                 set(han(i),'FaceColor', my_burlywood, 'edgecolor', grey_30, 'LineWidth',2, 'barwidth', 0.4);
        %             else
        %                 han(i) = bar(bar_dist(4), mean_disc_first_days(4));
        %                 set(han(i),'FaceColor', my_turquoiseblue, 'edgecolor', grey_30, 'LineWidth',2,  'barwidth', 0.2);
        %             end
        %         end
        
        er_disc = errorbar(bar_dist,mean_disc_first_days,sem_disc_first_days,'.');
        set(er_disc,er_specs);
        
        % individual mice data points
        for i = 1:length(mean_disc_first_days)
            plot_points(bar_dist(i),disc_first_perfs(i,each_stim_mice),3);
        end

        star_hand_ellipse = sigstar(groups,[p_disc_hab_first2last,...
            p_disc_hab_first2stim,p_disc_hablast_nov,p_disc_hab2stim_nov]);
        
        %         groups = {[1,2],[1,3],[2,4],[3,4],[2,3],[1,4]};
        %         star_hand_disc = sigstar(groups,[p_disc_hab_first2last,p_disc_hab_first2stim,p_disc_hablast_nov,p_disc_hab2stim_nov,p_disc_hab_last2stim,p_disc_hab_first_nov_first]);
        %         star_hand_disc(2,1) = star_hand_disc(1,1)
        
        box off
        
        %         ylabel(y_label_str)
        xlabel(x_label_str)
        ylim(y_lim)
        xlim(x_lim)
        
        ax_disc = gca;
        ax_disc.XTick = bar_dist;
        set(gca, x_ax_st);
        set(gca, y_ax_st);
        ytickangle(45)
        %         set(fig, 'position', [360 171 396 751])
        
        switch expname
            case 'aspect_ratio'
                ti = title('Mean responses of 5 mice, original disc first'); %1:12
                %                 leg = legend([han_h, han_n],{'ellipse','ori disc'}); %1:12
            case 'surface_area'
                ti = title('Mean responses of 6 mice, small disc first'); % 13:24,35,36
                %                 leg = legend([han_h, han_n],{'small disc','oridisc'}); %13:24
            case 'acicularity'
                ti = title('Mean responses of 5 mice, ellipse first'); %25:34
                %                 leg = legend([han_h, han_n],{'ellipse','hawk'}); %25:34
            case '2d'
                ti = title('Mean responses of 5 mice, small ellipse first'); %37:46
                %                 leg = legend([han_h, han_n],{'small ellipse','original disc'}); %37:46
            case '2ellipse'
                ti = title('Mean responses of 5 mice, small ellipse first'); %47:56
                %                 leg = legend([han_h, han_n],{'small ellipse','large ellipse'}); %47:56
        end
        % set(leg, leg_specs)
        set(ti,title_specs);
        %         legend('boxoff')
        
        hold off
        
        %% all mice
        
        [h,p_hab_first2last,ci,stats]=ttest(hab_first(allmice_num),hab_last(allmice_num));
        [h,p_hab_first2stim,ci,stats]=ttest(hab_first(allmice_num),hab_2stim(allmice_num));
        [h,p_hablast_nov,ci,stats]=ttest(hab_last(allmice_num),nov_first(allmice_num));
        [h,p_hab2stim_nov,ci,stats]=ttest(hab_2stim(allmice_num),nov_first(allmice_num));
        [h,p_hab_last2stim,ci,stats]=ttest(hab_last(allmice_num),hab_2stim(allmice_num));
        [h,p_hab_first_nov_first,ci,stats]=ttest(hab_first(allmice_num),nov_first(allmice_num));
        %
        p_all = [p_hab_first2last,p_hab_first2stim,p_hablast_nov,p_hab2stim_nov,...
            p_hab_last2stim,p_hab_first_nov_first];
        
        mean_all_days = nanmean(all_perfs(:,allmice_num),2);
        sem_all_days = sem(all_perfs(:,allmice_num),2);
        
        %         fig = figure;
        %         hold on
        
        subplot(1,3,3)
        
        han_h = bar(bar_dist (1:(end-1)),mean_all_days(1:(end-1)));
        hold on
        han_n = bar (bar_dist(end), mean_all_days(end));
        set(han_h,bar_specs_h);
        set(han_n,bar_specs_n);
        
        % works in Matlab 2014
        %         for i = 1:2
        %             if i == 1
        %                 han(i) = bar(bar_dist, mean_all_days);
        %                 set(han(i),'FaceColor', my_burlywood, 'edgecolor', grey_30, 'LineWidth',2, 'barwidth', 0.4);
        %             else
        %                 han(i) = bar(bar_dist(4), mean_all_days(4));
        %                 set(han(i),'FaceColor', my_turquoiseblue, 'edgecolor', grey_30, 'LineWidth',2,  'barwidth', 0.2);
        %             end
        %         end
        
        
        er = errorbar(bar_dist,mean_all_days,sem_all_days,'.');
        set(er,er_specs);
        
        % individual mice data points
        for i = 1:length(mean_all_days)
            plot_points(bar_dist(i),all_perfs(i,allmice_num),3);
        end
        
        star_hand_ellipse = sigstar(groups,[p_hab_first2last,...
            p_hab_first2stim,p_hablast_nov,p_hab2stim_nov]);
        
        %         groups = {[1,2],[1,3],[2,4],[3,4],[2,3],[1,4]};
        %         star_hand = sigstar(groups,[p_hab_first2last,p_hab_first2stim,p_hablast_nov,p_hab2stim_nov,p_hab_last2stim,p_hab_first_nov_first]);
        %         star_hand(2,1) = star_hand(1,1)
        
        box off
        switch expname
            case 'aspect_ratio'
                ti = title('Mean responses of 10 mice, aspect ratio test'); %1:12
                leg = legend([han_h, han_n],{'ellipse','ori disc'});
            case 'surface_area'
                ti = title('Mean responses of 12 mice, surface area test'); % 13:24,35,36
                leg = legend([han_h, han_n],{'small disc','oridisc'});
            case 'acicularity'
                ti = title('Mean responses of 10 mice, accicularity test'); %25:34
                leg = legend([han_h, han_n],{'ellipse','hawk'});
            case '2d'
                ti = title('Mean responses of 10 mice, 2 dimensions test'); %37:466
                leg = legend([han_h, han_n],{'small ellipse','original disc'});
            case '2ellipse'
                title('Mean responses of 10 mice, ellipse surface area test'); %47:56
                leg = legend([han_h, han_n],{'small ellipse','large ellipse'});
        end
        
        set(ti,title_specs);
        set(leg, leg_specs);
        legend('boxoff');
        %         ylabel(y_label_str)
        xlabel(x_label_str)
        ylim(y_lim)
        xlim(x_lim)
        
        ax_disc = gca;
        ax_disc.XTick = bar_dist;
        set(gca, x_ax_st);
        set(gca, y_ax_st);
        set(ti,title_specs);
        ytickangle(45)
        %         set(fig, 'position', [360 171 396 751])
        hold off
        
        %% comparison between hawk first and disc first
        
        comp_data = [mean_disc_first_days, mean_ellipse_first_days];
        sem_comp = [sem_disc_first_days, sem_ellipse_first_days];
        
        [h,p_hab_first_d2h,ci,stats]=ttest2(disc_first_perfs(1,each_stim_mice),ellipse_first_perfs(1,each_stim_mice),'Alpha',0.01);
        [h,p_hab_last_d2h,ci,stats]=ttest2(disc_first_perfs(2,each_stim_mice),ellipse_first_perfs(2,each_stim_mice),'Alpha',0.01);
        [h,p_hab_2stim_d2h,ci,stats]=ttest2(disc_first_perfs(3,each_stim_mice),ellipse_first_perfs(3,each_stim_mice),'Alpha',0.01);
        [h,p_nov_d2h,ci,stats]=ttest2(disc_first_perfs(4,each_stim_mice),ellipse_first_perfs(4,each_stim_mice),'Alpha',0.01);
        
        figure;
        hold on
        for i = 1:length(comp_data)
            han_comp(i) = bar(i-0.1429, comp_data(i,1)); %#ok<*SAGROW>
            if i<length(comp_data)
                set(han_comp(i),'FaceColor', my_burlywood, 'edgecolor', grey_30, 'LineWidth',2, 'barwidth', 0.2);
            else
                set(han_comp(i),'FaceColor', my_turquoiseblue, 'edgecolor', grey_30, 'LineWidth',2,  'barwidth', 0.2);
            end
            han_comp(i+length(comp_data)) = bar(i+0.1429, comp_data(i,2));
            if i<length(comp_data)
                set(han_comp(i+length(comp_data)),'FaceColor', my_wheat, 'edgecolor', grey_30, 'LineWidth',2, 'barwidth', 0.2);
            else
                set(han_comp(i+length(comp_data)),'FaceColor', my_lightturquoise, 'edgecolor', grey_30, 'LineWidth',2,  'barwidth', 0.2);
            end
        end
        % legend(han_comp([3:5 8]))
        % Finding the number of groups and the number of bars in each group
        ngroups = size(comp_data, 1);
        nbars = size(comp_data, 2);
        % Calculating the width for each bar group
        groupwidth = min(0.8, nbars/(nbars + 1.5));
        % Set the position of each error bar in the centre of the main bar
        % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
        for i = 1:nbars
            % Calculate center of each bar
            x_comp = ((1:ngroups) - groupwidth/2) + (2*i-1) * groupwidth / (2*nbars);
            er_comp = errorbar(x_comp, comp_data(:,i), sem_comp(:,i), 'color', grey_30, 'linestyle', 'none', 'linewidth', 2);
            sig_groups(i,(1:ngroups)) = x_comp;
        end
        
        plot_points(sig_groups(1,1),disc_first_perfs(1,each_stim_mice),3);
        plot_points(sig_groups(2,1),ellipse_first_perfs(1,each_stim_mice),3);
        plot_points(sig_groups(1,2),disc_first_perfs(2,each_stim_mice),3);
        plot_points(sig_groups(2,2),ellipse_first_perfs(2,each_stim_mice),3);
        plot_points(sig_groups(1,3),disc_first_perfs(3,each_stim_mice),3);
        plot_points(sig_groups(2,3),ellipse_first_perfs(3,each_stim_mice),3);
        plot_points(sig_groups(1,4),disc_first_perfs(4,each_stim_mice),3);
        plot_points(sig_groups(2,4),ellipse_first_perfs(4,each_stim_mice),3);
        
        
        groups = {[sig_groups(:,1)],[sig_groups(:,2)],[sig_groups(:,3)],[sig_groups(:,4)]}; %#ok<*NBRAK>
        star_hand = sigstar(groups,[p_hab_first_d2h,p_hab_last_d2h,p_hab_2stim_d2h,p_nov_d2h]);
        
        box off
        switch expname
            case 'aspect_ratio'
                title('Mean responses of of 10 mice, aspect ratio', 'FontSize', 18) %1:12
                legend_str = {'dischab', 'ellipsenov','ellipsehab', 'discdnov'};
            case 'surface_area'
                title('Mean responses of 12 mice, surface area', 'FontSize', 18) % 13:24,35,36
                legend_str = {'small dischab', 'large disc nov','large disc hab', 'small disc nov'}; % 13:24
            case 'acicularity'
                title('Mean responses of 10 mice, acicularity', 'FontSize', 18) %25:34
                legend_str = {'ellipsehab', 'hawknov','hawkhab', 'ellipsenov'}; % 25:34
            case '2d'
                title('Mean responses of 10 mice, 2 dimensions', 'FontSize', 18) %37:46
                legend_str = {'ellipsehab', 'discnov','dischab', 'ellipsenov'}; % 37:46
            case '2ellipse'
                title('Mean responses of 10 mice, 2 ellipses', 'FontSize', 18) %47:56
                legend_str = {'S_ellipsehab', 'L_ellipsenov','L_ellipsenov', 'S_ellipsenov'}; %47:56
        end
        
        ylabel('freezing (%)','FontWeight','bold')
        xlabel('Time(sessions)','FontWeight','bold')
        ylim([0 100])
        
        leg_data = han_comp([3:5 8]);
        [legend_h,object_h,plot_h,text_strings] = columnlegend(leg_data, 2, legend_str);
        % [LEGH,OBJH,OUTH,OUTM] = legend(han_comp([3:5 8]), 'hab', 'nov', 'hab', 'nov','Orientation','horizontal')
        % legend('boxoff')
        ax_comp = gca;
        ax_comp.XAxis.FontSize = 18;
        ax_comp.XAxis.FontWeight= 'bold';
        ax_comp.YAxis.FontSize = 18;
        ax_comp.YAxis.FontWeight= 'bold';
        ax_comp.XTick = 1:length(comp_data);
        set(gca,'XTickLabel', {'1' ,'5', '6', '6'}, 'Xcolor', grey_30,'Ycolor', grey_30,'LineWidth',3, 'FontWeight','bold');
        
        %% 172005
    case 172005
        group = 1;
        switch group
            case 1
                mice_172005_1 %SC
                perfstr = 'performance_172005.1.';
                titlestr = 'Hawk vs Disc, SC inhibition';
                %                     allmice_num = [11:13,15:16];
                allmice_num = 11:16;
            case 2
                mice_172005_2 %V1
                perfstr = 'performance_172005.2.';
                titlestr = 'Hawk vs Disc, V1 inhibition';
                allmice_num = 11;
            case 3
                mice_172005_3 %LP
                perfstr = 'performance_172005.3.';
                titlestr = 'Hawk vs Disc, LP inhibition';
                allmice_num = 1:20;
        end
        
        for i = allmice_num
            if exist (['performance_172005.1.' num2str(i) '.mat'], 'file')~= 0
                load(['performance_172005.1.' num2str(i) '.mat']);
            elseif exist (['performance_172005.1.0' num2str(i) '.mat'], 'file')~= 0
                load(['performance_172005.1.0' num2str(i) '.mat']);
            else
                disp('Freeze duration file does not exist. Get data from manualfrzdata.m');
            end
            hab_first(i) = perf_col(1,1);  %#ok<*AGROW>
            
            for j = 1:30
                if ~isnan(perf_col(j,2)) == 1
                    nov_first(i) = perf_col(j,2);
                    hab_2stim(i) = perf_col(j,1);
                    hab_last(i) = perf_col(j-1,1);
                    break
                else
                    hab_only_trials(j,i) = perf_col(j,1);
                end
            end
        end
        
        hab_first = hab_first*100;
        hab_last = hab_last*100;
        hab_2stim = hab_2stim*100;
        nov_first = nov_first*100;
        all_perfs = [hab_first; hab_last; hab_2stim; nov_first];
        
        [h,p_hab_first2last,ci,stats]=ttest(hab_first(allmice_num),hab_last(allmice_num));
        [h,p_hab_first2stim,ci,stats]=ttest(hab_first(allmice_num),hab_2stim(allmice_num));
        [h,p_hablast_nov,ci,stats]=ttest(hab_last(allmice_num),nov_first(allmice_num));
        [h,p_hab2stim_nov,ci,stats]=ttest(hab_2stim(allmice_num),nov_first(allmice_num));
        [h,p_hab_last2stim,ci,stats]=ttest(hab_last(allmice_num),hab_2stim(allmice_num));
        [h,p_hab_first_nov_first,ci,stats]=ttest(hab_first(allmice_num),nov_first(allmice_num));
        %
        p_all = [p_hab_first2last,p_hab_first2stim,p_hablast_nov,p_hab2stim_nov,...
            p_hab_last2stim,p_hab_first_nov_first];
        
        mean_all_days = nanmean(all_perfs(:,allmice_num),2);
        sem_all_days = sem(all_perfs(:,allmice_num),2);
        
        my_colours;
        bar_dist = [1:0.5:2.5];
        
        figure;
        hold on
        for i = 1:2
            if i == 1
                han(i) = bar(bar_dist, mean_all_days);
                set(han(i),'FaceColor', my_burlywood, 'edgecolor', grey_30, 'LineWidth',2, 'barwidth', 0.4);
            else
                han(i) = bar(bar_dist(4), mean_all_days(4));
                set(han(i),'FaceColor', my_turquoiseblue, 'edgecolor', grey_30, 'LineWidth',2,  'barwidth', 0.2);
            end
        end
        er = errorbar(bar_dist,mean_all_days,sem_all_days,'.');
        er.Color = grey_30;
        er.LineWidth = 2;
        
        plot_points(1,all_perfs(1,allmice_num),3);
        plot_points(1.5,all_perfs(2,allmice_num),3);
        plot_points(2,all_perfs(3,allmice_num),3);
        plot_points(2.5,all_perfs(4,allmice_num),3);
        
        groups = {[1,1.5],[1,2],[1.5,2.5],[2,2.5]};
        star_hand = sigstar(groups,[p_hab_first2last,p_hab_first2stim,p_hablast_nov,p_hab2stim_nov]);
        
        %         groups = {[1,2],[1,3],[2,4],[3,4],[2,3],[1,4]};
        %         star_hand = sigstar(groups,[p_hab_first2last,p_hab_first2stim,p_hablast_nov,p_hab2stim_nov,p_hab_last2stim,p_hab_first_nov_first]);
        %         star_hand(2,1) = star_hand(1,1)
        
        box off
        
        ylim([0 100])
        xlim([0.75 2.75])
        ylabel('mean freezing(%)','FontWeight','bold')
        xlabel('Time(sessions)','FontWeight','bold')
        legend({'habituating','novel'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30);
        legend('boxoff')
        ax = gca;
        ax.XAxis.FontSize = 18;
        ax.XAxis.FontWeight= 'bold';
        ax.YAxis.FontSize = 18;
        ax.YAxis.FontWeight= 'bold';
        ax.XTick = bar_dist;
        set(gca,'XTickLabel', {'1' ,'5', '6', '6'},'Xcolor', grey_30,'Ycolor', grey_30,'LineWidth',3, 'FontWeight','bold');
        title(titlestr, 'FontSize', 20)
        hold off
        
end


cd(curdir); 














