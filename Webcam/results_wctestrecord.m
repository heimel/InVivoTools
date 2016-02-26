function results_wctestrecord( record )
%RESULTS_WCTESTRECORD shows measures from webcam record
%
% RESULTS_WCTESTRECORD( RECORD )
%
% 2015-2016, Alexander Heimel

global measures global_record

global_record = record;

experimentpath(record)

measures = record.measures

evalin('base','global measures');
evalin('base','global global_record');
logmsg('Measures available in workspace as ''measures'',, record as ''global_record''.');
%% plots movement trajectory
mousemove = measures.mousemove ;
move2der = measures.move2der;
trajectorylength = measures.trajectorylength;
averagemovement = measures.averagemovement;
minimalmovement = measures.minimalmovement;
diftreshold = measures.diftreshold;
deriv2tresh = measures.deriv2tresh;
fig_n = measures.fign;

my_blue = [0 0.2 0.6];
my_purple = [0.6 0.2 0.6];

if ~isempty(mousemove)
    figure((fig_n+3));
    subplot(2,1,1);
    plot((1:trajectorylength),averagemovement,'--k');hold on;
    plot((1:trajectorylength),minimalmovement+diftreshold,'linestyle' ,'--');
    plot(mousemove,'color',my_blue,'linewidth',2);
    set(gca, 'xtick', (0:30:600), 'XTickLabel', (-10:10),'xgrid','off');
    title('Mouse movement trajectory');
    
    subplot(2,1,2);
    plot([1,trajectorylength],[deriv2tresh,deriv2tresh], '--k'); hold on;
    plot([1,trajectorylength],[-deriv2tresh,-deriv2tresh], '--k');
    plot(move2der, 'color',[0.8 0 0.6],'linewidth',1.4);
    xlabel('seconds'); ylim([-0.7 0.7]);
    set(gca, 'xtick', (0:30:600), 'XTickLabel', (-10:10),'xgrid','on');
    title('2nd derivative of the trajectory');
else
    disp('No trajectory data available');
end
%% plots angles
nose = measures.nose;
arse = measures.arse;
stim = measures.stim;
head_theta = measures.head_theta;
pos_theta = measures.pos_theta;
L = size(nose,1);

for k = 1:L;
    arse_a(k, :) = arse(k,:) - nose(k,:);  %THE COORDINATES ALIGNED TO NOSE
    nose_a(k, :) = nose(k,:) - nose(k,:);
    if ~isempty(nose) && ~isempty(arse)
        figure(k+(fig_n+4));
        plot([0, nose_a(k,1)], [0, nose_a(k,2)],'v','MarkerSize',8,...
            'MarkerFaceColor', my_blue); hold on;
        grid on; extent1 = abs(arse_a)+50; ax1= max(max(extent1));
        plot([-ax1 ax1],[0 0],'--k',[0 0],[-ax1 ax1],'--k');hold on;
        text(-15,-30,'nose','color',my_blue, 'fontweight', 'b', 'BackgroundColor','w');
        plot([0, arse_a(k,1)], [0, arse_a(k,2)], 'linewidth',3,'color',my_blue); hold on;
        
        head_txt = text(50,(ax1-10),sprintf('head \\theta = %.1f%c',head_theta(k),...
            char(176)),'color',my_blue, 'fontweight', 'b', 'BackgroundColor','w'); %char(176) is deg
        if ~isempty(stim);
            stim_present = any(stim,2);
            if stim_present(k)== 1
                figure(k+(fig_n+4));
                stim_a(k, :) = stim(k,:) - nose(k,:);
                plot([0, stim_a(k,1)], [0, stim_a(k,2)], 'linewidth',3,...
                    'color',my_purple); hold on;
                grid on;
                extent = abs(stim_a)+60; ax= max(max(extent));
                plot([-ax ax],[0 0],'--k',[0 0],[-ax ax],'--k');
                set(head_txt, 'Position',[50 (extent(2))] );
                text(50,(extent(2)-50),sprintf('position \\theta = %.1f%c',pos_theta(k),...
                    char(176)),'color',my_purple, 'fontweight', 'b', 'BackgroundColor','w');
                
                %             plot ang arc
                %                     angle_arc_plot([0,0],30,[deg2rad(get_ang(hor,arse_a(k)))
                %                     deg2rad(get_ang...
                %                         (hor,stim_a(k)))],'-','b',2);
            end
        end
    else
        disp('No mouse coordinates available');
    end
end