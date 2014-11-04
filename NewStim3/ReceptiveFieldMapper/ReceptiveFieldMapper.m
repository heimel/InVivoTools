function ReceptiveFieldMapper
%
%  ReceptiveFieldMapper
%
%  ReceptiveFieldMapper is a tool for finding receptive fields.  There are two
%  stimuli, a constant field and a bar, which are moveable by the keyboard and
%  the mouse.  The size and shape of the field are adjustable via the keyboard,
%  and the size, orientation, width, and length of the bar are also adjustable via
%  the keyboard.  The user may also hide the stimulus, display it blinking at 2Hz,
%  and move it around with the mouse.  An on-line menu is available and is reproduced
%  (with slightly more description) here.
%
%  Modes (press the appropriate key to put the mapper into the appropriate mode):
%
%  l   - adjust location w/ keyboard
%  z   - adjust rectangle size of stimulus w/ keyboard
%  m   - track the stimulus with the mouse (ends with a click)
%  c   - adjust the contrast w/ keyboard
%  o   - toggle between a rectangle and an oval for the field stim, or adjust
%         orientation for the bar stim
%  b   - switch to bar stim
%  f   - switch to field stim
%  w   - adjust width/height of bar
%  h   - hide the stimulus
%  a   - auto-hide the stimulus at 2Hz (i.e., blink)
%  x   - exit
%  Esc - display menu (use any key to exit)
%
%  One adjusts the above parameters with the same set of keys.  One can make
%  fine, medium, or coarse adjustments.
%
%  ,/.;/'                      left/right/up/down fine
%  (arrows)                    left/right/up/down medium
%  help/home/pg up/pg dn       left/right/up/down coarse
%
%  Requires the NewStim package

if ~haspsychtbox,error('ReceptiveFieldMapper requires PsychToolbox.'); end;

FlushEvents(['keyDown']);
ReceptiveFieldGlobals;

try, delete runit.m
catch, end;
cd(pwd);
	
StimWindowGlobals;
ShowStimScreen; Screen(StimWindow,'FillRect',0);

if isempty(RFcurrentrect),RFcurrentrect=[0 0 100 100];
else,RFcurrentrect=rectofinter(StimWindowRect,RFcurrentrect);end;

 %initialize parameters
if isempty(RFparams),
	PSparams=struct('rect',RFcurrentrect,...
        'imageType',0,'animType',0,'angle',0,'sFrequency',4,'sPhaseShift',0,...
	'tFrequency',StimWindowRefresh,'barWidth',0.5000,'nCycles',1,'contrast',1,...
	'background',0.5000,'backdrop',0.0000,'barColor',1,'nSmoothPixels',2,...
        'fixedDur',0,'windowShape',0,'flickerType',0,'distance',57,'chromhigh',[255 255 255],'chromlow',[0 0 0]);
	PSparams.dispprefs = {'BGpretime',-1,'BGposttime',-1},
	LBparams = struct('rect',RFcurrentrect,'shape',0,'points',[10 5],...
	'distance',57,'units',1,'orientation',45,...
        'howlong',1/75,'backdrop',[0 0 0],'background',[0 0 0],...
        'foreground',[255 255 255],'contrast',1,'remove',[0 0],...      
        'offsetxy',[0 0],'offsettheta',0,'smooth',2);
	LBparams.dispprefs = {'BGpretime',-1,'BGposttime',-1};
	
	RFparams = struct('state',2,'mode',0,...
	'drawrect',RFcurrentrect,'stim',1,'draw',1);
	RFparams.stims = {periodicstim(PSparams), polygonstim(LBparams)};
else,
	RFparams.mode = 0; RFparams.state = 2;
	RFparams.stims{1}=repositionstim(RFparams.stims{1},...
		{'rect',RFcurrentrect,'params',1}); % shouldn't fail
	RFparams.stims{2}=repositionstim(RFparams.stims{2},...
		{'rect',RFcurrentrect,'params',1}); % shouldn't fail
end;

