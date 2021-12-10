function [intDone, dblStamp, StimInfo] = customdraw(StimObj, StimInfo, ~, ~)
% DRAWMOVINGELLIPSE of PRESENTFLYOVER to draw an ellipse moving across the screen
%
% 2021, Robin Haak

%% set debug switch
boolDebug = false;

%% retrieve parameters

%NewStim parameters
if boolDebug == false
    NewStimGlobals %for pixels_per_cm and NewStimViewingDistance
    StimWindowGlobals %for StimWindowRefresh (i.e., framerate)
elseif boolDebug == true
    pixels_per_cm = 1920/50;
    NewStimViewingDistance = 20;%cm
    StimWindowRefresh = 60;%Hz
end

%input parameters (defined in PRESENTFLYOVER)
if boolDebug == false
    sStimParams = getparameters(StimObj);
elseif boolDebug == true
    clearvars sStimParams
    sStimParams.strStimType = 'disc'; %'disc' or 'ellipse'
    sStimParams.strStartPosition = 'left'; %'right' or 'left', irrelevant if boolRandomTrajectory == true
    sStimParams.vecDiscSizeDeg = [4.1 4.1]; %deg
    sStimParams.vecEllipseSizeDeg = [1.6  4.4]; %deg
    sStimParams.dblVelocityDeg = 39; %stimulus speed, deg/s
    sStimParams.boolRandomTrajectory = false; %if true, x-position is randomized
    sStimParams.dblStimulusIntensity = 0; %background intensity ([0 1], 0 = black)
    sStimParams.dblBackgroundIntensity = 0.5; %background intensity ([0 1], 0.5 = mean gray)
end
intBackgroundIntensity = round(mean(sStimParams.dblBackgroundIntensity)*255);

%% open window for testing (while debugging)
if boolDebug == true
    [StimWindow, StimWindowRect] = Screen('OpenWindow', 0, intBackgroundIntensity, [0 0 640 360]);
end

%% set stimulus parameters
vecScreenSizePix =  [StimWindowRect(4) StimWindowRect(3)];
dblStimCenterPixY = vecScreenSizePix(1)/2; %y-coordinate of the stimulus trajectory, fixed for now to the middle of the screen
dblPixelsPerDegree = tan(pi/(2*180))*NewStimViewingDistance*pixels_per_cm*2;
dblVelocityPix = sStimParams.dblVelocityDeg*dblPixelsPerDegree; %pix/s
dblVelocityFrame = dblVelocityPix/StimWindowRefresh; %pix/frame
intNumFrames = round(vecScreenSizePix(2)/dblVelocityFrame); %number of frames needed to animate movement
intStimulusIntensity = round(mean(sStimParams.dblStimulusIntensity)*255);

if strcmp(sStimParams.strStimType, 'disc')
    vecStimExtentPix = sStimParams.vecDiscSizeDeg*dblPixelsPerDegree;
elseif strcmp(sStimParams.strStimType, 'ellipse')
    vecStimExtentPix = sStimParams.vecEllipseSizeDeg*dblPixelsPerDegree;
end

%% show the stimulus
fprintf('Showing %s, expected duration %.2f seconds\n', sStimParams.strStimType, round(intNumFrames/StimWindowRefresh, 2))
if sStimParams.boolRandomTrajectory == true
    fprintf('Random order\n');
end

tic
dblStamp = Screen('Flip', StimWindow);
if strcmp(sStimParams.strStartPosition, 'left') && sStimParams.boolRandomTrajectory == false
    dblStimCenterPixX = 0;
    for i = 1:intNumFrames
        vecBoundingRect = [dblStimCenterPixX-vecStimExtentPix(1)/2, dblStimCenterPixY-vecStimExtentPix(2)/2, ...
            dblStimCenterPixX+vecStimExtentPix(1)/2, dblStimCenterPixY+vecStimExtentPix(2)/2];
        Screen('FillOval', StimWindow, intStimulusIntensity, vecBoundingRect);
        dblStamp = Screen('Flip', StimWindow, dblStamp+0.5/StimWindowRefresh);
        dblStimCenterPixX = dblStimCenterPixX+dblVelocityFrame;
    end
elseif strcmp(sStimParams.strStartPosition, 'right')  && sStimParams.boolRandomTrajectory == false
     dblStimCenterPixX = vecScreenSizePix(2);
    for i = 1:intNumFrames
        vecBoundingRect = [dblStimCenterPixX-vecStimExtentPix(1)/2, dblStimCenterPixY-vecStimExtentPix(2)/2, ...
            dblStimCenterPixX+vecStimExtentPix(1)/2, dblStimCenterPixY+vecStimExtentPix(2)/2];
        Screen('FillOval', StimWindow, intStimulusIntensity, vecBoundingRect);
        dblStamp = Screen('Flip', StimWindow, dblStamp+0.5/StimWindowRefresh);
        dblStimCenterPixX = dblStimCenterPixX-dblVelocityFrame;
    end
elseif sStimParams.boolRandomTrajectory == true
    dblStimTrajectoryPixX = zeros(intNumFrames, 1);
    for i = 2:intNumFrames; dblStimTrajectoryPixX(i) = dblStimTrajectoryPixX(i-1)+dblVelocityFrame; end
    dblStimTrajectoryPixX = dblStimTrajectoryPixX(randperm(length(dblStimTrajectoryPixX)));
    for i = 1:intNumFrames
        dblStimCenterPixX = dblStimTrajectoryPixX(i);
        vecBoundingRect = [dblStimCenterPixX-vecStimExtentPix(1)/2, dblStimCenterPixY-vecStimExtentPix(2)/2, ...
            dblStimCenterPixX+vecStimExtentPix(1)/2, dblStimCenterPixY+vecStimExtentPix(2)/2];
        Screen('FillOval', StimWindow, intStimulusIntensity, vecBoundingRect);
        dblStamp = Screen('Flip', StimWindow, dblStamp+0.5/StimWindowRefresh);
    end
end
Screen('Flip', StimWindow, dblStamp+0.5/StimWindowRefresh);
dblStimDuration = toc;
fprintf('Done! Stimulus took %.2f seconds\n', dblStimDuration);

%% finish
intDone = 1;
dblStamp = [];
