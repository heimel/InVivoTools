function plot_stimulus_timeline(record,xlims)
%PLOT_STIMULUS_TIMELINE plots onsets and offset of the stimuli from stimsfile
%
% 2014, Alexander Heimel
%

if nargin<2
    xlims = [];
end

stimsfile = getstimsfile(record);
stims=get(stimsfile.saveScript);
variable = varied_parameters(stimsfile.saveScript);
if length(variable)>1
    logmsg(['Multiple parameters varied. Only showing first: ' variable{1}]);
end
if ~isempty(variable)
    variable = variable{1};
end

vx = [0];
vy = [0];

starttime = 0;
stoptime = stimsfile.MTI2{end}.startStopTimes(end)-stimsfile.start;
do  = getDisplayOrder(stimsfile.saveScript);
n_bins = 1000;
tstep = (stoptime-starttime)/n_bins;
imbar = zeros(1,n_bins);
tx= [];
ty = [];
stimlabel = {};
for i=1:length(stimsfile.MTI2)
    % on
    vx(end+1) = stimsfile.MTI2{i}.startStopTimes(2)-stimsfile.start;
    vy(end+1) = 0;
    vx(end+1) = stimsfile.MTI2{i}.startStopTimes(2)-stimsfile.start;
    vy(end+1) = 1;
    % off
    vx(end+1) = stimsfile.MTI2{i}.startStopTimes(3)-stimsfile.start;
    vy(end+1) = 1;
    vx(end+1) = stimsfile.MTI2{i}.startStopTimes(3)-stimsfile.start;
    vy(end+1) = 0;
    
    tx(end+1) = mean([stimsfile.MTI2{i}.startStopTimes(2) stimsfile.MTI2{i}.startStopTimes(3)])-stimsfile.start;
    ty(end+1) = (mod(i,3)/4)+0.25;
    
    if ~isempty(variable) 
        par = getparameters(stims{do(i)});
    end
    stimlabel{end+1} = num2str(par.(variable));
    
    imbar( max(1,round((stimsfile.MTI2{i}.startStopTimes(2)-stimsfile.start)/tstep)):min(end,round((stimsfile.MTI2{i}.startStopTimes(3)-stimsfile.start)/tstep))) = ...
        do(i);
end
vx(end+1) = stimsfile.MTI2{end}.startStopTimes(4)-stimsfile.start;
vy(end+1) = 0;


h = plot(vx,vy,'k-');
vbasey = min(0,min(vy));
ShadingColor = 0.8*[1 1 1];
h = fill([vx vx(end) vx(1)], [vy vbasey vbasey], ShadingColor); 
for i = 1:length(stimlabel)
    if isempty(xlims) || (tx(i)>xlims(1) && tx(i)<xlims(2))
        ht = text(tx(i),ty(i),stimlabel{i},'HorizontalAlignment','center');
    end
end
ylim([0 1.3]);
set(gca,'ytick',[])
box off
if ~isempty(xlims)
    xlim(xlims);
end


%     imbarcol = zeros(1,size(imbar,2),3);
%     colmap = [0 0 1;0 1 0;1 0 0; 0 1 1;1 0 1;1 1 0];
%     for i=1:size(imbar,2);
%         if imbar(i)==0
%             imbarcol(1,i,:) = [ 1 1 1];
%         else
%        imbarcol(1,i,:) = colmap(mod(imbar(i)-1,size(colmap,1))+1,:); 
%         end
%     end
%     
%     figure;
%     image(imbarcol);
%     
    
    keyboard
