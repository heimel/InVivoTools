function [outstim] = loadstim(MDstim)

if ~haspsychtbox, outstim = MDstim; return; end; % can only load if has psychtoolbox

StimWindowGlobals; NewStimGlobals;

MDstim = unloadstim(MDstim);  % unload old version before loading

 % no error handling yet

MDp = getparameters(MDstim);

fps_act = StimWindowRefresh/max([1 round(StimWindowRefresh/MDp.fps)]);
 
width=MDp.rect(3)-MDp.rect(1);height=MDp.rect(4)-MDp.rect(2);

xCtr=(MDp.rect(1)+MDp.rect(3))/2;yCtr=(MDp.rect(2)+MDp.rect(4))/2;

dotcolor = 1;
bgcolor = 0;

dotSz = round(pixels_per_cm*MDp.distance*tan(MDp.dotsize*pi/180));
nFrames = round(fps_act*MDp.duration);

if strcmp(MDp.motiontype,'planar'),
	dpix_dt = 2*pixels_per_cm*MDp.distance*tan(MDp.velocity*pi/180)*1/fps_act;
	dxdy_dt=repmat(dpix_dt*[cos(pi*MDp.direction/180)/width sin(pi*MDp.direction/180)/height],...
	   MDp.numdots,1);
else, % must be radial
	dr_dt=2/sqrt(width^2+height^2)*pixels_per_cm*MDp.distance*tan(MDp.velocity*pi/180)*1/fps_act*...
			sin(MDp.direction*pi/180);
	dth_dt=MDp.angvelocity*pi/180 * cos(MDp.direction*pi/180)*1/fps_act; % comp. & change to rad
end;

 % handle dot drawing here
 % figure out what dots to draw each frame; must draw background color over all
 % dots in the previous frame and draw foreground color over all new dots

rand('state',MDp.randState);

firstdots = zeros(MDp.numdots,4,MDp.numpatterns);
middledots = zeros(MDp.numdots*2,4,nFrames,MDp.numpatterns);

for NN=1:MDp.numpatterns,

dots_ = 2*(rand(MDp.numdots,2)-0.5); % random array of dot positions in [-1,1]
dots_(:,3) = dotcolor;                      % color table value for dots
dots_(:,4) = dotSz;

firstdots(:,:,NN) = dots_;
prevdots = firstdots(:,:,NN); 
lifetimes = ceil(rand(MDp.numdots,1)*round(fps_act*MDp.lifetimes));
lifetimes(find(lifetimes==0))=round(fps_act*MDp.lifetimes); % catch 0 case
lifetimes = lifetimes-1;

for frame=2:nFrames,
	L = (rand(MDp.numdots,1) < MDp.coherence)&(lifetimes>0);
	currdots = prevdots;
    if strcmp(MDp.motiontype,'planar'),
		currdots(L,[1 2]) = prevdots(L,[1 2])+dxdy_dt(L,:);
		if ~isempty(L),
			outofbounds=L&((abs(currdots(:,1))>1)|(abs(currdots(:,2))>1));
			if sum(outofbounds), % correct anyone out of bounds by making new rand loc
				currdots(outofbounds,[1 2])=2*(rand(sum(outofbounds),2)-0.5);
			end;
		end;
	else, % radial
		outofbounds = [];
		[th,r]=cart2pol(currdots(L,1),currdots(L,2));
		th=th+dth_dt;  r=r+dr_dt;
		if ~isempty(L),
			outofbounds=find((r<0)|(abs(currdots(L,1))>1)|(abs(currdots(L,2))>1));
		end;
		[x,y]=pol2cart(th,r);
		currdots(L,[1 2])=[x y];
		if ~isempty(outofbounds),
			Linds = find(L);
			currdots(Linds(outofbounds),[1 2])=2*(rand(length(outofbounds),2)-0.5);
		end;
	end;
	if sum(~L), currdots(~L,[1 2]) = 2*(rand(sum(~L),2)-0.5); end; % new rand locs
	prevdots(:,3) = bgcolor;
	% sort by y coord so top dots get drawn first; helps in case drawing is slow
	% since computer video refresh goes from top to bottom
	[dummy,topbotorder] = sort(currdots(:,2));
	middledots(1:MDp.numdots,:,frame,NN)=prevdots(topbotorder,:);
	middledots(MDp.numdots+1:end,:,frame,NN)=currdots(topbotorder,:);
	prevdots = currdots;
	lifetimes = lifetimes - 1;
	lifetimes(find(lifetimes<0))=round(fps_act*MDp.lifetimes); % catch 0 case
end;
% map coords to screen
firstdots(:,1,NN) = round(xCtr+firstdots(:,1)*width/2);
firstdots(:,2,NN) = round(yCtr+firstdots(:,2)*height/2);
middledots(:,1,:,NN) = round(xCtr+middledots(:,1,:,NN)*width/2);
middledots(:,2,:,NN) = round(yCtr+middledots(:,2,:,NN)*height/2);
end; %

clut_bg=repmat(MDp.BG,256,1);  depth = 8;
clut_usage=[ 1 ones(1,1) zeros(1,255-1) ]';
clut=[MDp.BG;MDp.FG;repmat(MDp.BG,254,1)];

displayType='custom'; displayProc='dotsstim';

df = struct(getdisplayprefs(MDstim));

drawstim = struct('firstdots',firstdots,'middledots',middledots,...
	'frameLength',max([0 round(StimWindowRefresh/df.fps)]),'numFrames',nFrames,...
	'parameters',MDp,'numpatterns',MDp.numpatterns);
	
global movingdotsstimrecord
clear global movingdotsstimrecord

dS = {'displayType', displayType, 'displayProc', displayProc, ...
        'offscreen', 0, 'frames', nFrames, 'depth', 8, ...
		'clut_usage',clut_usage,'clut_bg',clut_bg,'clut',clut, ...
        'userfield',drawstim};
  
outstim = MDstim;
outstim.stimulus = setdisplaystruct(outstim.stimulus,displaystruct(dS));
outstim.stimulus = loadstim(outstim.stimulus);

