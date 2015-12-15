function [freezeTimes, flightTimes, pos_theta, head_theta, approach] = trackmouseblack_pi(filename,showMovie,stimStart,startside)
%% Trackmouseblack function tracks mouse on basis of his black color and contrast with light background.
% 09-03-2015 Sven van der Burg
% Azadeh Tafreshiha Dec 2015, added angle calculations

% Input arguments are the filename and a logical value telling this
% function to show the video and analysis in figures or not. Output
% variables are the timepoints when animal is freezing (freezeTimes) and
% timepoints when animal is fleeing (flightTimes). Both are matrices with
% two colomuns, first column represents start time, second column stop
% time. Each row represents a different flight/freeze episode

% filename = 'redfoot1.mp4';
% filename = 'Redfoot2-1.mp4';
% filename = 'black1.mp4';
% filename = 'blackreddot2.mp4';

% Read in videofile
vid=VideoReader(filename);
%Get paramters of video
numFrames = get(vid, 'NumberOfFrames');
frameRate = get(vid, 'FrameRate'); %30 frames/sec
vidFrames = read(vid, 1);
Frame=vidFrames(:,:,:,1);
s=size(Frame);
secBeforeAfter = 10;
framesBeforeAfter = secBeforeAfter *frameRate;
stimFrame = round(stimStart*frameRate);
frameRange = stimFrame - framesBeforeAfter:stimFrame + framesBeforeAfter; % Range of frames that need to be analyzed
makeVideo = 0; % Make 1 if you want to record

blackThreshold = 0.20; % Treshold for amount of blackness to be treated as mouse %was 0.30
minAreaSize = 200; % Minimal area size for region that is tracked as mouse
difScope = 60; % The range around mouse that is included in pixelchange analysis
nestRange = [80 60]; % x, y in pixels, range from nestcenter at which mouse ist reated as in nest
freezeSmoother = [5,5]; % Amount of frames that freeze analysis is averaging over before and after current frame
difTreshold = 0.3; % treshold + minimum movement for difference between frames to be considered as no difference, fraction of average movement
freezeTreshold = 0.5; % in seconds, treshold for
deriv2Tresh = 0.05; % Treshold for 2nd derivative of vidDif %was 0.05
noNest = 1;
approach = [];
discDetection = 0; %Makes script very slow, don't run on average computer
if showMovie
    figure;
end

trajectory = [];
%% To record video
if makeVideo
    writerObj = VideoWriter('mousetracking1.avi');
    writerObj.FrameRate = frameRate;
    open(writerObj);
end

%% Make a background by averageing frames in bgframes
% The background is complemented so black shapes become white and can be
% substracted from each other.
bgframes = frameRange(1:90:600);
firstdone = 0;
for i = bgframes
    vidFrames = read(vid, i);
    Frame=vidFrames(:,:,:,1);
    if ~firstdone
        bgsum = double(Frame);
        firstdone = 1;
    else
        bgsum = bgsum + double(Frame);
    end
    
    
end
bg = bgsum/length(bgframes); % in double
double_bg = double(imcomplement(uint8(bg)));
% figure
% imshow(uint8(double_bg));
fprintf('Background is made \n');
%% Find the nest in the background
% Nest is found be cutting off the black band on the edges of the
% background image, the center of the black shape that is left is the
% center of the nest
if ~noNest
    nest = double_bg(:,:,1) > 200; %was 230
    % figure
    % imshow(nest);
    
    %determine width of cut off band for determining nest location
    
    found = 0;
    i = 1;
    while ~found
        if nest(s(1)/2,s(2)-i + 1)
            i = i +1;
        else
            found = 1;
            rightband = i;
        end
    end
    found = 0;
    i = 1;
    while ~found
        if nest(s(1)/2,i)
            i = i +1;
        else
            found = 1;
            leftband = i;
        end
    end
    found = 0;
    i = 1;
    while ~found
        if nest(i,leftband + 20)
            i = i +1;
        else
            found = 1;
            upperband = i;
        end
    end
    found = 0;
    i = 1;
    while ~found
        if nest(s(1)-i + 1,leftband + 20)
            i = i +1;
        else
            found = 1;
            bottomband = i;
        end
    end
    
    nest(1:upperband,1:s(2)) = 0;
    nest(0.4*s(1):s(1),1:s(2)) = 0;
    nest(1:s(1),s(2)-rightband:s(2)) = 0;
    nest(1:s(1),1:0.7*s(2)) = 0;
    pos=regionprops(nest, 'Centroid', 'Area');
    x = find([pos.Area] == max([pos.Area]));
    x = x(1);
    nestcenter = round(pos(x).Centroid);
    
    %  hImage=imshow(A);
    %  pn=rectangle('Position', [0, 0, 1, 1], 'EdgeColor', 'g',  'Curvature', [0 0]);
    %   set(pn, 'Position', [nestcenter(1)-60, 0,s(2)- (nestcenter(1)-60), nestcenter(2) + 60]);
    % figure
    % imshow(uint8(double_bg));
    
    fprintf('Nest is found \n');
