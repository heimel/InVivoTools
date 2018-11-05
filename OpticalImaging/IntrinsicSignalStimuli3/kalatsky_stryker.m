%KALATSKY_STRYKER
%
% Wide-field imaging stimulus, NewStim3 version
%    based on retinopy_2x2
% 
% 2004-2018, Alexander Heimel
%
% To skip initial tests
% Screen('Preference', 'SkipSyncTests', 2)

display (['IMP: If stimuli is tilted change NewStimTilt in'])
display (['NewStimConfiguration to 0 (normal), 10 (left) or -10 (right)'])
%display (['Press space to proceed ..........'])
%pause

NewStimInit;
ReceptiveFieldGlobals;
NewStimGlobals;

CloseStimScreen;
ShowStimScreen;
 
StimWindowGlobals

windowrect = StimWindowRect; % screen size
width = windowrect(3)-windowrect(1);
height = windowrect(4)-windowrect(2);

ps = periodicstim('default');
pspar = getparameters(ps);
pspar.distance = NewStimViewingDistance;
pspar.rect = windowrect;
pspar.imageType = 6; % edge
pspar.animType = 4; % drifting grating
pspar.tFrequency = 0.09987; % Hz, to be used with acqtime:580747ms, 12camframperdataframe
pspar.sFrequency = 0.0048; % cpd
pspar.barWidth = 0.05; % fraction of screen width?
pspar.barColor = 0;
pspar.nCycles = 30; % about 5 min
pspar.background = 0.5;
pspar.backdrop = 0.5;
pspar.windowShape = 0;
pspar.dispprefs = {'BGpretime',0,'BGposttime',0};
pspar.angle = 45;
pspar.prestim_time = 3
directions = [90 270 0 180]; % right, left, up, down

for i = 1:length(directions)
    iss_script(i) = stimscript(0);
    pspar.angle = directions(i);
    iss_script(i) = append(iss_script(i),periodicstim(pspar));
    iss_script(i) = loadStimScript(iss_script(i));
end

teststim = 1;
% show script as test
MTI = DisplayTiming(iss_script(teststim));
tic
DisplayStimScript(iss_script(teststim),MTI,0,0);
toc

return

try
    % waiting for stimulus signal on parallelport
    lpt=open_parallelport;
    ready=0;
    stop=0;
    while ~stop
        [go,stim] = get_gostim(lpt);
        if ~go    % go has to be off, before another stimulus is shown
            ready = 1;
        end
        if go && ready
            if stim~=0 % not blank
                pause(pspar.prestim_time);
                MTI = DisplayTiming(iss_script(stim));
                DisplayStimScript(iss_script(stim),MTI,0,0);
            else
                % blank (do nothing)
            end
            ready = 0;
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
    close_parallelport(lpt);
end

