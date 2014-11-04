function [startStopTimes,frameTimes] = DisplayStimulus(MTI, thestim, trigger, capture_movie)


% DISPLAYSTIMULUS
%
%   [startStopTimes,frameTimes] = DISPLAYSTIMULUS(MTI, STIM)
%
%  Displays a stimulus STIM using data in the Measured Timing Index variable MTI.  Returns
%  timestamp entries startStopTimes and frameTimes.

if nargin<4;capture_movie=[];end
if isempty(capture_movie);capture_movie=false;end
if nargin<2, stim = []; else, stim = thestim; end;
if nargin<3
    trigger = [];
end
if isempty(trigger)
    trigger = 0;
end

StimWindowGlobals;
NewStimGlobals;

% fill variables for speed, if it matters
startStopTimes = MTI.startStopTimes;
frameTimes = MTI.frameTimes;

if NS_PTBv<3,
    Screen(StimWindow,'FillRect',0);
else,
    show_background(StimWindow,MTI,[],2);
%    show_background(StimWindow,MTI,[],2);
%    WaitSecs(0.02);
end;




masktexture = -1;

if MTI.ds.makeClip, % make a clipping region
    if NS_PTBv<3,  %use clipping region, can call routine directly
        Screen(StimWindow,'SetDrawingRegion',MTI.ds.clipRect,MTI.ds.makeClip-1);
    else, % make a clipping region or use the one provided
        if MTI.ds.makeClip==4|MTI.ds.makeClip==5,
            masktexture = MTI.ds.clipRect;
        end;
    end;
end;

if strcmp(MTI.ds.displayType,'Sound'), Snd('Open'); end;

if trigger
    % Levelt lab trigger hard coded. Should use StimTriggerAct structure
    StimSerialGlobals
    %OpenStimSerial
    disp('trigger');
    StimSerial(StimSerialScriptOutPin,StimSerialScript,0);
    waitsecs(0.001);
    StimSerial(StimSerialScriptOutPin,StimSerialScript,1);
    
    % turn on separate trigger channel
    StimSerial('rts',StimSerialStim,1);
else
    StimSerialGlobals
    % turn off separate trigger channel
    StimSerial('rts',StimSerialStim,0);
end

if MTI.preBGframes>0,
    if NS_PTBv<3,
        Screen(StimWindow,'SetClut',MTI.ds.clut_bg); % also does waitblanking
        startStopTimes(1) = StimTriggerAct('Stim_BGpre_trigger',MTI.stimid);
        Screen(StimWindow,'WaitBlanking',MTI.preBGframes);
    else,
    
        vbl = show_background(StimWindow,MTI);
        startStopTimes(1) = StimTriggerAct('Stim_BGpre_trigger',MTI.stimid);
        show_background(StimWindow,MTI,vbl + (MTI.preBGframes-1)/StimWindowRefresh)
        if capture_movie; Screen('AddFrameToMovie', StimWindow,[],[],[],MTI.preBGframes); end
    end;
else,
    startStopTimes(1) = StimTriggerAct('Stim_BGpre_trigger',MTI.stimid);
end;