end
%% Get a grasp of max RGB values after background subtraction
% This is important since different videos might have different illuminance
% levels
testFrames = frameRange(10:90:600);
maxRGBs = zeros(1,length(testFrames));
j = 1;
for i = testFrames
    vidFrames = read(vid, i);
    Frame = vidFrames(:,:,:,1);
    B=imcomplement(Frame);
    B = double(B) - double_bg;
    maxRGBs(j) = max(B(:));
    j = j + 1;
end
meanMaxRGB = mean(maxRGBs);
fprintf('Maximum RGB values are calculated \n');
%% The actual videoanalysis part
% Runs a for loop trough all frames that need to be analysed specified by
% frameRange. For every frame, the background is substracted. Then, the
% resulting image is tresholded to have the remainig shape which is assumed
% to be the mouse. From this, the position of the mouse is calculated.
% Around this position the mean pixelvalue change is calculated that is
% used later for freeze detection.

oldpos = 0;
finalpos = [];
oldframe = [];
vidDif = zeros(numFrames,1); % Stores the difference in frames
boolnewpos = 0;
inNest = zeros(numFrames,1); % Stores when mouse is in nest
nearNest = zeros(numFrames,1); %Stores when mouse is near nest
nearNest(frameRange(1)) = 1;

for currentframenr = frameRange  %1:5:numFrames
    vidFrames = read(vid, currentframenr);
    Frame=vidFrames(:,:,:,1);
    % Find out were the disc is
    if discDetection
        red = double(Frame(:,:,1))./double(Frame(:,:,2));
        Disc = red > 2;
    end
    % Subtraction and tresholding of current frame
    B=imcomplement(Frame);
    B = double(B) - double_bg;
    %     figure
    %         imshow(B);
    % If the maximum RGB values are smaller than this value it is better to
    % have a normalized treshold since the video is pretty blurry. This
    % might become problamatic when mouse is in the nest.
    
    if meanMaxRGB > 90
        
        mouse = B(:,:,1) > meanMaxRGB* blackThreshold;
    else
        mouse = B(:,:,1) > max(B(:))* blackThreshold;
    end
    if discDetection
        mouse(Disc) = 0; %Correct for presence of disc
    end
    %     figure
    %         imshow(mouse);
    
    % Find the position of the mouse
    
    % If the position is not found, either the old position is taken as the
    % current one if mouse is not near the nest in previous frame. If mouse
    % was near nest then he is probably in nest and the new posiiton is the
    % nestcenter
    pos=regionprops(mouse, 'Centroid', 'Area');
    if isempty(pos)
        if oldpos ~= 0
            if ~noNest && nearNest(currentframenr - 1)
                finalpos = nestcenter;
            else
                finalpos = oldpos;
            end
        elseif ~noNest
            finalpos = nestcenter;
        else
            finalpos = [0 0];
        end
    else
        
        
        
        
        % Check whether the areasize of the found shape is larger than the
        % minimum
        maxAreaInd = find([pos.Area] == max([pos.Area]));
        maxAreaInd = maxAreaInd(1);
        nearMaxInd = ([pos.Area] > pos(maxAreaInd).Area * 0.2 & [pos.Area] > minAreaSize);% was 5
        if pos(maxAreaInd).Area <= minAreaSize
            boolnewpos = 0;
            if ~noNest && nearNest(currentframenr - 1)
                finalpos = nestcenter;
            else
                finalpos = oldpos;
            end
        else
            boolnewpos = 1;
            posCentroids = [pos(nearMaxInd).Centroid];
            finalpos = [mean(posCentroids(1:2:end)), mean(posCentroids(2:2:end))];
        end
    end
    
    % This part defines the scope in which the difference between last
    % frame is calculated
    if ~isempty(oldframe) && ~isempty(finalpos) && finalpos(1) ~= 0
        if isempty(pos)
            vidDif(currentframenr - 1) = 0;
        else
            frameDif = abs(Frame - oldframe);
            if round(finalpos(1) - difScope) < 1
                difScopex1 = 1;
            else
                difScopex1 = round(finalpos(1) - difScope);
            end
            if round(finalpos(1)+ difScope) > s(2)
                difScopex2 = s(2);
            else
                difScopex2 = round(finalpos(1)+ difScope);
            end
            if round(finalpos(2) - difScope) < 1
                difScopey1 = 1;
            else
                difScopey1 = round(finalpos(2) - difScope);
            end
            if round(finalpos(2)+ difScope) > s(1)
                difScopey2 = s(1);
            else
                difScopey2 = round(finalpos(2)+ difScope);
            end
            if discDetection
                frameDif(Disc,:) = NaN; % Correct for red disc
            end
            frameDifMouse = frameDif(difScopey1:difScopey2,difScopex1:difScopex2,:);
            
            meanFrameDif = mean2(frameDifMouse);
            
            vidDif(currentframenr - 1) = meanFrameDif;
            %         reshapeFrameDif = reshape(frameDifMouse,1,(difScopey2-difScopey1 + 1) * (difScopex2 - difScopex1+ 1)*3);
            %         meanFrameDif = median(reshapeFrameDif);
            %         vidDif(currentframenr - 1) = meanFrameDif;
        end
    end
    % Show the frame and already set the difscope square and dot for
    % position of mouse
    if showMovie
        hImage=imshow(Frame);
        %         set(hImage, 'CData', Frame);
        pn=rectangle('Position', [0, 0, 1, 1], 'EdgeColor', 'b', 'FaceColor', 'b', 'Curvature', [1 1]);
        square=rectangle('Position', [0, 0, 1, 1], 'EdgeColor', 'b',  'Curvature', [0 0]);
        if ~noNest
            nest=rectangle('Position', [0, 0, 1, 1], 'EdgeColor', 'g',  'Curvature', [0 0]);
            set(nest, 'Position', [nestcenter(1)-nestRange(1) nestcenter(2)-nestRange(2) 2*nestRange(1) 2*nestRange(2)]);
            set(nest, 'EdgeColor',[0 0.7 0.5]);
            set(nest, 'LineWidth',2);
        end
        
        
        [frameHour, frameMinute, frameSec, frameMSec] = getFrameTime(currentframenr,frameRate);
        timeText = strcat(num2str(frameHour),':',num2str(frameMinute), ':',num2str(frameSec), ':',num2str(frameMSec));
        htimeText = text(s(2)-70,s(1)-20,timeText);
        set(htimeText, 'Color', 'white');
    end
    % Set whether mouse is in or near nest
    if ~isempty(finalpos) && finalpos(1) ~= 0
        if ~noNest
            if (any(ismember(nestcenter(1)-nestRange(1):round(s(2)),round(finalpos(1)))) && any(ismember(0:nestcenter(2) + nestRange(2),round(finalpos(2)))))
                inNest(currentframenr) = 1;
            elseif (any(ismember(nestcenter(1)-nestRange(1)*2:round(s(2)),round(finalpos(1)))) &&...
                    any(ismember(0:nestcenter(2) + nestRange(2)*2,round(round(finalpos(2))))))
                nearNest(currentframenr) = 1;
            end
        end
        %Save the position in the trajectory
        trajectory(currentframenr,:) = finalpos([1 2]);
        
        %Show the square and dot and make green if animal is moving, red if
        %animal is in nest and blue if animal is stationary
        if showMovie
            set(pn, 'Position', [finalpos(1)-5 finalpos(2)-5 5 5]);
            
            if exist('difScopex1','var')
                set(square, 'Position', [difScopex1 difScopey1 difScope*2 difScope*2]);
            end
            if ~noNest
                if inNest(currentframenr)
                    set(pn, 'EdgeColor', 'b');
                    set(pn, 'FaceColor', 'b');
                elseif mean(vidDif(currentframenr - 10:currentframenr -1)) < difTreshold
                    set(pn, 'EdgeColor', 'r');
                    set(pn, 'FaceColor', 'r');
                end
            end
            drawnow
        end
        
        
    end
    oldframe = Frame;
    oldpos = finalpos;
    if makeVideo
        frame = getframe;
        writeVideo(writerObj,frame);
    end