lastrect = RFcurrentrect;
screencleared = 1;
sscript = loadstimscript(append(stimscript(5),RFparams.stims{RFparams.stim}));
MTI=DisplayTiming(sscript); Screen(StimWindow,'SetClut',MTI{1}.ds.clut{1});
r = RFcurrentrect;
c = getparameters(RFparams.stims{1}); c = c.contrast;
n=0; firsttime = 1;
curmouse=[0 0];
nt = 0; nmt = 0; nft = 0; aht = 0;
 % add other stims later

 % main loop

 
  HideCursor;

  while(RFparams.state~=0),
	dir=0;big=2; adj=0; rl=0;
	[b,nt] = checkkeyboard(nt,RFparams.state);
	if b,
		c = GetChar;
		switch(double(c)),
			case 104, % h
				RFparams.draw = 1-RFparams.draw;
			case 108, % l
				RFparams.mode = 1;
			case 99, % c
				RFparams.mode = 2;
			case 122, % z
				RFparams.mode = 3;
			case 115, %s
				RFparams.mode = 4;
			case 120, RFparams.state = 0; % x
			case 111, RFparams.mode = 5, % o
			case 119, RFparams.mode = 6; % w
			case 97, RFparams.mode = 7; aht = getsecs; % auto-hide at 2Hz
			case 27, domenu; % Esc
			case 109, RFparams.state = 3; FlushEvents('mouseUp'); % m - mouse
			% arrow keys and whatnot, get keys from computer
			case 28, adj=1; dir=pi;     big=2; % left arrow
			case 29,adj=1; dir=0;      big=2;  % right arrow
			case 30,   adj=1; dir=pi/2;   big=2; % up arrow
			case 31, adj=1; dir=3*pi/2; big=2; % down arrow
			case 11,      adj=1; dir=pi/2;   big=3; % pgup
			case 12,    adj=1; dir=3*pi/2; big=3; % pgdown
			case 1,      adj=1; dir=0;      big=3; % home
			case 5,    adj=1; dir=pi;     big=3; % help, maybe also end
			case 44,      adj=1; dir=pi;      big=1; % comma
			case 46,    adj=1; dir=0;     big=1; % period
			case 59, adj=1; dir=3*pi/2; big=1; % semicolon
			case 39, adj=1; dir=pi/2; big=1; % apostrophie
			case 102, adj = 1; RFparams.stim = 1; RFparams.mode =0;
					s=RFparams.stim; rl=1;
					RFparams.stims{s}=repositionstim(RFparams.stims{s},...
						{'rect',RFcurrentrect,'params',1}); % shouldn't fail
			case 98, adj = 1; RFparams.stim = 2; RFparams.mode = 0;
					s=RFparams.stim; rl=1;
					RFparams.stims{s}=repositionstim(RFparams.stims{s},...
						{'rect',RFcurrentrect,'params',1}); % shouldn't fail
		end;
		if adj,
			switch RFparams.mode,
				case 0, % don't do anything
				case 1, movestim(dir,big);
				case 2, stepcontrast(cos(dir),big);
				case 3, resizestim(dir,big);
				case 5, steporientation(cos(dir),big);
				case 6, stepwidthheight(dir,big);
			end;
			if RFparams.stim==1,rl=1;end;
			if (RFparams.mode~=1)|rl==1,
				sscript=loadstimscript(set(sscript,RFparams.stims{RFparams.stim},1));
			else,
				par=getparameters(RFparams.stims{RFparams.stim}); par.rect,
				dp=(getdisplayprefs(get(sscript,1)));
				dp = setvalues(dp,{'rect',par.rect});
				sscript=set(sscript,setdisplayprefs(get(sscript,1),dp),1);
			end;
			MTI=DisplayTiming(sscript);
			Screen(StimWindow,'SetClut',MTI{1}.ds.clut{1});
			%Screen(StimWindow,'WaitBlanking');
			%Screen(StimWindow,'FillRect',0,lastrect); lastrect=RFcurrentrect;
		end;
	elseif RFparams.state==3, % tight loop, hard to follow
		[b,nmt]=checkmouse(nmt,1);
		if b,
			RFparams.state = 2; FlushEvents('mouseUp');
			% update params, this can be slow
			RFparams.stims{1}=repositionstim(RFparams.stims{1},...
						{'rect',RFcurrentrect,'params',1}); % shouldn't fail
			RFparams.stims{2}=repositionstim(RFparams.stims{2},...
						{'rect',RFcurrentrect,'params',1}); % shouldn't fail			
		else,
			[x,y]=GetMouse(StimWindow);
			if (x~=curmouse(1))|(y~=curmouse(2)), adj = 1; curmouse = [ x y]; end;
		end;
		if adj, % just update MTI for speed since window size can't change
			%setstimposition(x,y);
			%if RFparams.stim==1,
			%	sscript=loadstimscript(set(sscript,RFparams.stims{RFparams.stim},1));
			%	MTI=DisplayTiming(sscript);
			%
			%else,
			%	par=getparameters(RFparams.stims{RFparams.stim});
			%	dp=(getdisplayprefs(get(sscript,1)));
			%	dp = setvalues(dp,{'rect',par.rect});
			%	sscript=set(sscript,setdisplayprefs(get(sscript,1),dp),1);
			r = RFcurrentrect;
			dx=fix(x-0.5*(r(3)+r(1))); dy = fix(y-0.5*(r(4)+r(2)));
			dx=-(dx<0)*min([-dx r(1)])+(dx>0)*min([dx StimWindowRect(3)-r(3) ]);
			dy=-(dy<0)*min([-dy r(2)])+(dy>0)*min([dy StimWindowRect(4)-r(4) ]);
			RFcurrentrect=RFcurrentrect+round([dx dy dx dy]);
			MTI{1}.df.rect = RFcurrentrect;
			%end;
		end;
	elseif ~adj&(getsecs-nft)>5,
		cd(pwd); txt=checkscript('runit.m'); ntf=getsecs;
		if ~isempty(txt),
			adj=1;
			evalin('base',txt); % eval and update
			cd(pwd); % try to flush writingx
			RFparams.stims{1}=repositionstim(RFparams.stims{1},...
						{'rect',RFcurrentrect,'params',1}); % shouldn't fail
			RFparams.stims{2}=repositionstim(RFparams.stims{2},...
						{'rect',RFcurrentrect,'params',1}); % shouldn't fail
			sscript=loadstimscript(set(sscript,RFparams.stims{RFparams.stim},1));
			MTI=DisplayTiming(sscript);
			Screen(StimWindow,'SetClut',MTI{1}.ds.clut{1});
			delete runit.m; nft=getsecs;
			HideCursor;
		end;
	end;
	if adj==0,
		if RFparams.mode==7,
			if (getsecs-aht)>0.5, RFparams.draw = 1-RFparams.draw; aht = getsecs; end;
		end;
		if RFparams.draw|firsttime, blastMTI(MTI); firsttime=0;
		else, Screen(StimWindow,'FillRect',0); end;
	else,
		if RFparams.draw, blastMTIlr(MTI,lastrect); %DisplayStimScript(sscript,MTI,0,lastrect);
		else, Screen(StimWindow,'FillRect',0); end;	
		lastrect = RFcurrentrect;
	n=n+1;
	end;
	
