function tpplotraw( record)
%TPPLOTRAW plots calcium cell data
%
%  2014, Alexander Heimel
%

if ~isfield(record,'measures') || isempty(record.measures) || ~isfield(record.measures,'raw_t')
    return
end

process_params = tpprocessparams(record);

figname = [record.mouse ', ' record.date ', ' record.epoch ' - raw'];

figure('Name',figname,'NumberTitle','off');

colors={[1 0 0],[0 1 0],[0 0 1],[1 1 0],[0 1 1],[1 0 1],[0.5 0 0],[0 0.5 0],[0 0 0.5],[0.5 0.5 0],[0.5 0.5 0.5]};

% curves
switch process_params.method
    case 'event_detection'
        stack_lines = 0;
        marker = '.';
        linestyle = 'none';
        ylab = 'Peak \Delta F/F';
        n_panelrows = 2;
    case 'normalize'
        stack_lines = 1;
        marker='none';
        linestyle = '-';
        ylab = '\Delta F/F';
        n_panelrows = 1;
    case 'none'
        stack_lines = 0;
        marker='none';
        linestyle = '-';
        ylab = 'F';
        n_panelrows = 1;
end

if ~isempty(record)
    n_panelrows = n_panelrows + 0;
end

h_traces  = subplot(n_panelrows,1,1);

hold on;
for i=1:length(record.measures)
    ind=mod(i-1,length(colors))+1;
    plot(record.measures(i).raw_t, ...
        record.measures(i).raw_data + stack_lines * (i-1) * 0.2 ,...
        'line',linestyle,'color',colors{ind},'marker',marker);
end
ylabel(ylab);
xlabel('Time (s)');
xlims = xlim;

% show data as color image
% subplot(n_panelrows,2,2);
%
% imgdata = [];
% markers = [];
% marker_labels = {};
% marker_index = 1;
%
% for i = 1:length(record.measures)
%     imgdata = [imgdata; record.measures(i).data];
% end
% imagesc(imgdata);
% set(gca,'YDir','normal')
% set(gca,'Xtick',markers);
% set(gca,'Xticklabel',marker_labels);
% ylabel('Cell');
% xlabel('Time (ks)');
% colormap jet

% global events
switch process_params.method
    case 'event_detection'
        participating_fraction=[];
        global_t = [];
        for interval = 1:size(data,1)
            participating_fraction = [participating_fraction; mean([data{interval,:}]>0,2)];
            global_t = [global_t;nanmean([t{interval,:}],2)];
        end
        
        if isempty(timeint)
            timeint = [-inf inf];
        end
        y = {};
        x = {};
        for i = 1:size( timeint,1 )
            log_ind = (global_t > timeint(i,1) & global_t<timeint(i,2));
            y{i} = participating_fraction(log_ind);
            x{i} = global_t(log_ind);
        end
        
        % plot fraction vs time
        subplot(n_panelrows,2,3);
        hold on
        for i=1:length(x)
            plot(x{i},y{i},'.','color',colors{i});
        end
        ylabel('Participating fraction');
        xlabel('Time (s)');
        mark_intervals( timeint )
        ylim([0 1]);
        
        % plot cumhistograms for each requested interval
        h=subplot(n_panelrows,2,4);
        
        graph(y,[],'style','cumul','axishandle',h,...
            'xlab','Participating fraction','ylab','Fraction',...
            'color',colors);
        bigger_linewidth(-4);
        smaller_font(14);
        ylim([0 1]);
        
end

if ~isempty(record)
%    h_timeline = subplot(n_panelrows,1,((n_panelrows-1)*1)+1);
    plot_stimulus_timeline(record,xlims);
%    p_traces = get(h_traces,'position');
 %   p_timeline = get(h_timeline,'position');
 %   p_timeline(4) = 0.1;
 %   p_timeline(2) = p_traces(2)-p_timeline(4);
 %   set(h_timeline,'position',p_timeline);
 %   set(h_traces,'xtick',[]);
end

return

function mark_intervals( timeint, h)
hold on;
if nargin<2
    h = gca;
end

ax = axis(h);
for i = 1:size(timeint,1)
    line( [timeint(i,1) timeint(i,1)],[ax(3) ax(4)],'color',[0 1 0]);
    line( [timeint(i,2) timeint(i,2)],[ax(3) ax(4)],'color',[1 0 0 ]);
    text( timeint(i,1), ax(3)-0.05*(ax(4)-ax(3)), ' >','HorizontalAlignment','right');
    text( timeint(i,2), ax(3)-0.05*(ax(4)-ax(3)), '< ','HorizontalAlignment','left');
end







