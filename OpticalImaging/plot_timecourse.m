function h_leg=plot_timecourse(tc,tit,frame_duration,stim_onset,stim_offset,leg)
%PLOT_TIMECOURSE for optical imaging stimulus
%
%  H_LEG=PLOT_TIMECOURSE(TC,TIT,FRAME_DURATION,STIM_ONSET,LEG)
%       TC = frames x stimulus timecourse array
%       TIT = title
%       STIM_ONSET = time of stimulus onset (in s if timescale is set)
%       LEG = legend string array
%       FRAME DURATION = frame duration in seconds
%       H_LEG is legend handle
%
%  2005-2019, Alexander Heimel
%

if nargin<6 || isempty(leg)
    leg = cell(size(tc,2),1);
    for i=1:size(tc,2)
        leg{i} = ['stim ' char(i+48)];
    end
elseif leg == false
    leg = {};
end

if nargin<5 
    stim_offset=[]; 
end
if nargin<4
    stim_onset = 3; % seconds 
end 
if nargin<3
    frame_duration=0.6;% seconds
end
if nargin<2
    tit=[];
end

time = (1:size(tc,1))*frame_duration-stim_onset;
hold on 
if size(tc,2)>1
    co = repmat( linspace(0,0.8,size(tc,2))',1,3);
    set(gca,'ColorOrder',co);
end
m = 'ox+*sdv^<>ph';
for i=1:size(tc,2)
    plot(time,tc(:,i),['-' m( mod(i,length(m))+1)]);
end
xlabel('Time (s)');
hold on
ax = axis;
plot( [0 0],[ax(3) ax(4)],'y-');
if ~isempty(stim_offset)
    plot( [stim_offset-stim_onset stim_offset-stim_onset],...
        [ax(3) ax(4)],'y-');
end
ax([1 2]) = [time(1) time(end)];
axis(ax);

if ~isempty(leg)
    h_leg = legend(leg,'location','northwest');
else
    h_leg = [];
end

if ~isempty(tit)
    title(tit);
end



