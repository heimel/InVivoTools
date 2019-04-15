function perfplots(exp)

logmsg('THERE IS ALSO ANOTHER VERSION PERFPLOTS2 OF THIS. CHECK OUT THE DIFFERENCES (2019-02-20)' );


% Makes performance figures for mice 14.13 group 2 and 172002
% works in 2016a
% Azadeh October 2017
% October 2018
my_colours;
switch exp
    case 14.13
        mice_1413;
        n_mice = length(mice);
        
        mean_dur = NaN(1, 30, 2, n_mice);
        % val_pos_theta = NaN(200,n_mice);
        % val_head_theta = NaN(200,n_mice);
        
        for i = 14
            %     1:n_mice
            subj = mice(i);
            exp = 14.13;
            %             manualfrzdata(subj, exp)
            
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
            save (['performance_14.13.2.' num2str(i) '.mat'], 'perf_col');
            
            figure(i);
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
            phand_dur = plot(mean_dur(:,:,1,i), '-.h', 'color',my_peru, 'linewidth', 1.2);
            
            ax2 = gca;
            ax2.YColor = 'k';
            ylim(ax2,[0 1]);
            ylabel('freezing duration(s)', 'FontSize', 18);
            legend([a(1),b],'habituating stim', 'mean freezing duration','FontSize',15,'FontWeight','bold', 'Textcolor', grey_30);
            %             legend([bhand_perf(1),phand_dur],'hab', 'mean dur hab');
            legend('boxoff');
            %
            %             if any(~isnan(mean_dur(:,:,2,i)))
            %                 plot(mean_dur(:,:,2,i), '-.*', 'color',my_darkturquoise, 'linewidth', 1.2);
            %                 legend('hab','novel', '\mu dur hab', '\mu dur nov');
            %                 legend('boxoff');
            %             end
        end
       
    case 172002
        mice_172002;
        n_mice = length(mice);
        
        mean_dur = NaN(1, 30, 2, n_mice);
        
        for i = 34 %2d: [37:46], aspect ratio: [1:2,5:12], surface area: [13,15,17:24,35,36], acicularity: [25:34]
            %             1:n_mice
            i
            %     1:n_mice
            subj = mice(i);
            exp = 172002.1;
            expname = 'acicularity';
            manualfrzdata(subj, exp, expname)
            
            if exist (['man_frz_dur_172002.1.0' num2str(i) '.mat'], 'file')~= 0
                load(['man_frz_dur_172002.1.0' num2str(i) '.mat']);
            elseif exist (['man_frz_dur_172002.1.' num2str(i) '.mat'], 'file')~= 0
                load(['man_frz_dur_172002.1.' num2str(i) '.mat']);
            else
                warning('Freeze duration file does not exist. Get data from manualfrzdata.m');
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
            ses_num = sum(~isnan(perf_col));
            save (['performance_172002.1.' num2str(i) '.mat'], 'perf_col');
            %             load(['performance_172002.1.', num2str(i),'.mat']);
            perf_col = perf_col*100;      
            
            figure(i);
            if any(~isnan(perf_col(:,2)))
                bhand_perf = bar(perf_col);
                set(bhand_perf(1),'FaceColor',my_burlywood, 'edgecolor', grey_30,'LineWidth',2);
                set(bhand_perf(2),'FaceColor',my_turquoiseblue, 'edgecolor', grey_30,'LineWidth',2);
            else
                bhand_perf = bar(perf_col(:,1));
                set(bhand_perf,'FaceColor',my_burlywood, 'edgecolor', grey_30,'LineWidth',2);
            end
            
            ylim([0, 100])
            %     ax1 = gca;
            %     ax1.YTick = 0:0.05:1;
            %     ax1.YGrid = 'on';
            %     ax1.GridLineStyle = ':';
            %             xlim([0 max(ses_num)+1]);
            xlim([0 7])
            box off
            %             title(['Surface area test, mouse 172002.1.' num2str(i)], 'FontSize', 18);
            title('two dimensions', 'FontSize', 20);
            ylabel('freezing (%)', 'FontWeight','bold');
            xlabel('Time(sessions)', 'FontWeight','bold');
            ax = gca;
            ax.XAxis.FontSize = 20;
            ax.XAxis.FontWeight = 'bold';
            ax.YAxis.FontSize = 20;
            ax.YAxis.FontWeight = 'bold';
            set(gca,'Xcolor', grey_30,'Ycolor', grey_30,'LineWidth',3, 'FontWeight','bold');
            hold on
            yyaxis 'right';
            phand_dur = plot(mean_dur(:,:,1,i), '-.h', 'color',my_peru, 'linewidth', 1.2,'markerSize',9);
            ax2 = gca;
            ax2.YColor = grey_30;
            ylim(ax2,[0 2.1]);
            ylabel('freezing duration(s)', 'FontWeight', 'bold');
            set(gca,'Ycolor', grey_30,'LineWidth',3, 'FontSize', 20,'FontWeight','bold');

            if any(~isnan(mean_dur(:,:,2,i)))
                plot(mean_dur(:,:,2,i), '-.*', 'color',my_darkturquoise, 'linewidth', 1.2);
                legend({'habituating','novel', '\mu duration hab', '\mu duration nov'}, 'FontSize', 18);
                legend('boxoff');
            else 
