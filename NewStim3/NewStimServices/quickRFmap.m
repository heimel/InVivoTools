function quickRFmap

% Provides quick stimulus manipulation for mapping RFs. See keyboard commands
% in figure window to control stimulus. Stimulus position will also follow mouse pointer.
% 
% Many default settings (including increments for size and position) can be changed in the
% m-file directly. 
% 
% Can display vbl timestamps in figure (default is ON). Note - the system will drop frames 
% when changing the size of large textures. These textures are re-calculated on the fly, and 
% this takes time. On most systems, moving large textures should be seamless. If it is not, it 
% may indicate a timing problem elsewhere.
% 
% 5/17/11 Gordon Smith <gordon.smith@mpfi.org>.

% % % Defaults for increments, wave type, surround size
global rad square surroundwidth surroundinc gratinginc arrowinc anginc keypressint plotvbltimes

global quickRFrect

rad=100;
square=1;
surroundwidth=200; % starting point... 
surroundinc=20; % how many px do we increment surround width each keypress?
gratinginc=20; % how many px do we increment gratingsize each keypress?
arrowinc=50; % how many px to move with arrow?
anginc=22.5; % how much to increment angle?
keypressint=0.2; % how long to wait between keypresses? increase to prevent multiple responses from single keystroke.
plotvbltimes=0;
% % % END SETABLE PARAMATERS...

StimWindowGlobals; MonitorWindowGlobals;
ShowStimScreen;


% % % Make monitor window
fpos=Screen('Rect',MonitorWindowMonitor)-50; %set 50 px inside upper Rt corner
fpos=[fpos(3)-420, fpos(4)-410, 420 410];
oldVerbosity=Screen('Preference','Verbosity',1); %supress annoying outputs?
close(findobj('Name','Quick RF mapping'))
fig=figure('WindowStyle','normal','Position',fpos,'Name','Quick RF mapping',...
    'CloseRequestFcn',{@closeRFfnc, oldVerbosity});
clf
txt.Units = 'pixels'; txt.BackgroundColor = [0.8 0.8 0.8];
txt.fontsize = 10; txt.fontweight = 'normal';
txt.HorizontalAlignment = 'left';txt.Style='text';
edit = txt; edit.BackgroundColor = [ 1 1 1]; edit.Style = 'Edit';
edit.HorizontalAlignment='center';
but=txt; but.style='pushbutton';

sh=-70;
uicontrol(txt,'position',[5   385   150    22],'string','Quick RF mapping','fontweight','bold',...
    'fontsize',12);
uicontrol(txt,'position',[15   400+sh   70    22],'string','Spat. Fq.');
uicontrol(txt,'position',[15   380+sh   70    22],'string','Temp. Fq.');
uicontrol(txt,'position',[15   360+sh   70    22],'string','Conrast');
uicontrol(txt,'position',[15   340+sh   70    22],'string','Angle');
uicontrol(txt,'position',[15   320+sh   70    22],'string','BG color');
uicontrol(txt,'position',[15   270+sh   70    22],'string','Monitor dist');

han.cyc_per_deg=uicontrol(edit,'position',[90   400+sh   70    22],'string','0.1');
han.cyclespersec=uicontrol(edit,'position',[90   380+sh   70    22],'string','1');
han.contrast=uicontrol(edit,'position',[90   360+sh   70    22],'string','1');
han.ang=uicontrol(edit,'position',[90   340+sh   70    22],'string','0');
han.bgcolor=uicontrol(edit,'position',[90   320+sh   70    22],'string','128');
han.dist=uicontrol(edit,'position',[90   270+sh   70    22],'string','30');

uicontrol(txt,'position',[15   165   200    22],'string','Keyboard commands:','fontweight','bold');

str='';
str=[str sprintf('%s\n','e             -   Exit animation loop ')];
str=[str sprintf('%s\n',' ')];
str=[str sprintf('%s\n','f              -   Toggle full screen grating ')];
str=[str sprintf('%s\n','s             -   Toggle center / surround')];
str=[str sprintf('%s\n','z             -   Toggle sine vs square wave grating')];
str=[str sprintf('%s\n',' ')];
str=[str sprintf('%s\n',['<   or    >  -   Increment center width (' num2str(gratinginc) ' px)'])];
str=[str sprintf('%s\n',['[    or    ]  -   Increment surround width (' num2str(surroundinc) ' px)'])];
str=[str sprintf('%s\n',['-    or   +  -   Change angle (' num2str(anginc) ' deg steps)'])];
str=[str sprintf('%s\n','c   or   v   or   x -   Change contrast (10% steps) , toggle on/off')];
str=[str sprintf('%s\n',' ')];
str=[str sprintf('%s\n',['Arrow keys  -    Move stimulus, ' num2str(arrowinc) ' px steps'])];
uicontrol(txt,'position',[15   10   400    160],'string',str)

