function h = plot_stimulus_timeline(record,xlims,variable,show_icons,stepped)
%PLOT_STIMULUS_TIMELINE plots onsets and offset of the stimuli from stimsfile
%
%  H = PLOT_STIMULUS_TIMELINE(RECORD,XLIMS,VARIABLE,SHOW_ICONS=false,STEPPED)
%
%     RECORD contains record info to find stims.mat file
%     XLIMS x-limit to show
%     VARIABLE to use as label
%     SHOW_ICONS 
%
% 2014-2017, Alexander Heimel
%

if nargin<5 || stepped
    stepped = true;
end
if nargin<4 || isempty(show_icons)
    show_icons = false;
end
if nargin<3
    variable = [];
end
if nargin<2
    xlims = [];
end

if isfield(record,'MTI2') % record is stimsfile struct
	stimsfile = record;
else
	stimsfile = getstimsfile(record);
end
if isempty(stimsfile)
	return
end
stims = get(stimsfile.saveScript);

if isempty(variable) && isfield(record,'measures') && ~isempty(record.measures) && isfield(record.measures(1),'variable')
    variable = record.measures(1).variable;
end
if isempty(variable)
    variable = varied_parameters(stimsfile.saveScript);
    if length(variable)>1
        logmsg(['Multiple parameters varied. Only showing first: ' variable{1}]);
    end
    if ~isempty(variable)
        variable = variable{1};
    end
end
show_labels = true;
starttime = 0;
stoptime = stimsfile.MTI2{end}.startStopTimes(end)-stimsfile.start;
do  = getDisplayOrder(stimsfile.saveScript);
n_bins = 1000;
tstep = (stoptime-starttime)/n_bins;
imbar = zeros(1,n_bins);
tx= [];
ty = [];
label = {};

ax = axis;
low = ax(3);
high = ax(4);
if stepped 
    steps = 3;
else
    steps = 1;
end

vx = 0;
vy = low;

ax = gca;
pa = get(ax,'position');
for i=1:length(stimsfile.MTI2)
    % on
    vx(end+1) = stimsfile.MTI2{i}.startStopTimes(2)-stimsfile.start;
    vy(end+1) = low;
    vx(end+1) = stimsfile.MTI2{i}.startStopTimes(2)-stimsfile.start;
    vy(end+1) = high;
    % off
    vx(end+1) = stimsfile.MTI2{i}.startStopTimes(3)-stimsfile.start;
    vy(end+1) = high;
    vx(end+1) = stimsfile.MTI2{i}.startStopTimes(3)-stimsfile.start;
    vy(end+1) = low;
    
    tx(end+1) = mean([stimsfile.MTI2{i}.startStopTimes(2) stimsfile.MTI2{i}.startStopTimes(3)])-stimsfile.start;
    ty(end+1) = low+ 0.25*(high-low)*(mod(i,steps)/steps + 0.25);
    
    if ~isempty(variable) && ~strcmp(variable,'position')
        par = getparameters(stims{do(i)});
        label{end+1} = num2str(par.(variable));
        
        if show_icons && tx(end)>xlims(1) && tx(end)<xlims(2)
            if ismethod(stims{do(i)},'stimicon')
                w = 0.05;
                subplot('position',[pa(1)+ pa(3)*(tx(end)-xlims(1))/(xlims(2)-xlims(1))-w/2 pa(2)-w w w])
                stimicon(stims{do(i)});
                show_labels = false;
            elseif ismethod(stims{do(i)},'stimlabel')
                label{end} = stimlabel(stims{do(i)});
            else
                logmsg('No stimicon or stimlabel methods available');
            end
        end
    else
         label{end+1} = num2str(do(i));
    end
    
    imbar( max(1,round((stimsfile.MTI2{i}.startStopTimes(2)-stimsfile.start)/tstep)):min(end,round((stimsfile.MTI2{i}.startStopTimes(3)-stimsfile.start)/tstep))) = ...
        do(i);
end
vx(end+1) = stimsfile.MTI2{end}.startStopTimes(4)-stimsfile.start;
vy(end+1) = low;


vbasey = min(0,min(vy));
ShadingColor = 0.9*[1 1 1];

axes(ax);
h = fill([vx vx(end) vx(1)], [vy vbasey vbasey], ShadingColor); 
set(h,'edgecolor',ShadingColor);
if ~isempty(xlims)
    xlim(xlims);
end
ylim([low high]);

children = get(gca,'children');
set(gca,'children',children(end:-1:1));

if show_labels
    for i = 1:length(label)
        if isempty(xlims) || (tx(i)>xlims(1) && tx(i)<xlims(2))
            ht = text(tx(i),ty(i),label{i},'HorizontalAlignment','center');
        end
    end
end