end


fprintf('Video analysis is done \n');

%% This part is flight detection
if ~noNest
    nestRangeX = nestcenter(1)-nestRange(1):round(s(2));
    nestRangeY = 0:nestcenter(2) + nestRange(2);
end
mouseSpeed = zeros(numFrames,1);
trajectorySmoother = [6 6]; % Amount of frames before and after currentframe for Kalman filtering

% Smooth the trajectory by Kalman filtering
smoothTrajectoryFrames = frameRange(trajectorySmoother(1)+1:end - trajectorySmoother(2));
smoothTrajectory = zeros(numFrames,2);
for i = smoothTrajectoryFrames
    smoothTrajectory(i,1) = mean(trajectory(i-trajectorySmoother(1):i+trajectorySmoother(2),1));
    smoothTrajectory(i,2) = mean(trajectory(i-trajectorySmoother(1):i+trajectorySmoother(2),2));
end

%Calculate new inNest and nearNest with smoothed trajectory
if ~noNest
    for i = smoothTrajectoryFrames
        if (any(ismember(nestcenter(1)-nestRange(1):round(s(2)),round(smoothTrajectory(i,1)))) &&...
                any(ismember(0:nestcenter(2) + nestRange(2),round(smoothTrajectory(i,2)))))
            inNest(i) = 1;
        elseif (any(ismember(nestcenter(1)-nestRange(1)*2:round(s(2)),round(smoothTrajectory(i,1)))) &&...
                any(ismember(0:nestcenter(2) + nestRange(2)*2,round(smoothTrajectory(i,2)))))
            nearNest(i) = 1;
        end
    end
    
