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
%  2005, Alexander Heimel
%

if nargin<6; leg=[]; end
if nargin<5; stim_offset=[]; end
if nargin<4; stim_onset=3;  end % 3 seconds
if nargin<3; frame_duration=0.6;end
if nargin<2; tit=[];end

if isempty(leg)
  clear leg
  for i=1:size(tc,2)
    leg(i,:)=['stim ' char(i+48)];
  end
end

time=(1:size(tc,1))*frame_duration-stim_onset;
%plot(0,0);
co=repmat( linspace(0,0.9,size(tc,2))',1,3);
hold on;
set(gca,'ColorOrder',co);
m='ox+*sdv^<>ph';
for i=1:size(tc,2)
  h=plot(time,tc(:,i),['-' m( mod(i,length(m))+1)]);
 % set(h,'Color',co( mod(i,length(co))+1,:));
end
xlabel('time (s)');
hold on;
ax=axis;
plot( [0 0],[ax(3) ax(4)],'y-');
if ~isempty(stim_offset)
  plot( [stim_offset-stim_onset stim_offset-stim_onset],...
	[ax(3) ax(4)],'y-');
end
ax([1 2])=[time(1) time(end)];
axis(ax);

if leg~=0
	h_leg=legend(leg,0);
else 
	h_leg=[];
end

	
if ~isempty(tit)
  title(tit);
end

  
 