if strcmp(MTI.ds.displayType,'CLUTanim')&strcmp(MTI.ds.displayProc,'standard'),
    s0 = GetSecs();
    startStopTimes(2) = StimTriggerAct('Stim_ONSET_trigger',MTI.stimid);
    rect = Screen(MTI.ds.offscreen(1),'Rect');
    if NS_PTBv<3,
        Screen('CopyWindow',MTI.ds.offscreen(1),StimWindow,rect,MTI.df.rect,'srcCopy');
        Screen(StimWindow, 'SetClut', MTI.ds.clut{MTI.df.frames(1)}); % does waitblanking
        frameTimes(1) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,1);
        for frameNum=2:length(MTI.df.frames),
            Screen(StimWindow,'WaitBlanking',MTI.pauseRefresh(frameNum-1));
            StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,frameNum);
            Screen(StimWindow,'SetClut',MTI.ds.clut{MTI.df.frames(frameNum)});
            frameTimes(frameNum) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,frameNum);
        end;
        Screen(StimWindow,'WaitBlanking',MTI.pauseRefresh(end));
    else,
        Screen('DrawTexture',StimWindow,MTI.ds.offscreen(1),rect,MTI.df.rect);
        % mask if necessary
        %if MTI.ds.makeClip==4, Screen('DrawTexture',StimWindow,masktexture); elseif MTI.ds.makeClip==5, screen('DrawTexture',StimWindow,masktexture,[],MTI.df.rect); end;
        Screen('LoadNormalizedGammaTable',StimWindow, MTI.ds.clut{MTI.df.frames(1)},1);
        vbl=Screen('Flip',StimWindow,0,2); % waits for waitblanking, does not clear buffer
        frameTimes(1) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,1);
        Screen(StimWindow,'FillRect',0); % paint background color in the 2nd buffer
        Screen('DrawTexture',StimWindow,MTI.ds.offscreen(1),rect,MTI.df.rect); % draw in the 2nd buffer
        %if MTI.ds.makeClip==4, Screen('DrawTexture',StimWindow,masktexture); elseif MTI.ds.makeClip==5, screen('DrawTexture',StimWindow,masktexture,[],MTI.df.rect); end;
        StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,1);
        for frameNum=2:length(MTI.df.frames),
            % this should really be measured from each interval for most accurate "local" display
            Screen('LoadNormalizedGammaTable',StimWindow, MTI.ds.clut{MTI.df.frames(frameNum)},1);
            vbl=Screen('Flip',StimWindow,vbl+(MTI.pauseRefresh(frameNum-1)+0.5)/StimWindowRefresh,2);
            %Screen('Flip',StimWindow,vbl+(sum(1+MTI.pauseRefresh(1:frameNum-1))-0.5)/StimWindowRefresh,2);
            frameTimes(frameNum)=StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,frameNum);
            StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,frameNum);
        end;
        Screen('Flip',StimWindow,vbl+(MTI.pauseRefresh(end)+0.5)/StimWindowRefresh); % the +0.5 is here because these pause times for CLUTanims can range from -1 due to backward compatibility
    end;
    
