% visual_and_current_stimulation
% 
%   Shows continuous visual stimulation and reads stims bits and instructs
%   current stimulation arduino with the frequency
%
% 2014, Despina Tsapa and Alexander Heimel
%

NewStimConfiguration

NewStimGlobals
NewStimInit;
remotecommglobals;
ReceptiveFieldGlobals;
StimWindowGlobals

comPort = '/dev/ttyS101'; % current stimulation arduino

% close if it is open already
s=instrfind('type','serial','name',['Serial-' comPort],'status','open');
if ~isempty(s)
    fclose(s);
end

flag = 1;

s = serial(comPort);
set(s, 'DataBits', 8);
set(s, 'StopBits', 1);
set(s, 'BaudRate', 9600);
set(s, 'Parity', 'none');
fopen(s);
frequency = 10; %Hz

lpt = open_parallelport;
count = 0;

angles = 0:45:315;

CloseStimScreen;
ShowStimScreen;

gratingstim = periodicstim('default');
wp = getparameters(gratingstim);
wp.imageType = 1;  % square wave
wp.animType = 4;
wp.dispprefs={'BGpretime',nan,'BGposttime',nan};
wp.sFrequency = 0.05;% to check linearization
wp.tFrequency = 2;% to check linearization                
wp.rect = StimWindowRect;
wp.nCycles = 1;
 wp.contrast = 0;


for i = 1:length(angles)
    wp.angle = angles(i);
    gratingstim = periodicstim(wp);
    gratingscripts{i} = stimscript(0);
    gratingscripts{i} = append(gratingscripts{i},gratingstim);
    gratingscripts{i}=loadStimScript(gratingscripts{i});
    MTIs{i}=DisplayTiming(gratingscripts{i});
end
fwrite(s, frequency, 'uint8', 'sync');



i = 1;
prevstim = NaN;
prevgo = NaN;
while 1
    MTI = MTIs{i}{1};
    vbl = Screen('Flip',StimWindow,0);
    frameTimes(1) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,1);
    
    
    for frameNum=2:length(MTI.df.frames);
        textures = MTI.MovieParams.Movie_textures{frameNum};
        Screen('DrawTextures',StimWindow,MTI.ds.offscreen(textures),...
            squeeze(MTI.MovieParams.Movie_sourcerects(:,frameNum,textures)),...  % sourceRects
            squeeze(MTI.MovieParams.Movie_destrects(:,frameNum,textures)),...    % destinationRects
            squeeze(MTI.MovieParams.Movie_angles(:,frameNum,textures)),1,...       % rotationAngle, filterMode
            squeeze(MTI.MovieParams.Movie_globalalphas(:,frameNum,textures)),... % globalAlpha
            [],[],[], ... % modulateColor,textureShader,specialFlags
            squeeze(MTI.MovieParams.Movie_auxparameters(:,frameNum,textures))); % auxParameters
                 
        
        %if StimWindowUseCLUTMapping, Screen('LoadNormalizedGammaTable',StimWindow,linspace(0,1,256)' * ones(1,3),1); end;
        vbl=Screen('Flip',StimWindow,vbl+(MTI.pauseRefresh(frameNum-1)-0.5)/StimWindowRefresh);
        %frameTimes(frameNum) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,frameNum);
        %WaitSecs(1/10000);  
        %StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,frameNum);
        
         
        % getting vdaq stimulus number
        [go,stim]=get_gostim(lpt);
        if  prevstim~=stim
            prevgo = go;
            prevstim = stim;
            
            disp(['stim = ' num2str(stim)]);
            frequency = stim;
            status = uint8(0);
            while status==0
                %disp('reading');
                status = fread(s,1,'uint8');
                %disp('read');
                pause(0.01);
            end
            fwrite(s, frequency, 'uint8', 'sync');
        end
        
    end
    if KbCheck
        CloseStimScreen;
        break
    end
    i = i+1;
    if i>length(gratingscripts)
        i = 1;
    end
end

fclose(s);
close_parallelport(lpt);

