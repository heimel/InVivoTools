 %RETINOTOPY_2x2
%
% RETINOTOPY_2x2, NewStim3 version
% 
% 2012, Alexander Heimel
%

% To skip initial tests
% Screen('Preference', 'SkipSyncTests', 2)

display (['IMP: If stimuli is tilted change NewStimTilt in'])
display (['NewStimConfiguration to 0 (normal), 10 (left) or -10 (right)'])
display (['Press space to proceed ..........'])

pause

NewStimInit;
ReceptiveFieldGlobals;
NewStimGlobals;

CloseStimScreen;
ShowStimScreen;
 
StimWindowGlobals

% how many blocks
n_x = 2;
n_y = 2;

r = StimWindowRect; % screen size

fullheight = r(4)-r(2);
fullwidth = fullheight/3*4; % to match 4:3 dimensions of old CRT

x_offset = round( (r(3)-r(1)-fullwidth)/2);
width = round( fullwidth/n_x);
height = round( fullheight/n_y);

ps=periodicstim('default');
pspar = getparameters(ps);
pspar.distance = NewStimViewingDistance;
pspar.imageType = 1;
pspar.animType = 4;
pspar.tFrequency = 2;
pspar.sFrequency = 0.05;
pspar.nCycles = 1.5;
pspar.background = 0.5;
pspar.backdrop = 0.5; % Ok 0.5
pspar.windowShape = 0; % Ok 0
pspar.dispprefs = {'BGpretime',0,'BGposttime',0};
pspar.angle = 45;
total_duration = 6; % OK 6
pspar.prestim_time = 3;
% pspar.size=12; % Ok no
angles = [0:pspar.angle:360-pspar.angle];

for i = 1:n_x*n_y
    iss_script(i) = StimScript(0);
   
    % location
    row=floor( (i-1)/n_x);
    col=i-1-row*n_x;
    pspar.rect = [x_offset+col*width row*height x_offset+(col+1)*width (row+1)*height];
    % R = jander_screen_rotate(pspar.rect,10); %new line for rotation
    % pspar.rect=R; %new line for rotation
    pspar.nCycles = total_duration * pspar.tFrequency / length(angles);
    angles = angles( randperm(length(angles)) );
    for angle = angles
       
        pspar.angle = angle;
        retinotopy_stim = periodicstim(pspar);
        iss_script(i) = append(iss_script(i),retinotopy_stim);
    end
    iss_script(i) = loadStimScript(iss_script(i));
end

tic
% show script as test
MTI = DisplayTiming(iss_script(4));
DisplayStimScript(iss_script(4),MTI,0,0);
toc

try
    % waiting for stimulus signal on parallelport
    lpt=open_parallelport;
    ready=0;
    stop=0;
    while ~stop
        [go,stim]=get_gostim(lpt)
        if ~go    % go has to be off, before another stimulus is shown
            ready=1;
        end
        if go && ready
            if stim~=0 % not blank
                pause(pspar.prestim_time);
                MTI = DisplayTiming(iss_script(stim));
                DisplayStimScript(iss_script(stim),MTI,0,0);
            else
                % blank (do nothing)
            end
            ready=0;
        end
        pause(0.01);
        if kbcheck
            CloseStimScreen;
            return
        end
    end
    CloseStimScreen;
catch me
    CloseStimScreen;
    rethrow(me);
end

