% continious orientation stimulus for tDCS

% Mehran & Despoina, 04 March 2014

% To skip initial tests
% Screen('Preference', 'SkipSyncTests', 2)


NewStimInit;
ReceptiveFieldGlobals;
NewStimGlobals;

CloseStimScreen;
ShowStimScreen;

StimWindowGlobals

% how many blocks

r = StimWindowRect; % screen size

ps=periodicstim('default');
pspar = getparameters(ps);
pspar.distance = NewStimViewingDistance;
pspar.imageType = 1;
pspar.animType = 4;
pspar.tFrequency = 2;
pspar.sFrequency = 0.05;
pspar.nCycles = 10;
pspar.background = 0.5;
pspar.backdrop = 0.5;
pspar.windowShape = 0;
pspar.dispprefs = {'BGpretime',0,'BGposttime',0};
pspar.angle = 30;
total_duration = 5*12;
pspar.prestim_time = 0;
angles = [0:pspar.angle:360-pspar.angle];
iss_script = StimScript(0);
pspar.rect = r;
pspar.nCycles = total_duration * pspar.tFrequency / (length(angles));

for i=1:10
    angles = angles( randperm(length(angles)) );
    for angle = angles
        pspar.angle = angle;
        ori_stim = periodicstim(pspar);
        iss_script = append(iss_script,ori_stim);
    end
end
    iss_script = loadStimScript(iss_script);

% tic
% show script as test
% MTI = DisplayTiming(iss_script(4));
% DisplayStimScript(iss_script,MTI,0,0);
% toc


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
                MTI = DisplayTiming(iss_script);
                DisplayStimScript(iss_script,MTI,0,0);
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