end;
n;
RFcurrentrect;r;
sscript = unloadstimscript(sscript);
ShowCursor;
CloseStimScreen;

function [b,nt]=checkkeyboard(no,state)
switch state,
	case 3,
		%if(getsecs-no)>3, b=CharAvail; nt = getsecs;
		%else, b = 0; nt = no; end;
		b = 0; nt = no;
	otherwise,
		b = CharAvail; nt = getsecs;
end;
	
function [b,nmt]=checkmouse(no,state)
switch state,
	case 3,
		if(getsecs-no)>0.1, b=EventAvail('mouseUp'); nmt = getsecs;
		else, b = 0; nmt = no; end;
	otherwise,
		b = EventAvail('mouseUp'); nmt = getsecs;
end;
	
function blastMTIlr(MTI,lastrect)
StimWindowGlobals;ReceptiveFieldGlobals;
Screen(StimWindow,'WaitBlanking');
Screen(StimWindow,'FillRect',0,lastrect);
if MTI{1}.ds.makeClip,Screen(StimWindow,'SetDrawingRegion',RFcurrentrect,MTI{1}.ds.makeClip-1); end;
Screen('CopyWindow',MTI{1}.ds.offscreen,StimWindow,...
	MTI{1}.df.rect-[MTI{1}.df.rect(1) MTI{1}.df.rect(2) MTI{1}.df.rect(1) MTI{1}.df.rect(2)],...
	MTI{1}.df.rect,'srcCopy');
if MTI{1}.ds.makeClip,Screen(StimWindow,'SetDrawingRegion',StimWindowRect); end;

function blastMTI(MTI)
StimWindowGlobals;ReceptiveFieldGlobals;
Screen(StimWindow,'WaitBlanking');
if MTI{1}.ds.makeClip,Screen(StimWindow,'SetDrawingRegion',RFcurrentrect,MTI{1}.ds.makeClip-1); end;
Screen('CopyWindow',MTI{1}.ds.offscreen,StimWindow,...
	MTI{1}.df.rect-[MTI{1}.df.rect(1) MTI{1}.df.rect(2) MTI{1}.df.rect(1) MTI{1}.df.rect(2)],...
	MTI{1}.df.rect,'srcCopy');
if MTI{1}.ds.makeClip,Screen(StimWindow,'SetDrawingRegion',StimWindowRect); end;