else
    nearNest(smoothTrajectoryFrames) = 0;
end
% Calculate Euclidian distance (mouseSpeed)
for i = smoothTrajectoryFrames(2:end)
    deltaX = smoothTrajectory(i,1) - smoothTrajectory(i-1,1);
    deltaY = smoothTrajectory(i,2) - smoothTrajectory(i-1,2);
    if inNest(i)
        mouseSpeed(i) = 0;
    else
        mouseSpeed(i) = sqrt(deltaX^2 + deltaY^2);
    end
end
averageMouseSpeed = mean(mouseSpeed(smoothTrajectoryFrames(2:end)));
running = zeros(numFrames,1);
running = mouseSpeed > 4 * averageMouseSpeed;

flightTimes = [];
i = smoothTrajectoryFrames(1);
while i < smoothTrajectoryFrames(end)
    if all(mouseSpeed(i:i+3)' > 4 * averageMouseSpeed) && ~nearNest(i)
        startTime = i/frameRate;
        j = 1;
        %While mouse is still moving above average
        while mouseSpeed(i+j) > averageMouseSpeed && i+j < smoothTrajectoryFrames(end)
            %Check if position is in the nest
            if any(inNest(i+j + 1:i+j + 3)) % look 3 frame further to make this a bit more robust
                if all(inNest(i+j +3:i + j +20)) % He needs to stay in the nest for some time
                    
                    stopTime = (i+j + 1)/frameRate;
                    
                    flightTimes = [startTime stopTime];
                    break;
                end
            end
            j = j +1;
        end
        %Jump to i + j, since in this range a flight trajectory will not be found
        i = i + j;
        
    end
    i = i +1;
    
    
end

% Show figure of trajectory
if 0 %Change into showMovie
    figure
    flightFrames = round(flightTimes(1) *frameRate): round(flightTimes(2) *frameRate)+20;
    noFlightFrames = smoothTrajectoryFrames(1):round(flightTimes(1) *frameRate);
    hplot = plot(smoothTrajectory(noFlightFrames,1),smoothTrajectory(noFlightFrames,2),'.');
    hold on;
    flightPlot = plot(smoothTrajectory(flightFrames,1),smoothTrajectory(flightFrames,2),'.');
    
    ylim([0 , s(1)]);
    xlim([0 ,s(2)]);
    axis ij
    set(hplot, 'Color','black');
    square=rectangle('Position', [0, 0, 1, 1], 'EdgeColor', 'g',  'Curvature', [0 0]);
    set(square, 'Position', [nestcenter(1)-nestRange(1) nestcenter(2)-nestRange(2) 2*nestRange(1) 2*nestRange(1)]);
    set(square, 'EdgeColor',[0 0.7 0]);
    set(square, 'LineWidth',2);
    set(flightPlot,'LineStyle','-');
    set(hplot,'LineStyle','-');
    set(gca,'YTickLabel',[]);
    set(gca,'XTickLabel',[]);
end
logmsg('Flight detection is done \n');

%% This part is freezing detection
freezePeriodNr = 0;
firstHit = 1;
hitnr = 0;
freezeTimes = [];
% meanMove = mean(vidDif(frameRange(logical(inNest(frameRange)))));
for i = frameRange(freezeSmoother(1)+1:end-freezeSmoother(2))
    smoothVidDif(i) = mean(vidDif(i-freezeSmoother(1):i+freezeSmoother(2)));
    if i > 1
        deriv2(i) = smoothVidDif(i)-smoothVidDif(i - 1);
    end
    %     fprintf('smoothVidDif is %i\n',smoothVidDif);
    
end
averageMovement = mean(smoothVidDif(frameRange(freezeSmoother(1)+1:end-freezeSmoother(2))));
minimalMovement = min(smoothVidDif(frameRange(freezeSmoother(1)+1:end-freezeSmoother(2))));

vidlag = sum(freezeSmoother)+3;  %three frames after the stim start for the stim to be visible in the picture

for i = frameRange(freezeSmoother(1)+1:end-freezeSmoother(2))
    if smoothVidDif(i) < minimalMovement + difTreshold && deriv2(i) < deriv2Tresh && deriv2(i) > -deriv2Tresh && ~inNest(i) && smoothTrajectory(i,1) ~= 0;
        if firstHit
            startTime = i / frameRate;
            firstHit = 0;
            hitnr = 1;
            
            %get a snapshot of the first freezing frame
            if startTime > stimStart && startTime < stimStart + 4;
                snapfig = figure();
                snapaxes = axes('parent', snapfig);
                snapframe = read(vid, i+vidlag);
                image(snapframe, 'Parent', snapaxes);
                title(snapaxes, sprintf('Frame #%d, StartTime %g, StimStart %g', i+vidlag, startTime/60, stimStart/60));
                
                %get the positions of nose, arse and stim manually
                nose = ginput(1);
                arse = ginput(1);
                hold on
                plot([nose(1),arse(1)],[nose(2),arse(2)]); %head line
                
                mouseX = arse(1) - nose(1);
                mouseY = arse(2) - nose(2);
                mouse_alpha = (atan(mouseX/mouseY)).*180./pi; %deg
                mouse_theta = (atan(mouseY/mouseX)).*180./pi;
                
                stimpos = ginput(1);
                plot([nose(1),stimpos(1)],[nose(2),stimpos(2)]); %position line
                plot(stimpos) %stim line
                
                posX = stimpos(1) - nose(1);
                posY = stimpos(2) - nose(2);
                stim_theta = (atan(posY/posX)).*180./pi; %deg;
                stim_alpha = (atan(posX/posY)).*180./pi;
                
                %calculate the angles(deg), stimulus approaching or
                %receding
                if posX > 0 %stimulus on the right of the nose
                    
                    if posY > 0 %stimulus below the nose
                    pos_theta = 180 - ((stim_theta) + (mouse_theta)); %position angle: the angle head line makes with stim line
                    else
                    pos_theta = (180 - (mouse_theta)) + (mouse_theta);
                    end
                    
                    head_theta = (atan(posY/posX)).*180./pi; %head angle with stim trajectory
                    
                else
                    
                    if posY > 0 %stimulus below the nose
                    pos_theta = 180 - ((stim_theta) - (mouse_theta)); %position angle: the angle head line makes with stim line
                    else
                    pos_theta = 180 - ((stim_theta) + (mouse_theta));
                    end
                    
                    head_theta = 180 - ((atan(posY/posX)).*180./pi); %head angle with stim trajectory
                end
                
                if head_theta < 90
                    approach = 1; % stimulus is moving toward the mouse
                else
                    approach = 0; %stimulus is moving away from the mouse
                end
                
                stim_theta = atan((nose(2)-arse(2))/(nose(1)- arse(1)));
                pos_theta = 180 - (abs(head_theta) + abs(stim_theta)); %the angle that stim makes with the head line
              
                if pos_theta > 180
                   pos_theta = 360 - pos_theta;
               end
                 
            end
        else
            hitnr = hitnr + 1;
            %             fprintf('%d\n', hitnr);
        end
    else
        if hitnr/frameRate > freezeTreshold
            stopTime = (i-1) / frameRate;
            freezePeriodNr = freezePeriodNr + 1;
            freezeTimes(freezePeriodNr,1:2) = [startTime stopTime];
        end
        firstHit = 1;
        hitnr = 0;
    end
end
% figure
% plot(deriv2(frameRange(freezeSmoother(1)+1:end-freezeSmoother(2))));
if 1
    figure
    subplot(2,1,1);
    plot(smoothVidDif(frameRange(freezeSmoother(1)+1:end-freezeSmoother(2))));
    set(gca, 'xtick', 0:30:600);
    set(gca, 'XTickLabel', (-10:10));
    set(gca,'xgrid','on');
    hold on
    plot(1:length(frameRange(freezeSmoother(1)+1:end-freezeSmoother(2))),averageMovement);
    plot(1:length(frameRange(freezeSmoother(1)+1:end-freezeSmoother(2))),minimalMovement+difTreshold);
    subplot(2,1,2);
    plot([1,length(frameRange(freezeSmoother(1)+1:end-freezeSmoother(2)))], [deriv2Tresh,deriv2Tresh], 'black');
    hold on
    plot([1,length(frameRange(freezeSmoother(1)+1:end-freezeSmoother(2)))], [-deriv2Tresh,-deriv2Tresh], 'black');
    plot(deriv2(frameRange(freezeSmoother(1)+1:end-freezeSmoother(2))));
    xlabel('seconds')
    set(gca, 'xtick', 0:30:600);
    set(gca, 'XTickLabel', (-10:10));
    set(gca,'xminorgrid','off');  
end

fprintf('Freeze detection is done \n');

if makeVideo
    close(writerObj);
end
end
function [frameHour,frameMinute,frameSec,frameMSec] = getFrameTime(frameNr,frameRate)
totalSecs = floor(frameNr/(frameRate));
totalMinutes = floor(totalSecs/60);
frameSec = round((totalSecs/60 - totalMinutes)*60);
frameMSec = round((frameNr /frameRate -totalSecs) *100);
frameHour = floor(totalMinutes/60);
frameMinute = totalMinutes - frameHour * 60;
if frameHour == 0
    frameHour = [];
end

end