%                  legend([bhand_perf(1),phand_dur],{'habituating', '\mu duration hab', 'FontSize'}, 18);
            legend({'habituating','novel'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30);
% legend
                 legend('boxoff');
            end
        end
            
    case 172005
        group = 1;
            switch group
                case 1
                    mice_172005_1 %SC
                    filestr1 = 'man_frz_dur_172005.1.0' ;
                    filestr2 = 'man_frz_dur_172005.1.' ;
                    perfstr = 'performance_172005.1.';
                    titlestr = 'Hawk vs Disc, SC inhibition, 172005.1.';
                case 2
                    mice_172005_2 %V1
                    filestr1 = 'man_frz_dur_172005.2.0' ;
                    filestr2 = 'man_frz_dur_172005.2.' ;
                    perfstr = 'performance_172005.2.';
                    titlestr = 'Hawk vs Disc, V1 inhibition, 172005.2.';
                case 3
                    mice_172005_3 %LP
                    filestr1 = 'man_frz_dur_172005.3.0' ;
                    filestr2 = 'man_frz_dur_172005.3.' ;
                    perfstr = 'performance_172005.3.';
                    titlestr = 'Hawk vs Disc, LP inhibition, 172005.3.';
            end
        n_mice = length(mice);
        
        mean_dur = NaN(1, 30, 2, n_mice);
        % val_pos_theta = NaN(200,n_mice);
        % val_head_theta = NaN(200,n_mice);
        
        for i = [15,16,19:22]
            i
            %     1:n_mice
            subj = mice(i);
            exp = 172005.1;
            manualfrzdata(subj, exp)
            
            if exist (['man_frz_dur_172005.1.0' num2str(i) '.mat'], 'file')~= 0
                load(['man_frz_dur_172005.1.0' num2str(i) '.mat']);
            elseif exist (['man_frz_dur_172005.1.' num2str(i) '.mat'], 'file')~= 0
                load(['man_frz_dur_172005.1.' num2str(i) '.mat']);
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
            save (['performance_172005.1.' num2str(i) '.mat'], 'perf_col');
            
            figure(i);
            if any(~isnan(perf_col(:,2)))
                bhand_perf = bar(perf_col);
                set(bhand_perf(1),'FaceColor',my_burlywood, 'edgecolor', grey_30,'LineWidth',2);
                set(bhand_perf(2),'FaceColor',my_turquoiseblue, 'edgecolor', grey_30,'LineWidth',2);
            else
                bhand_perf = bar(perf_col(:,1));
                set(bhand_perf,'FaceColor',my_burlywood, 'edgecolor', grey_30,'LineWidth',2);
            end
            title(['Hawk vs Disc, SC inhibition, 172005.1.' num2str(i)]);
            
            ax = gca;
            ax.XAxis.FontSize = 20;
            ax.XAxis.FontWeight = 'bold';
            ax.YAxis.FontSize = 20;
            ax.YAxis.FontWeight = 'bold';
            set(gca,'Xcolor', grey_30,'LineWidth',3, 'FontWeight','bold');
            ylim([0, 1]);
            xlim([0 8]);
            %             xlim([0 max(ses_num)+1]);
            box off
            yyaxis 'right'
            ylim([0 2.1]);
            ax.YTick = 0.5:0.5:2;
            yax1 = ax.YAxis(1);
            yax1.Color = grey_30;
            set(gca,'Ycolor', grey_30,'LineWidth',3, 'FontWeight','bold');
            %     ax1 = gca;
%                 ax1.YTick = 0:0.05:1;
            %     ax1.YGrid = 'on';
            %     ax1.GridLineStyle = ':';    
            xlabel('Time(sessions)');
            ylabel('Propotion freezing');
 
            hold on
            phand_dur = plot(mean_dur(:,:,1,i), '-.h', 'color',my_peru, 'linewidth', 1.2,'markerSize',9);
            ylabel('freezing duration(s)', 'FontWeight', 'bold');
            set(gca,'Ycolor', grey_30,'LineWidth',3, 'FontSize', 20,'FontWeight','bold');
%             legend([bhand_perf(1),phand_dur],'habituating', '\mu duration hab', 'FontSize', 18);
%             legend({'habituating','novel'},'FontSize',15,'FontWeight','bold', 'Textcolor', grey_30);
%             legend('boxoff');
            
            if any(~isnan(mean_dur(:,:,2,i)))
                plot(mean_dur(:,:,2,i), '-.*', 'color',[0.4 0.8 0.6], 'linewidth', 1.2);
                legend('hab','novel', '\mu dur hab', '\mu dur nov');
                legend('boxoff');
            end
            end
end