elseif strcmp(MTI.ds.displayType,'Movie')&strcmp(MTI.ds.displayProc,'standard'),
    startStopTimes(2) = StimTriggerAct('Stim_ONSET_trigger',MTI.stimid);
    if NS_PTBv<3,
        Screen(StimWindow,'SetClut',MTI.ds.clut); % does waitblanking
        Screen('CopyWindow',MTI.ds.offscreen(MTI.df.frames(1)),StimWindow,MTI.MovieParams.Movie_sourcerect(1,:), MTI.df.rect,'srcCopyQuickly');
        frameTimes(1) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,1);
        for frameNum=2:length(MTI.df.frames);
            Screen(StimWindow,'WaitBlanking',MTI.pauseRefresh(frameNum-1));
            StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,frameNum);
            rectnum = 1+mod(MTI.df.frames(frameNum),length(MTI.ds.offscreen));
            Screen('CopyWindow',MTI.ds.offscreen(MTI.df.frames(frameNum)),StimWindow,MTI.MovieParams.Movie_sourcerect(frameNum,:), MTI.df.rect,'srcCopyQuickly');
            frameTimes(frameNum) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,frameNum);
        end;
        Screen(StimWindow,'WaitBlanking',MTI.pauseRefresh(end));
    else,
        
        Screen('LoadNormalizedGammaTable',StimWindow,MTI.ds.clut,1); % this seems to be no longer necessary or correct, the textures already have colors
        %StimWindowPreviousCLUT = repmat(linspace(0,1,256)',1,3);
        %StimWindowPreviousCLUT(:,2) = 0;
        % Screen('LoadNormalizedGammaTable',StimWindow,StimWindowPreviousCLUT);
        Screen('FillRect',StimWindow,round(MTI.ds.bg_gammauncorrected));
        frameNum = 1;
        textures = MTI.MovieParams.Movie_textures{frameNum};
        Screen('DrawTextures',StimWindow,MTI.ds.offscreen(textures),...
            squeeze(MTI.MovieParams.Movie_sourcerects(:,frameNum,textures)),...  % sourceRects
            squeeze(MTI.MovieParams.Movie_destrects(:,frameNum,textures)),...    % destinationRects
            squeeze(MTI.MovieParams.Movie_angles(:,frameNum,textures)),1,...       % rotationAngle, filterMode
            squeeze(MTI.MovieParams.Movie_globalalphas(:,frameNum,textures)),... % globalAlpha
            [],[],[], ... % modulateColor,textureShader,specialFlags
            squeeze(MTI.MovieParams.Movie_auxparameters(:,frameNum,textures))); % auxParameters
             
        if StimWindowUseCLUTMapping, Screen('LoadNormalizedGammaTable',StimWindow,linspace(0,1,256)' * ones(1,3),1); end;
        
        
        vbl = Screen('Flip',StimWindow,0);
        frameTimes(1) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,1);

        capture_image = false;
        if capture_image;
            imageArray = Screen('GetImage', StimWindow);
            imwrite(imageArray,fullfile(getdesktopfolder,'stimulus_frame.png'),'png')
        end
        

        if capture_movie; Screen('AddFrameToMovie', StimWindow); end
        %Screen('FillRect',StimWindow,255*MTI.ds.clut(1,:,:)); % fill the other buffer with background -- seems to be unnecessary
        StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,1);
        
        for frameNum=2:length(MTI.df.frames);
            textures = MTI.MovieParams.Movie_textures{frameNum};            
            Screen('DrawTextures',StimWindow,MTI.ds.offscreen(textures),...
            squeeze(MTI.MovieParams.Movie_sourcerects(:,frameNum,textures)),...  % sourceRects
            squeeze(MTI.MovieParams.Movie_destrects(:,frameNum,textures)),...    % destinationRects
            squeeze(MTI.MovieParams.Movie_angles(:,frameNum,textures)),1,...       % rotationAngle, filterMode
            squeeze(MTI.MovieParams.Movie_globalalphas(:,frameNum,textures)),... % globalAlpha
            [],[],[], ... % modulateColor,textureShader,specialFlags
            squeeze(MTI.MovieParams.Movie_auxparameters(:,frameNum,textures))); % auxParameters

            
            if StimWindowUseCLUTMapping, Screen('LoadNormalizedGammaTable',StimWindow,linspace(0,1,256)' * ones(1,3),1); end;
            vbl=Screen('Flip',StimWindow,vbl+(MTI.pauseRefresh(frameNum-1)-0.5)/StimWindowRefresh);
            if capture_movie; Screen('AddFrameToMovie', StimWindow); end
           frameTimes(frameNum) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,frameNum);
            WaitSecs(1/10000);
            StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,frameNum);
        end;
        if StimWindowUseCLUTMapping, Screen('LoadNormalizedGammaTable',StimWindow,linspace(0,1,256)' * ones(1,3),1); end;
        Screen('Flip',StimWindow,vbl+(MTI.pauseRefresh(end)-0.5)/StimWindowRefresh);
        if capture_movie; Screen('AddFrameToMovie', StimWindow); end

        
    end;
    
elseif strcmp(MTI.ds.displayType,'custom'),
    done=0; stamp=0; info=[]; stampNum=1;
    startStopTimes(2) = StimTriggerAct('Stim_ONSET_trigger',MTI.stimid);
    while(done==0),
        eval(['[done,stamp,info]=' MTI.ds.displayProc '(info,StimWindow,MTI.ds,MTI.df);']);
        if stamp==1, % make a time stamp
            frameTimes(stampNum) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,stampNum);
            stampNum = stampNum + 1;
            StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,stampNum);
        end;
    end;
    
elseif strcmp(MTI.ds.displayProc,'customdraw'), % calls the stim's 'customdraw' function
    done=0; stamp=0; info=[]; stampNum=1;
    startStopTimes(2) = StimTriggerAct('Stim_ONSET_trigger',MTI.stimid);
    while(done==0),
        eval(['[done,stamp,info]=customdraw(stim,info,MTI);']);
        if stamp==1, % make a time stamp
            frameTimes(stampNum) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,stampNum);
            stampNum = stampNum + 1;
            StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,stampNum);
        end;
    end;
    
    
elseif strcmpi(MTI.ds.displayType,'QUICKTIME'),   % note, quicktime play only supported in PTB-3
    Screen('LoadNormalizedGammaTable',StimWindow,StimWindowPreviousCLUT);
    Screen('SetMovieTimeIndex', MTI.ds.userfield.movie, 0); % play from beginning, regardless of where we played last time
    done = 0; frameNum = 0;
    startStopTimes(2) = StimTriggerAct('Stim_ONSET_trigger',MTI.stimid);
    Screen('PlayMovie',MTI.ds.userfield.movie,1);
    while ~done,
        if frameNum>0, StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,frameNum); end;
        tex = Screen('GetMovieImage',StimWindow,MTI.ds.userfield.movie);
        if tex<=0, done = 1; break; % detect hitting the end of the movie
        else,
            frameNum = frameNum + 1;
            Screen('DrawTexture',StimWindow,tex,[],MTI.df.rect);
            if StimWindowUseCLUTMapping, Screen('LoadNormalizedGammaTable',StimWindow,linspace(0,1,256)' * ones(1,3),1); end;
            Screen('Flip',StimWindow);
            frameTimes(frameNum) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,frameNum);
            Screen('Close',tex);
        end;
    end;
    Screen('PlayMovie',MTI.ds.userfield.movie,0); % stop the movie from playing
    
