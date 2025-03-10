%RETINOTOPY_11x6
%
% RETINOTOPY_11x6, NewStim3 version
% 
% 2014, Alexander Heimel
%

% To skip initial tests
% Screen('Preference', 'SkipSyncTests', 2)


NewStimInit;
ReceptiveFieldGlobals;
NewStimGlobals;
        
NewStimTilt = 0;
logmsg(['NewStimTilt = ' num2str(NewStimTilt)]);

CloseStimScreen;
ShowStimScreen;
 
StimWindowGlobals
 
% how many blocks
n_x = 11; 
n_y = 6;

r = StimWindowRect; % screen size


fullheight = r(4)-r(2);
fullwidth = fullheight/6*11; 

fullwidth = r(3)-r(1);
fullheight = fullheight/11*6; 

x_offset = round( (r(3)-r(1)-fullwidth)/2);
width = round( fullwidth/n_x);
height = round( fullheight/n_y);

width = 174;
height = 174;
x_offset = 3;

ps=periodicstim('default');
pspar = getparameters(ps);
pspar.distance = NewStimViewingDistance;
pspar.imageType = 1;
pspar.animType = 4;
pspar.tFrequency = 2;
pspar.sFrequency = 0.05;
pspar.nCycles = 1.5;
pspar.background = 0.5;
pspar.backdrop = 0.5;
pspar.windowShape = 0;
pspar.dispprefs = {'BGpretime',0,'BGposttime',0};
pspar.angle = 45;
total_duration = 6;
pspar.prestim_time = 3;
angles = [0:pspar.angle:360-pspar.angle];

for i = 1:n_x*n_y
    iss_script(i) = StimScript(0);
   
    % location
    row=floor( (i-1)/n_x);
    col=i-1-row*n_x;
    pspar.rect = [x_offset+col*width row*height x_offset+(col+1)*width (row+1)*height];
    
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
end 

 