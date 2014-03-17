%OD
%
% 2012, Alexander Heimel
%


NewStimInit;
ReceptiveFieldGlobals;

CloseStimScreen;
ShowStimScreen;

StimWindowGlobals

% how many blocks
n_x = 2;
n_y = 2;

r = StimWindowRect; % screen size
width = round( (r(3)-r(1))/n_x);
height = round( (r(4)-r(2))/n_y);

ps=periodicstim('default');
pspar = getparameters(ps);
pspar.imageType = 1;
pspar.animType = 4;
pspar.tFrequency = 2;
pspar.sFrequency = 0.05;
pspar.nCycles = 1.5;
pspar.background = 0.5
pspar.backdrop = 0.5;
pspar.windowShape = 0;
pspar.dispprefs = {'BGpretime',0,'BGposttime',0};
pspar.angle = 45;
total_duration = 3;
pspar.prestim_time = 0;
angles = [0:pspar.angle:360-pspar.angle];

for i = 1:n_x*n_y
    retinotopy_script(i) = StimScript(0);
    
    row=floor( (i-1)/n_x);
    col=i-1-row*n_x;
    
    pspar.rect = [col*width row*height (col+1)*width (row+1)*height];
    
    pspar.nCycles = total_duration * pspar.tFrequency / length(angles);
    angles = angles( randperm(length(angles)) );
    for angle = angles
        pspar.angle = angle;
        retinotopy_stim = periodicstim(pspar);
        retinotopy_script(i) = append(retinotopy_script(i),retinotopy_stim);
    end
    retinotopy_script(i) = loadStimScript(retinotopy_script(i));
end

tic
% show script as test
MTI = DisplayTiming(retinotopy_script(4));
DisplayStimScript(retinotopy_script(4),MTI,0,0);
toc


try
    % waiting for stimulus signal on parallelport
    lpt=open_parallelport;
    ready=0;
    stop=0;
    while ~stop
        [go,stim]=get_gostim(lpt);
        stim = stim && (255-32);
        stim = stim && (255-16);
        
        if ~go    % go has to be off, before another stimulus is shown
            ready=1;
        end
        if go && ready
            if stim~=0 % not blank
                stim=and(stim,31); % remove shutter bits
                pause(pspar.prestim_time);
                MTI = DisplayTiming(retinotopy_script(stim));
                DisplayStimScript(retinotopy_script(stim),MTI,0,0);
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