elseif strcmp(MTI.ds.displayType,'Sound'),
    startStopTimes(2) = StimTriggerAct('Stim_ONSET_trigger',MTI.stimid);
    Snd('Play',MTI.ds.userfield.sound,MTI.ds.userfield.rate);
    StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,1);
    Snd('Wait');
    frameTimes(1) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,1);
end;


if MTI.postBGframes>0,
    if NS_PTBv<3,
        Screen(StimWindow,'SetClut',MTI.ds.clut_bg);
        startStopTimes(3) = StimTriggerAct('Stim_OFFSET_trigger',MTI.stimid);
        Screen(StimWindow,'WaitBlanking',MTI.postBGframes);
    else,
        if 1,
            vbl = show_background(StimWindow,MTI,[]);
            show_background(StimWindow,MTI, vbl + (MTI.preBGframes-0.5)/StimWindowRefresh);
            if capture_movie; Screen('AddFrameToMovie', StimWindow); end
        elseif strcmpi(MTI.ds.displayType,'CLUTanim'),
            Screen(StimWindow,'FillRect',round(255*MTI.ds.clut_bg(1,:,:))); % make sure background is in 2nd buffer
            vbl = Screen('Flip', StimWindow, 0); % wait for blanking
            Screen(StimWindow,'FillRect',round(255*MTI.ds.clut_bg(1,:,:))); % make sure background is in 2nd buffer
            WaitSecs(0.2);
            % Screen('LoadNormalizedGammaTable', StimWindow, MTI.ds.clut_bg,1);
        else
            Screen('FillRect',StimWindow,round(255*MTI.ds.clut_bg(1,:,:))); % make sure background is installed
            vbl = Screen('Flip', StimWindow, 0); % wait for blanking
            Screen('FillRect',StimWindow,round(255*MTI.ds.clut_bg(1,:,:))); % make sure background is installed
            WaitSecs(0.2);
            if StimWindowUseCLUTMapping, Screen('LoadNormalizedGammaTable',StimWindow,linspace(0,1,256)' * ones(1,3),1); end;
        end;
        startStopTimes(3) = StimTriggerAct('Stim_OFFSET_trigger',MTI.stimid);
        Screen('Flip', StimWindow, vbl + (MTI.postBGframes+0.5)/StimWindowRefresh);
        if capture_movie; Screen('AddFrameToMovie', StimWindow,[],[],[],MTI.postBGframes); end
        WaitSecs(0.2);
    end;
else,
    startStopTimes(3) = StimTriggerAct('Stim_OFFSET_trigger',MTI.stimid);
end;


% hardcoded optogenetics trigger off
StimSerialGlobals
StimSerial('rts',StimSerialStim,0);

%show_background(StimWindow,MTI,[],1)
%show_background(StimWindow,MTI,[],1)

startStopTimes(4) = StimTriggerAct('Stim_BGpost_trigger',MTI.stimid);

if strcmp(MTI.ds.displayType,'Sound'), Snd('Close'); end;


if MTI.ds.makeClip&NS_PTBv<3, % clear the clipping region
    Screen(StimWindow,'SetDrawingRegion',StimWindowRect);
end;



function vbl = show_background(StimWindow,MTI,when,dontsync)
% shows background color in normalized color table of stimulus.
% Note that background color table should then not be corrected by itself.
% Note: order of flip parameters is not identical to Screen('Flip') itself
if nargin<3
    when = [];
end
if isempty(when)
    when = 0;
end
if nargin<4
    dontsync = [];
end
if isempty(dontsync)
    dontsync = 0;
end

%StimWindowPreviousCLUT = repmat(linspace(0,1,256)',1,3);
%Screen('LoadNormalizedGammaTable', StimWindow, StimWindowPreviousCLUT,1);
%currLut = Screen('ReadNormalizedGammaTable', StimWindow);
%Screen('LoadNormalizedGammaTable',StimWindow,currLut,1);

Screen('LoadNormalizedGammaTable',StimWindow,MTI.ds.clut,1);
Screen(StimWindow,'FillRect',round(MTI.ds.bg_gammauncorrected));
vbl = Screen('Flip',StimWindow,when,0,dontsync);