function domenu
StimWindowGlobals;
ulx = StimWindowRect(3)-600; uly = StimWindowRect(4)-600;
Screen(StimWindow,'FillRect',0);
Screen(StimWindow,'TextSize',24);
Screen(StimWindow,'DrawText','ReceptiveFieldMapper menu',ulx,uly);
width = Screen(StimWindow,'TextWidth','ReceptiveFieldMapper menu');
Screen(StimWindow,'TextSize',18);
Screen(StimWindow,'DrawText','modes:',ulx+0.5*width-25,uly+25);
Screen(StimWindow,'DrawText','l - adj. location',ulx-50,uly+50);
Screen(StimWindow,'DrawText','z - adj. rect size',ulx-50,uly+75);
Screen(StimWindow,'DrawText','c - adj. contrast',ulx-50,uly+100);
Screen(StimWindow,'DrawText','b - switch to bar',ulx-50,uly+125);
Screen(StimWindow,'DrawText','o - adj. orientation (bar) or rect/oval (field)',ulx+0.5*width-25,uly+50);
Screen(StimWindow,'DrawText','w - adj. width/length of bar',ulx+0.5*width-25,uly+75);
Screen(StimWindow,'DrawText','h - toggle hide',ulx+0.5*width-25,uly+100);
Screen(StimWindow,'DrawText','a - auto-hide at 2Hz (blink)',ulx+0.5*width-25,uly+125);
Screen(StimWindow,'DrawText','m - track with mouse until click',ulx+0.5*width-25,uly+150);
Screen(StimWindow,'DrawText','x - exit',ulx-50,uly+150);
Screen(StimWindow,'DrawText','adjustment keys:',ulx+0.5*width-50,uly+175);
Screen(StimWindow,'DrawText',',/./;/'' - small adjust left/right/up/down',ulx-50,uly+200);
Screen(StimWindow,'DrawText','(arrows) - med. adjust left/right/up/down',ulx-50,uly+225);
Screen(StimWindow,'DrawText','help/home/pageup/pagedown - big adjust left/right/up/down',ulx-50,uly+250);

while ~EventAvail(['mouseUp'],['keyDown']), end;
FlushEvents(['mouseUp'],['keyDown']);
Screen(StimWindow,'FillRect',0);

%	c1 = getparameters(RFparams.stims{1}); c1 = c1.contrast;
%	if c~=c1, c = c1, end;
%	if ~prod(r==RFcurrentrect),RFcurrentrect,r=RFcurrentrect; end;

%  menu -
%    x - exit
%    m - start mouse tracking, ends with a click
%    h - hide stim *
%    s - change stimulus to f) field, b) bar
%    l - location adjust mode *
%    c - contrast adjust mode *
%    z - size adjust mode *
%    o - orientation adjust mode for bars, rect/oval for field
%    w - width/height of orientated bar
%    Esc - show menu mode 
%    arrow-key - adjust parameter moderately *
%    pgup/pgdwn - adjust parameter massively (use home/end for height) *
%    ,/. ;/' - adjust parameter finely *
%               (use ,/. for inc/dec or left/right, ;/' for up/down)
% where to display stims?
%    in RFcurrentrect, or as close as possible ('drawrect' is variable)
% how to handle mouse clicks that would position the rect off the screen?
%    move it so the rect is the same size but on edge of screen  *
%    adjust the rect's size so that the center can be where the mouse is clicked
% how to handle keyboard moving rect off the screen?
%    move it so rect is at the edge of screen, then beep if it is still moved

% how to display stims?
%    a) just draw some frames to the screen
%    b) call DisplayStimScript...would need to make it so it doesn't erase
%          stimulus at end  * 

% alternatives
%    a) make a light-weighting stim     *
%    b) make a quick-and-dirty bar stim
%    now three stim alternatives, add top two first
%       1) field stim, contrast adjust
%       2) blinkingstim, adjust thickness among five or so values
%       3) lightweighting stim

function stepcontrast(direc, big); %dir=+/-1, big=1,2,3 fine,med,big step
ReceptiveFieldGlobals;
switch(big), case 1,dc=0.05;case 2,dc=0.1;case 3,dc=0.25; end;
switch(RFparams.stim),
case 1,  % field
	p = getparameters(RFparams.stims{1});
	p.contrast = min([1 max([0 p.contrast+direc*dc])]); % bound in 0-1
	RFparams.stims{1} = periodicstim(p);