uicontrol(txt,'position',[15   365   400    22],'string','Drag mouse to move stimulus.','fontweight','bold')

x=260;
uicontrol(txt,'position',[x   400+sh   150    22],'string','Stimulus Position','fontweight','bold');
uicontrol(txt,'position',[x   380+sh   90    22],'string','Center x-y');
uicontrol(txt,'position',[x   360+sh   90    22],'string','Center radius');
uicontrol(txt,'position',[x   340+sh   90    22],'string','Surround width');

sh2=100; 
han.pos=uicontrol(txt,'position',[x+sh2   380+sh   90    22],'string',' ');
han.rad=uicontrol(txt,'position',[x+sh2   360+sh   90    22],'string',num2str(rad));
han.surroundwidth=uicontrol(txt,'position',[x+sh2   340+sh   90    22],'string',num2str(surroundwidth));


uicontrol(but,'position',[x   270+sh   140    22],'string','Run','Callback',{@runthis,han});


function runthis(src,eventdata,han)
% get parameters
cyc_per_deg=str2double(get(han.cyc_per_deg,'String')); 
dist=str2double(get(han.dist,'String'));
bgcolor=str2double(get(han.bgcolor,'String'));
cyclespersecond=str2double(get(han.cyclespersec,'String'));
ang=str2double(get(han.ang,'String'));
contrast=str2double(get(han.contrast,'String'));
global rad square surroundwidth surroundinc gratinginc arrowinc anginc keypressint plotvbltimes

% Mapping code...
NewStimGlobals; StimWindowGlobals; MonitorWindowGlobals;

white=WhiteIndex(StimWindowMonitor);
black=BlackIndex(StimWindowMonitor);
gray=round((white+black)/2);
if gray == white
    gray=white / 2;
end
inc=white-gray;

%
f=(cyc_per_deg)/(dist*tan(pi/180)*pixels_per_cm);
p=ceil(1/f);
fr=f*2*pi;
ang=mod(ang+90,360); %- make consistent with typical lab usage


