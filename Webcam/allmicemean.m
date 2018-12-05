% function [p_hawk, p_disc, p_all, p_comp_all] = allmicemean(exp)
%% Draws the bar plots of the data from group 2 mice 14.13 and 172002
% with the significance stars
% Azadeh September 2017
switch exp %can be 14.13, 172002, 172005
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
        
        my_colours;
        bar_dist = [1:0.5:2.5];
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
        
        
        figure;
        hold on
        for i = 1:2
            if i == 1
                han(i) = bar(bar_dist,mean_hawk_first_days);
                set(han(i),'FaceColor', my_burlywood, 'edgecolor', grey_30, 'LineWidth',2, 'barwidth', 0.4);
            else
                han(i) = bar(bar_dist(4), mean_hawk_first_days(4));
                set(han(i),'FaceColor', my_turquoiseblue, 'edgecolor', grey_30, 'LineWidth',2,  'barwidth', 0.2);
            end
        end
        
        er_hawk = errorbar(bar_dist,mean_hawk_first_days,sem_hawk_first_days,'.');
        er_hawk.Color = grey_30;
        er_hawk.LineWidth = 2;
        
        plot_points(1,hawk_first_perfs(1,:),3);
        plot_points(1.5,hawk_first_perfs(2,:),3);
        plot_points(2,hawk_first_perfs(3,:),3);
        plot_points(2.5,hawk_first_perfs(4,:),3);
        
        groups = {[1,1.5],[1,2],[1.5,2.5],[2,2.5]};
        star_hand_hawk = sigstar(groups,[p_hawk_hab_first2last,p_hawk_hab_first2stim,p_hawk_hablast_nov,p_hawk_hab2stim_nov]);
        
        % groups = {[1,2],[1,3],[2,4],[3,4],[2,3],[1,4]};
        % star_hand_hawk = sigstar(groups,[p_hawk_hab_first2last,p_hawk_hab_first2stim,p_hawk_hablast_nov,p_hawk_hab2stim_nov,p_hawk_hab_last2stim,p_hawk_hab_first_nov_first]);
        % star_hand_hawk(2,1) = star_hand_hawk(1,1)
        
        box off
        title('Mean response of 7 mice, hawk first', 'FontSize', 19)
        ylabel('freezing(%)','FontWeight','bold')
        xlabel('Time(sessions)','FontWeight','bold')
        ylim([0 100])
        xlim([0.75 2.75])
        % legend
        %         [LEGH,OBJH,OUTH,OUTM] = legend('hawk','disc');
        legend({'hawk','disc'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30);
        legend('boxoff')
        ax_hawk = gca;
        ax_hawk.XAxis.FontSize = 18;
        ax_hawk.XAxis.FontWeight = 'bold';
        ax_hawk.YAxis.FontSize = 18;
        ax_hawk.YAxis.FontWeight = 'bold';
        ax_hawk.XTick = bar_dist;
        set(gca,'XTickLabel', {'1' ,'5', '6', '6'}, 'Xcolor', grey_30,'Ycolor', grey_30,'LineWidth',3, 'FontWeight','bold');
        
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
        
        figure;
        hold on
        for i = 1:2
            if i == 1
                han(i) = bar(bar_dist,mean_disc_first_days);
                set(han(i),'FaceColor', my_burlywood, 'edgecolor', grey_30, 'LineWidth',2, 'barwidth', 0.4);
            else
                han(i) = bar(bar_dist(4), mean_disc_first_days(4));
                set(han(i),'FaceColor', my_turquoiseblue, 'edgecolor', grey_30, 'LineWidth',2,  'barwidth', 0.2);
            end
        end
        er_disc = errorbar(bar_dist,mean_disc_first_days,sem_disc_first_days,'.');
        er_disc.Color = grey_30;
        er_disc.LineWidth = 2;
        
        plot_points(1,disc_first_perfs(1,:),3);
        plot_points(1.5,disc_first_perfs(2,:),3);
        plot_points(2,disc_first_perfs(3,:),3);
        plot_points(2.5,disc_first_perfs(4,:),3);
        
        groups = {[1,1.5],[1,2],[1.5,2.5],[2,2.5]};
        star_hand_disc = sigstar(groups,[p_disc_hab_first2last,p_disc_hab_first2stim,p_disc_hablast_nov,p_disc_hab2stim_nov]);
        
        % groups = {[1,2],[1,3],[2,4],[3,4],[2,3],[1,4]};
        % star_hand_disc = sigstar(groups,[p_disc_hab_first2last,p_disc_hab_first2stim,p_disc_hablast_nov,p_disc_hab2stim_nov,p_disc_hab_last2stim,p_disc_hab_first_nov_first]);
        % star_hand_disc(2,1) = star_hand_disc(1,1)
        
        box off
        title('Mean response of 7 mice, disc first', 'FontSize', 19)
        ylabel('freezing (%)', 'FontWeight','bold')
        xlabel('Time(sessions)', 'FontWeight','bold')
        ylim([0 100])
        xlim([0.75 2.75])
        % legend
%         [LEGH,OBJH,OUTH,OUTM]  = legend('disc','hawk');
        legend({'disc','hawk'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30);
        legend('boxoff')
        ax_disc = gca;
        ax_disc.XAxis.FontSize = 18;
        ax_disc.XAxis.FontWeight = 'bold';
        ax_disc.YAxis.FontSize = 18;
        ax_dsc.YAxis.FontWeight = 'bold';
        ax_disc.XTick = bar_dist;
        set(gca,'XTickLabel', {'1' ,'5', '6', '6'}, 'Xcolor', grey_30,'Ycolor', grey_30,'LineWidth',3, 'FontWeight','bold');
        
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
        
        figure;
        hold on
        for i = 1:2
            if i == 1
                han(i) = bar(bar_dist,mean_all_days);
                set(han(i),'FaceColor', my_burlywood, 'edgecolor', grey_30, 'LineWidth',2, 'barwidth', 0.4);
            else
                han(i) = bar(bar_dist(4), mean_all_days(4));
                set(han(i),'FaceColor', my_turquoiseblue, 'edgecolor', grey_30, 'LineWidth',2,  'barwidth', 0.2);
            end
        end
        er = errorbar(bar_dist,mean_all_days,sem_all_days,'.');
        er.Color = grey_30;
        er.LineWidth = 2;
        
        plot_points(1,all_perfs(1,:),3);
        plot_points(1.5,all_perfs(2,:),3);
        plot_points(2,all_perfs(3,:),3);
        plot_points(2.5,all_perfs(4,:),3);
        
        groups = {[1,1.5],[1,2],[1.5,2.5],[2,2.5]};
        star_hand = sigstar(groups,[p_hab_first2last,p_hab_first2stim,p_hablast_nov,p_hab2stim_nov]); %#ok<*NASGU>
        
        % groups = {[1,2],[1,3],[2,4],[3,4],[2,3],[1,4]};
        % star_hand = sigstar(groups,[p_hab_first2last,p_hab_first2stim,p_hablast_nov,p_hab2stim_nov,p_hab_last2stim,p_hab_first_nov_first]);
        % star_hand(2,1) = star_hand(1,1)
        
        box off
        title('Mean responses of 14 mice', 'FontSize', 19)
        ylabel('mean freezing (%)', 'FontWeight','bold')
        xlabel('Time(sessions)', 'FontWeight','bold')
        ylim([0 100])
        xlim([0.75 2.75])
        legend({'habituating','novel'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30);
        legend('boxoff')
        ax = gca;
        ax.XAxis.FontSize = 20;
        ax.XAxis.FontWeight = 'bold';
        ax.YAxis.FontSize = 20;
        ax.YAxis.FontWeight = 'bold';
        ax.XTick = bar_dist;
        set(gca,'XTickLabel', {'1' ,'5', '6', '6'}, 'Xcolor', grey_30,'Ycolor', grey_30,'LineWidth',3, 'FontWeight','bold');
        
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
        title('Mean responses of 14 mice, disc vs hawk', 'FontSize', 19)
        ylabel('freezing (%)')
        xlabel('Time(sessions)')
        ylim([0 100])
%         xlim([0.65 4.39])
        leg_data = han_comp([3:5 8]);
        legend_str = {'dischab', 'hawknov','hawkhab', 'discnov'};
        columnlegend(leg_data, 2, legend_str);

        % [LEGH,OBJH,OUTH,OUTM] = legend(han_comp([3:5 8]), 'hab', 'nov', 'hab', 'nov','Orientation','horizontal')
        % legend('boxoff')
        ax_comp = gca;
        ax_comp.XAxis.FontSize = 18;
        ax_comp.XAxis.FontWeight = 'bold';
        ax_comp.YAxis.FontSize = 18;
        ax_comp.YAxis.FontWeight = 'bold';
        ax_comp.XTick = 1:length(comp_data);
        set(gca,'XTickLabel', {'1' ,'5', '6', '6'}, 'Xcolor', grey_30,'Ycolor', grey_30,'LineWidth',3, 'FontWeight','bold');
   %%     
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
        expname = 'acicularity';
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
        
        my_colours;
        bar_dist = [1:0.5:2.5];
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
        
        figure;
        hold on
        for i = 1:2
            if i == 1
                han(i) = bar(bar_dist,mean_ellipse_first_days);
                set(han(i),'FaceColor', my_burlywood, 'edgecolor', grey_30, 'LineWidth',2, 'barwidth', 0.4);
            else
                han(i) = bar(bar_dist(4), mean_ellipse_first_days(4));
                set(han(i),'FaceColor', my_turquoiseblue, 'edgecolor', grey_30, 'LineWidth',2,  'barwidth', 0.2);
            end
        end
        
        er_ellipse = errorbar(bar_dist,mean_ellipse_first_days,sem_ellipse_first_days,'.');
        er_ellipse.Color = grey_30;
        er_ellipse.LineWidth = 2;
        
        plot_points(1,ellipse_first_perfs(1,each_stim_mice),3);
        plot_points(1.5,ellipse_first_perfs(2,each_stim_mice),3);
        plot_points(2,ellipse_first_perfs(3,each_stim_mice),3);
        plot_points(2.5,ellipse_first_perfs(4,each_stim_mice),3);
        
        groups = {[1,1.5],[1,2],[1.5,2.5],[2,2.5]};
        star_hand_ellipse = sigstar(groups,...
            [p_ellipse_hab_first2last,p_ellipse_hab_first2stim,p_ellipse_hablast_nov,p_ellipse_hab2stim_nov]);
        
        %         groups = {[1,2],[1,3],[2,4],[3,4],[2,3],[1,4]};
        %         star_hand_hawk = sigstar(groups,[p_hawk_hab_first2last,p_hawk_hab_first2stim,p_hawk_hablast_nov,p_hawk_hab2stim_nov,p_hawk_hab_last2stim,p_hawk_hab_first_nov_first]);
        %         star_hand_hawk(2,1) = star_hand_hawk(1,1)
        
        box off
        switch expname
            case 'aspect_ratio'
                title('Mean responses of 5 mice, Ellipse first', 'FontSize', 19) %1:12
%                 [LEGH,OBJH,OUTH,OUTM] = legend('large ellipse','original disc','FontSize',15,'FontWeight','bold', 'Textcolor', grey_30); %1:12
                legend({'large ellipse','original disc'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30);
            case 'surface_area'
                title('Mean responses of 6 mice, original disc first', 'FontSize', 19) % 13:24,35,36
%                 [LEGH,OBJH,OUTH,OUTM] = legend('ori disc','small disc'); %13:24
                legend({'ori disc','small disc'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30);
            case 'acicularity'
                title('Mean responses of 5 mice, hawk first', 'FontSize', 19) %25:34
%                 [LEGH,OBJH,OUTH,OUTM] = legend('hawk','ellipse'); %25:34
                legend({'hawk','ellipse'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30);
            case '2d'
                title('Mean responses of 5 mice, original disc first', 'FontSize', 19) %37:46
%                 [LEGH,OBJH,OUTH,OUTM] = legend('original disc','small ellipse'); %37:46
                legend({'original disc','small ellipse'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30);
            case '2ellipse'
                title('Mean responses of 5 mice, large ellipse first', 'FontSize', 19) %47:56
%                 [LEGH,OBJH,OUTH,OUTM] = legend('large ellipse','small ellipse'); %47:56
                legend({'large ellipse','small ellipse'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30);
        end
        
        ylabel('freezing(%)','FontWeight','bold')
        xlabel('Time(sessions)','FontWeight','bold')
        ylim([0 100])
        xlim([0.75 2.75])
        % legend
        legend('boxoff')
        ax_ellipse = gca;
        ax_ellipse.XAxis.FontSize = 18;
        ax_ellipse.XAxis.FontWeight = 'bold';
        ax_ellipse.YAxis.FontSize = 18;
        ax_ellipse.YAxis.FontWeight = 'bold';
        ax_ellipse.XTick = bar_dist;
        set(gca,'XTickLabel', {'1' ,'5', '6', '6'}, 'Xcolor', grey_30,'Ycolor', grey_30,'LineWidth',3, 'FontWeight','bold');
        
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
        
        figure;
        hold on
        for i = 1:2
            if i == 1
                han(i) = bar(bar_dist, mean_disc_first_days);
                set(han(i),'FaceColor', my_burlywood, 'edgecolor', grey_30, 'LineWidth',2, 'barwidth', 0.4);
            else
                han(i) = bar(bar_dist(4), mean_disc_first_days(4));
                set(han(i),'FaceColor', my_turquoiseblue, 'edgecolor', grey_30, 'LineWidth',2,  'barwidth', 0.2);
            end
        end
        er_disc = errorbar(bar_dist,mean_disc_first_days,sem_disc_first_days,'.');
        er_disc.Color = grey_30;
        er_disc.LineWidth = 2;
        ylim([0 100])
        xlim([0.75 2.75])
        
        plot_points(1,disc_first_perfs(1,each_stim_mice),3);
        plot_points(1.5,disc_first_perfs(2,each_stim_mice),3);
        plot_points(2,disc_first_perfs(3,each_stim_mice),3);
        plot_points(2.5,disc_first_perfs(4,each_stim_mice),3);
        
        groups = {[1,1.5],[1,2],[1.5,2.5],[2,2.5]};
        star_hand_disc = sigstar(groups,[p_disc_hab_first2last,p_disc_hab_first2stim,p_disc_hablast_nov,p_disc_hab2stim_nov]);
        
        %         groups = {[1,2],[1,3],[2,4],[3,4],[2,3],[1,4]};
        %         star_hand_disc = sigstar(groups,[p_disc_hab_first2last,p_disc_hab_first2stim,p_disc_hablast_nov,p_disc_hab2stim_nov,p_disc_hab_last2stim,p_disc_hab_first_nov_first]);
        %         star_hand_disc(2,1) = star_hand_disc(1,1)
        
        box off
        switch expname
            case 'aspect_ratio'
                title('Mean responses of 5 mice, original disc first', 'FontSize', 18) %1:12
                legend({'ellipse','ori disc'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30); %1:12
            case 'surface_area'
                title('Mean responses of 6 mice, small disc first', 'FontSize', 18) % 13:24,35,36
                legend({'small disc','oridisc'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30); %13:24
            case 'acicularity'
                title('Mean responses of 5 mice, ellipse first', 'FontSize', 18) %25:34
                legend({'ellipse','hawk'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30); %25:34
            case '2d'
                title('Mean responses of 5 mice, small ellipse first', 'FontSize', 18) %37:46
                legend({'small ellipse','original disc'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30); %37:46
            case '2ellipse'
                title('Mean responses of 5 mice, small ellipse first', 'FontSize', 18) %47:56
                legend({'small ellipse','large ellipse'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30); %47:56
        end
        
        ylabel('freezing(%)','FontWeight','bold')
        xlabel('Time(sessions)','FontWeight','bold')
        % legend
        legend('boxoff')
        ax_disc = gca;
        ax_disc.XAxis.FontSize = 18;
        x_disc.XAxis.FontWeight= 'bold';
        ax_disc.YAxis.FontSize = 18;
        x_disc.YAxis.FontWeight= 'bold';
        ax_disc.XTick = bar_dist;
        set(gca,'XTickLabel', {'1' ,'5', '6', '6'}, 'Xcolor', grey_30,'Ycolor', grey_30,'LineWidth',3, 'FontWeight','bold');
        
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
        switch expname
            case 'aspect_ratio'
                title('Mean responses of 10 mice, aspect ratio test', 'FontSize', 19) %1:12
            case 'surface_area'
                title('Mean responses of 12 mice, surface area test', 'FontSize', 19) % 13:24,35,36
            case 'acicularity'
                title('Mean responses of 10 mice, accicularity test', 'FontSize', 19) %25:34
            case '2d'
                title('Mean responses of 10 mice, 2 dimensions test', 'FontSize', 19) %37:466
            case '2ellipse'
                title('Mean responses of 10 mice, ellipse surface area test', 'FontSize', 19) %47:56
        end
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
        Case 172005
            group = 1;
            switch group
                case 1
                    mice_172005_1 %SC
                    perfstr = 'performance_172005.1.';
                    titlestr = 'Hawk vs Disc, SC inhibition';
                    allmice_num = 11:16;
                case 2
                    mice_172005_2 %V1
                    perfstr = 'performance_172005.2.';
                    titlestr = 'Hawk vs Disc, V1 inhibition';
                    allmice_num = 11:16;
                case 3
                    mice_172005_3 %LP
                    perfstr = 'performance_172005.3.';
                    titlestr = 'Hawk vs Disc, LP inhibition';
                    allmice_num = 11:16;
            end
            
            for i = allmice_num
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
        title(titlestr)
        hold off
        
end


