case 2,
	dc=fix(dc*255);
	p = getparameters(RFparams.stims{2});
	p.foreground = min([255 255 255; max([0 0 0 ; p.foreground+direc*dc])]); % bound in 0-255
	RFparams.stims{2} = polygonstim(p);
end;
 % add more cases later

function steporientation(direc, big); %dir=+/-1, big=1,2,3 fine,med,big step
ReceptiveFieldGlobals;
switch(big), case 1,dc=0.01;case 2,dc=0.05;case 3,dc=0.20; end;
switch(RFparams.stim),
case 1,  % field, switch rect/oval
	p = getparameters(RFparams.stims{1});
	p.windowShape = 1-p.windowShape ;
	RFparams.stims{1} = periodicstim(p);
case 2,
	dc=fix(dc*360);
	p = getparameters(RFparams.stims{2});
	p.orientation = p.orientation+direc*dc;
	RFparams.stims{2} = polygonstim(p);
end;

function stepwidthheight(direc, big); %dir=+/-1, big=1,2,3 fine,med,big step
ReceptiveFieldGlobals;
dw = 3^(big-1)*cos(direc);dh=3^(big-1)*sin(direc);
switch(RFparams.stim),
case 1,  % field, do nothing
case 2,
	p = getparameters(RFparams.stims{2});
	p.points = max([1 1 ; p.points + [ dw dh ]]);
	RFparams.stims{2} = polygonstim(p);
end;

 % add more cases later

% if hit boundary, just don't move that far; beep if cannot move at all
function movestim(direc,big) % direc=polar, big as above
ReceptiveFieldGlobals; StimWindowGlobals; r=RFcurrentrect;
dx=10^(big-1)*cos(direc);     dy=-10^(big-1)*sin(direc);
dx=-(dx<0)*min([-dx r(1)])+(dx>0)*min([dx StimWindowRect(3)-r(3) ]);
dy=-(dy<0)*min([-dy r(2)])+(dy>0)*min([dy StimWindowRect(4)-r(4) ]);
%if (dx==0)&(dy==0), beep; end;
RFcurrentrect=RFcurrentrect+round([dx dy dx dy]);
switch(RFparams.stim),
	case {1,2},
		s=RFparams.stim;
		RFparams.stims{s}=repositionstim(RFparams.stims{s},...
			{'rect',RFcurrentrect,'params',1}); % shouldn't fail
end;

function resizestim(direc,big) % direc=polar sign, big as above
ReceptiveFieldGlobals;StimWindowGlobals;r=RFcurrentrect;s=StimWindowRect;
dx=10^(big-1)*cos(direc)*[1 1];     dy=-10^(big-1)*sin(direc)*[1 1];
dx=dx.*(dx<0).*(-2*dx<diff(r([1 3])))+(dx>0).*min([dx; r(1)-s(1) s(3)-r(3)]);
dy=dy.*(dy<0).*(-2*dy<diff(r([2 4])))+(dy>0).*min([dy; r(2)-s(2) s(4)-r(4)]);
%if (dx==[0 0])&(dy==[0 0]), beep; end;
temprect=RFcurrentrect+round([-dx(1) -dy(1) dx(2) dy(2)]);
switch(RFparams.stim),
	case {1,2},
		s=RFparams.stim;
		RFparams.stims{s}=repositionstim(RFparams.stims{s},...
			{'rect',temprect,'params',1}); % should not fail
		RFcurrentrect = temprect;
end;

function setstimposition(xCtr,yCtr) % taken from sloppy recenterstim file...gotta make that cleaner
ReceptiveFieldGlobals; StimWindowGlobals;r=RFcurrentrect; s=StimWindowRect;
dx=fix(xCtr-0.5*(r(3)+r(1))); dy = fix(yCtr-0.5*(r(4)+r(2)));
dx=-(dx<0)*min([-dx r(1)])+(dx>0)*min([dx StimWindowRect(3)-r(3) ]);
dy=-(dy<0)*min([-dy r(2)])+(dy>0)*min([dy StimWindowRect(4)-r(4) ]);
%if (dx==0)&(dy==0), beep; end;
RFcurrentrect=RFcurrentrect+round([dx dy dx dy]);
switch(RFparams.stim),
	case 1,
		p = getparameters(RFparams.stims{1}); p.rect=RFcurrentrect;
		RFparams.stims{1}=periodicstim(p);
	case {2},
		p = getparameters(RFparams.stims{2}); p.rect=RFcurrentrect;
		RFparams.stims{2}=polygonstim(p);
end;


function beep
%SND('Play',0.5*sin(0:10000));
disp('err'),