%% center the mouse on rect
HideCursor;
[mx_old, my_old, buttons]=GetMouse(MonitorWindowMonitor); %get current position
[centx centy]=RectCenter(StimWindowRect); 
SetMouse(centx,centy,StimWindow);
[mxold, myold, buttons]=GetMouse(StimWindowMonitor); %get first position
%% Make windows
w=StimWindow;
Screen('FillRect',w,bgcolor); % change fill to new bg color
Screen('Flip',w);
Screen(w,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
% make grating
gratingsize=round(sqrt(StimWindowRect(3)^2+StimWindowRect(4)^2))*3; %calculate size needed to fill screen at any angle
texsize=gratingsize /2;
x = meshgrid(-texsize:texsize + p, 1);
grating=gray + inc*cos(fr*x);
gratingsq=round(grating/white)*white;
gratetex_sine=Screen('MakeTexture',w,grating);
gratetex_sq=Screen('MakeTexture',w,gratingsq);


if square
    gratetex=gratetex_sq;
else
        gratetex=gratetex_sine;
end
imrect=Screen('Rect',gratetex); % get size of grating texture REMEMBER: it's a 1D texture!
[fullrect, dx, dy]=CenterRect([0 0 imrect(3) imrect(3)],StimWindowRect); % recenter this rect.
% %create ring masks, with and without surround
outerrad=rad+surroundwidth; % start with this, will allow changes during run
innercircle=circle(rad);
outercircle=circle(outerrad);
padsize=(length(outercircle)-length(innercircle))/2;
innercirclepad=padarray(innercircle,[padsize padsize]);
circmasksurround=~innercirclepad&outercircle; circmasksurround=~circmasksurround;
circmaskfull=~innercirclepad;
circmasksurround=uint8(white*circmasksurround);
circmaskfull=uint8(white*circmaskfull);
circmasksurround=cat(3,bgcolor*ones(size(circmasksurround),'uint8'),circmasksurround);
circmaskfull=cat(3,bgcolor*ones(size(circmaskfull),'uint8'),circmaskfull);
masktexsurround=Screen('MakeTexture',w,circmasksurround);
masktexfull=Screen('MakeTexture',w,circmaskfull);


surround=0; % start without surround
if surround,    masktex=masktexsurround; else masktex=masktexfull; end

% determine region of grating that is within region of mask
% Note mask is smaller than grating!
mskrect=Screen('Rect',masktex);
myrect=CenterRect(mskrect,StimWindowRect);

drect=(ClipRect(myrect,fullrect));
srect0=OffsetRect(drect,-dx,-dy);

%% prep for animation
waitframes = 1; ifi=Screen('GetFlipInterval', w);
waitduration = waitframes * ifi;
posupdateint=round(1/ifi); % interval to update parameters
shiftperframe= cyclespersecond * p * waitduration;
fliptimes=zeros(1,ceil(1000/ifi)); % preallocate some space... will remove later
inttimes=fliptimes;

i=0;
escapeKey=KbName('e');
mask=1; lastSec=0;
tic; drift=1;
% keyboard;
try
    ListenChar(2);
    HideCursor;
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    % Animationloop:
    vbl=Screen('Flip', w);
    fliptimes(1)=vbl;
    while 1
        xoffset = mod(i*shiftperframe,p);
        i=i+1;
        sizechange=0;
        
        if mask, srect=srect0+[xoffset 0 xoffset 0]; 
        else srect=srectf+[xoffset 0 xoffset 0]; end
        
	if StimWindowUseCLUTMapping, Screen('LoadNormalizedGammaTable',StimWindow,linspace(0,1,256)' * ones(1,3),1);
    else, Screen('LoadNormalizedGammaTable',StimWindow,StimWindowPreviousCLUT,1);
    end;
        if drift, Screen('DrawTexture',w,gratetex,srect,drect,ang,[],contrast); 
        else Screen('DrawTexture',w,gratetex,srect0,drect,ang,[],contrast); end
        if mask, Screen('DrawTexture',w,masktex,[],myrect,ang); end
        inttimes(i)=toc; %get elapsed time for loop - start time just after previous flip
        vbl=Screen('Flip',w,vbl+(waitframes-0.5)*ifi);
        tic;
        fliptimes(i+1)=vbl;
        
        [ keyIsDown, seconds, keyCode ] = KbCheck;
        if keyIsDown
            
            if keyCode(escapeKey)
%                 sca; keyboard;
                break;
            elseif seconds-lastSec>keypressint 
                keyname=KbName(keyCode);
                switch keyname
                    case 'b'
                        drift=~drift;
                    case 'z' %toggle sine v square
                        square=~square;
                        if square
                            gratetex=gratetex_sq;
                        else
                            gratetex=gratetex_sine;
                        end
                    case 'c' % decrese contrast
                        contrast=contrast-0.1; if contrast<=0, contrast=0; end
                    case 'v'
                        contrast=contrast+0.1; if contrast>=1, contrast=1; end
                    case 'x',
			if contrast>0, contrast = 0; else, contrast = 1; end;
                    case 'f' % toggle full screen
                        mask=~mask;
                        sizechange=1;
                        drect=myrect;
                    case 's' %toggle surround of mask
                        if mask % possibly only allow if not fullscreen
                            surround=~surround;
                            if surround,    masktex=masktexsurround; else masktex=masktexfull; end
                        end
                    case {'[{',']}'} % change surround width size. requires recalc of make tex.
                        if mask
                            
                            if strcmp(keyname,'[{') % make smaller
                                surroundwidth=surroundwidth-surroundinc;
                            else % make larger
                                surroundwidth=surroundwidth+surroundinc;
                            end
                            %%
                            if surroundwidth<surroundinc, surroundwidth=surroundinc; end
                            
                            outerrad=rad+surroundwidth;
                            outercircle=circle(outerrad);
                            
                            if length(outercircle)<=length(innercirclepad) % ie the center tex is larger, make both texs smaller
                                padsize=(length(outercircle)-length(innercircle))/2;
                                innercirclepad=padarray(innercircle,[padsize padsize]);
                            else % need to pad the inner, and remake both
                                padsize=(length(outercircle)-length(innercirclepad))/2;
                                innercirclepad=padarray(innercirclepad,[padsize padsize]);
                            end
                            circmasksurround=~innercirclepad&outercircle; circmasksurround=~circmasksurround;
                            circmaskfull=~innercirclepad;
                            circmasksurround=uint8(white*circmasksurround);
                            circmaskfull=uint8(white*circmaskfull);
                            circmasksurround=cat(3,bgcolor*ones(size(circmasksurround),'uint8'),circmasksurround);
                            circmaskfull=cat(3,bgcolor*ones(size(circmaskfull),'uint8'),circmaskfull);
                            Screen('Close',[masktexsurround masktexfull]); % might not be needed, goal is to free memory...
                            masktexsurround=Screen('MakeTexture',w,circmasksurround);
                            masktexfull=Screen('MakeTexture',w,circmaskfull);
                            
                            % need to fix rects since it may have gotten larger
                            mskrect=Screen('Rect',masktex);
                            myrect=CenterRect(mskrect,drect);
                            sizechange=1;
                        end
                    case {',<','.>'}
                        if mask
                            if strcmp(keyname,',<') %make smaller
                                rad=rad-gratinginc;
                            else
                                rad=rad+gratinginc;
                            end
                            
                            if rad<=0,
                                rad=0;
                                innercircle=0*innercircle;
                                outercircle=0*outercircle;
                            else
                                innercircle=circle(rad);
                                outerrad=rad+surroundwidth;
                                outercircle=circle(outerrad);
                            end
                            padsize=(length(outercircle)-length(innercircle))/2;
                            innercirclepad=padarray(innercircle,[padsize padsize]);
                            circmasksurround=~innercirclepad&outercircle; circmasksurround=~circmasksurround;
                            circmaskfull=~innercirclepad;
                            %%
                            circmasksurround=uint8(white*circmasksurround);
                            circmaskfull=uint8(white*circmaskfull);
                            circmasksurround=cat(3,bgcolor*ones(size(circmasksurround),'uint8'),circmasksurround);
                            circmaskfull=cat(3,bgcolor*ones(size(circmaskfull),'uint8'),circmaskfull);
                            masktexsurround=Screen('MakeTexture',w,circmasksurround);
                            masktexfull=Screen('MakeTexture',w,circmaskfull);
                            
                            % need to set masktex
                            if surround,    masktex=masktexsurround; else masktex=masktexfull; end
                            
                            %  now fix the rects
                            mskrect=Screen('Rect',masktex);
                            myrect=CenterRect(mskrect,drect);
                            sizechange=1;
                        end
                    case 'UpArrow'
                        myrect=myrect-[0 arrowinc 0 arrowinc];
                    case 'DownArrow'
                        myrect=myrect+[0 arrowinc 0 arrowinc];
                    case 'LeftArrow'
                        myrect=myrect-[arrowinc 0 arrowinc 0];
                    case 'RightArrow'
                        myrect=myrect+[arrowinc 0 arrowinc 0];
                    case '-_'
                        ang=mod(ang-anginc,360);
                    case '=+'
                        ang=mod(ang+anginc,360);
                    case 'space'
                        WaitSecs(1);
                        ListenChar(0); ShowCursor; keyboard;                         
                        ListenChar(2); HideCursor;
                end
                lastSec=seconds;
            end
        end
        
        [mx, my, buttons]=GetMouse(StimWindowMonitor); %get position
%         if find(buttons) & mask %if click, change position
        if (mx~=mxold | my~=myold)
            myrect=CenterRect(myrect,[mx-rad my-rad mx+rad my+rad]);
        end
        mxold=mx;
        myold=my;

        global quickRFrect;
        quickRFrect = myrect;
        
        % now update the rectangles, need to handle differently if full or masked. 
        % Grating is 1D in x, and srect always pulls from this orientation. 
        % This causes problems (phase shifts) when ang~=0...
        % So we need to allow for srect to move differently depending on the angle.
        if mask
            if sizechange
                move=myrect - drect; move(2)=0; move(4)=0;
                srect0=srect0+move;
            else
                move=myrect - drect; xmove=move(1); ymove=move(2);
                move=[cos(ang/180*pi)*xmove + sin(ang/180*pi)*ymove];
                srect0=srect0+[move 0 move 0];
            end
            drect=(ClipRect(myrect,fullrect));
        else
            drect=fullrect;
            srectf=OffsetRect(drect,-dx,-dy);
        end
        
        if mod(i,posupdateint)==0 % update every interval
            pos=[drect(3)-(drect(3)-drect(1))/2, drect(4)-(drect(4)-drect(2))/2];
            set(han.ang,'String',num2str(mod(ang-90,360)));
            set(han.contrast,'String',num2str(contrast));
            set(han.pos,'String',num2str(pos));
            set(han.rad,'String',num2str(rad));
            set(han.surroundwidth,'String',num2str(surroundwidth));
            drawnow;
        end
%         if ~isequal(myrect,drect); keyboard; end
    end
    ListenChar(0);     Priority(0);     ShowCursor;
    Screen('FillRect',w,bgcolor); % change fill to new bg color
    Screen('Flip',w);
catch
    ListenChar(0);     Priority(0);
    ShowCursor;
    psychrethrow(psychlasterror);
end
SetMouse(mx_old, my_old,MonitorWindowMonitor) %put the mouse back where it was...
ShowCursor
if plotvbltimes
    if isempty(findobj('Name','VBL Timestamps'))
        figure('Name','Plottimes');
    else
        figure(findobj('Name','VBL Timestamps'))
        clf;
    end
fliptimes=fliptimes(fliptimes~=0);
plot(diff(fliptimes(1:end)))
% inttimes=inttimes(2:end); inttimes=inttimes(inttimes~=0);
end
% try to raise the control window, if hidden
figure(findobj('Name','Quick RF mapping'));

function closeRFfnc(src,eventdata,oldVerbosity)
StimWindowGlobals;
CloseStimScreen;
delete(findobj('Name','Quick RF mapping'));
Screen('Preference','Verbosity',oldVerbosity);



% keyboard;
