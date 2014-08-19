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
n_x = 1;
n_y = 1;

r = StimWindowRect; % screen size
width = round( (r(3)-r(1))/n_x);
height = round( (r(4)-r(2))/n_y);

ps=periodicstim('default');
pspar = getparameters(ps);
pspar.distance = NewStimViewingDistance;
pspar.imageType = 1;
pspar.animType = 4;
pspar.tFrequency = 2;
% pspar.sFrequency = 0.1;
pspar.nCycles = 1.5;
pspar.background = 0.5;
pspar.backdrop = 0.5;
pspar.windowShape = 0;
pspar.dispprefs = {'BGpretime',0,'BGposttime',0};
pspar.angle = 45;
pspar.rect=[0 0 960 540];
total_duration = 3;
pspar.prestim_time = 3
angles = [0:pspar.angle:360-pspar.angle];
spatialfrequency = [0.1 0.2 0.3 0.4 0.5 0.6];

for i = 1:6
    iss_script(i) = StimScript(0);
    % spatial frequency
    pspar.sFrequency = spatialfrequency(i);
     
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
MTI = DisplayTiming(iss_script(i));
DisplayStimScript(iss_script(i),MTI,0,0);
toc


try
    % waiting for stimulus signal on parallelport
    lpt=open_parallelport;
    ready=0;
    stop=0;
    while ~stop
        [go,stim]=get_gostim(lpt);
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
    close_parallelport(lpt);
end

