function [freezeTimes, nose, arse, stim, mouse_move, move_2der,trajectory_length,...
    averageMovement,minimalMovement,difTreshold,deriv2Tresh, freeze_duration] =...
    trackmouseblack_pi_legacy(filename,showMovie,stimStart,startside,peakPoints, record)
%% Trackmouseblack_pi_legacy tracks mouse on basis of his black color and
%contrast with light background.
% 09-03-2015 Sven van der Burg Azadeh Tafreshiha Dec 2015, added mouse and
% stim position

% Input arguments are the filename and a logical value telling this
% function to show the video and analysis in figures or not. Output
% variables are the timepoints when animal is freezing (freezeTimes) and
% timepoints when animal is fleeing (flightTimes). Both are matrices with
% two colomuns, first column represents start time, second column stop
% time. Each row represents a different flight/freeze episode

% filename = 'redfoot1.mp4'; filename = 'Redfoot2-1.mp4'; filename =
% 'black1.mp4'; filename = 'blackreddot2.mp4';

% Read in videofile
%
%  Uses old VideoReader implementation


            gamma  = 0.3;


vid=VideoReader(filename);
%Get paramters of video
numFrames = get(vid, 'NumberOfFrames');

frameRate = get(vid, 'FrameRate'); %30 frames/sec

vidFrames = read(vid, 1);
Frame=vidFrames(:,:,:,1);
s=size(Frame);
secBeforeAfter = 10;
framesBeforeAfter = secBeforeAfter *frameRate;

%%
    stimFrame = stimStart*frameRate;
    firstframe = read(vid,floor(stimFrame));
    filename2 = fullfile(experimentpath(record),'firstframe.mat');
    save(filename2, 'firstframe');
    %%

if ~isempty(record.stimstartframe)
    stimFrame = record.stimstartframe;
else
    stimFrame = stimStart*frameRate; %round(stimStart*frameRate);
end

% Range of frames that need to be analyzed
frameRange = (stimFrame - framesBeforeAfter):(stimFrame + framesBeforeAfter);

ActStimFrame = []; ActStartTime = []; ActEndFrame = []; ActEndTime = [];

if ~isempty(peakPoints)
    peakPointR = peakPoints(1,:);
    peakPointL = peakPoints(2,:);
    ActStimFrame = min([peakPointR(1), peakPointL(1)]);
    ActStartTime = ActStimFrame/30;
    ActEndFrame = max([peakPointR(1), peakPointL(1)]);
    ActEndTime = ActEndFrame/30;
else
    logmsg('stimulus not detected');
    ActStartTime = stimStart;
    ActEndTime = stimStart+3;
end

% fig_n = [];
% figHandles = findall(0,'Type','figure');
% fig_n = max(figHandles)+1;

makeVideo = 0; % Make 1 if you want to record

blackThreshold = 0.20; % Treshold for amount of blackness to be treated as mouse %was 0.30
minAreaSize = 200; % Minimal area size for region that is tracked as mouse
difScope = 50; % The range around mouse that is included in pixelchange analysis %was 60
% nestRange = [80 60]; % x, y in pixels, range from nestcenter at which
% mouse ist reated as in nest
freezeSmoother = [5,5]; % Amount of frames that freeze analysis is averaging
% over before and after current frame
difTreshold = 0.3; % treshold + minimum movement for difference between frames
% to be considered as no difference, fraction of average movement %was 0.3
freezeTreshold = 0.5; % in seconds, treshold for %was 1
deriv2Tresh = 0.08; % Treshold for 2nd derivative of vidDif %was 0.05
noNest = 1;
discDetection = 0; %Makes script very slow, don't run on average computer

showMovie = 0;
if showMovie
    figure;
end

trajectory = [];
%% To record video
if makeVideo
    writerObj = VideoWriter('mousetracking1.avi'); %#ok<UNRCH>
    writerObj.FrameRate = frameRate;
    open(writerObj);
end

%% Make a background by averageing frames in bgframes
% The background is complemented so black shapes become white and can be
% substracted from each other.
bgframes = frameRange(1:90:600);
firstdone = 0;
for i = bgframes
    vidFrames = read(vid, floor(i));
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
% figure imshow(uint8(double_bg));
logmsg('Background is made');
% %% Find the nest in the background % Nest is found be cutting off the
% black band on the edges of the % background image, the center of the
% black shape that is left is the % center of the nest if ~noNest
%     nest = double_bg(:,:,1) > 200; %was 230 % figure % imshow(nest);
%
%     %determine width of cut off band for determining nest location
%
%     found = 0; i = 1; while ~found
%         if nest(s(1)/2,s(2)-i + 1)
%             i = i +1;
%         else
%             found = 1; rightband = i;
%         end
%     end found = 0; i = 1; while ~found
%         if nest(s(1)/2,i)
%             i = i +1;
%         else
%             found = 1; leftband = i;
%         end
%     end found = 0; i = 1; while ~found
%         if nest(i,leftband + 20)
%             i = i +1;
%         else
%             found = 1; upperband = i;
%         end
%     end found = 0; i = 1; while ~found
%         if nest(s(1)-i + 1,leftband + 20)
%             i = i +1;
%         else
%             found = 1; bottomband = i;
%         end
%     end
%
%     nest(1:upperband,1:s(2)) = 0; nest(0.4*s(1):s(1),1:s(2)) = 0;
%     nest(1:s(1),s(2)-rightband:s(2)) = 0; nest(1:s(1),1:0.7*s(2)) = 0;
%     pos=regionprops(nest, 'Centroid', 'Area'); x = find([pos.Area] ==
%     max([pos.Area])); x = x(1); nestcenter = round(pos(x).Centroid);
%
%     %  hImage=imshow(A); %  pn=rectangle('Position', [0, 0, 1, 1],
%     'EdgeColor', 'g',  'Curvature', [0 0]); %   set(pn, 'Position',
%     [nestcenter(1)-60, 0,s(2)- (nestcenter(1)-60),...
% nestcenter(2) + 60]);
%     % figure % imshow(uint8(double_bg));
%
%     logmsg('Nest is found \n');
% end
%% Get a grasp of max RGB values after background subtraction
% This is important since different videos might have different illuminance
% levels
testFrames = frameRange(10:90:600);
maxRGBs = zeros(1,length(testFrames));
j = 1;
for i = testFrames
    vidFrames = read(vid, floor(i)); %floor for 2018a
    Frame = vidFrames(:,:,:,1);
    B=imcomplement(Frame);
    B = double(B) - double_bg;
    maxRGBs(j) = max(B(:));
    j = j + 1;
end
meanMaxRGB = mean(maxRGBs);
logmsg('Maximum RGB values are calculated');
%% The actual videoanalysis part
% Runs a for loop trough all frames that need to be analysed specified by
% frameRange. For every frame, the background is substracted. Then, the
% resulting image is tresholded to have the remainig shape which is assumed
% to be the mouse. From this, the position of the mouse is calculated.
% Around this position the mean pixelvalue change is calculated that is
% used later for freeze detection.

oldpos = 0;
finalpos = []; %#ok<NASGU>
oldframe = [];
vidDif = zeros(numFrames,1); % Stores the difference in frames
boolnewpos = 0;%#ok<NASGU>
inNest = zeros(numFrames,1);%#ok<NASGU> % Stores when mouse is in nest
nearNest = zeros(numFrames,1); %Stores when mouse is near nest
nearNest(round(frameRange(1))) = 1;

for currentframenr = frameRange %1:5:numFrames
    vidFrames = read(vid, floor(currentframenr));
    Frame=vidFrames(:,:,:,1);
    % Find out were the disc is
    if discDetection
        red = double(Frame(:,:,1))./double(Frame(:,:,2)); %#ok<UNRCH>
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
        mouse(Disc) = 0; %#ok<UNRCH> %Correct for presence of disc
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
        nearMaxInd = ([pos.Area] > pos(maxAreaInd).Area * 0.2 & [pos.Area]>...
            minAreaSize);% was 5
        if pos(maxAreaInd).Area <= minAreaSize
            boolnewpos = 0; %#ok<NASGU>
            if ~noNest && nearNest(currentframenr - 1)
                finalpos = nestcenter;
            else
                finalpos = oldpos;
            end
        else
            boolnewpos = 1; %#ok<NASGU>
            posCentroids = [pos(nearMaxInd).Centroid];
            finalpos = [mean(posCentroids(1:2:end)), mean(posCentroids(2:2:end))];
        end
    end
    
    % This part defines the scope in which the difference between last
    % frame is calculated
    if ~isempty(oldframe) && ~isempty(finalpos) && finalpos(1) ~= 0
        if isempty(pos)
            vidDif(floor(currentframenr) - 1) = 0;
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
                frameDif(Disc,:) = NaN; %#ok<UNRCH> % Correct for red disc
            end
            frameDifMouse = frameDif(difScopey1:difScopey2,difScopex1:difScopex2,:);
            
            meanFrameDif = mean2(frameDifMouse);
            
            vidDif(round(currentframenr) - 1) = meanFrameDif;
            %         reshapeFrameDif =
            %         reshape(frameDifMouse,1,(difScopey2-difScopey1 +
            %         1)...
            %             *(difScopex2 - difScopex1+ 1)*3);
            %         meanFrameDif = median(reshapeFrameDif);
            %         vidDif(currentframenr - 1) = meanFrameDif;
        end
    end
    % Show the frame and already set the difscope square and dot for
    % position of mouse
    if showMovie
        hImage=imshow(Frame); %#ok<NASGU>
        %         set(hImage, 'CData', Frame);
        pn=rectangle('Position', [0, 0, 1, 1], 'EdgeColor', 'b', 'FaceColor',...
            'b', 'Curvature', [1 1]);
        square=rectangle('Position', [0, 0, 1, 1], 'EdgeColor', 'b',  'Curvature', [0 0]);
        %         if ~noNest
        %             nest=rectangle('Position', [0, 0, 1, 1], 'EdgeColor',
        %             'g',...
        %         'Curvature', [0 0]);
        %             set(nest, 'Position', [nestcenter(1)-nestRange(1)...
        %         nestcenter(2)-nestRange(2) 2*nestRange(1)
        %         2*nestRange(2)]);
        %             set(nest, 'EdgeColor',[0 0.7 0.5]); set(nest,
        %             'LineWidth',2);
        %         end
        
        
        [frameHour, frameMinute, frameSec, frameMSec] = getFrameTime(currentframenr,frameRate);
        timeText = strcat(num2str(frameHour),':',num2str(frameMinute), ':',...
            num2str(frameSec), ':',num2str(frameMSec));
        htimeText = text(s(2)-70,s(1)-20,timeText);
        set(htimeText, 'Color', 'white');
    end
    
    % Set whether mouse is in or near nest
    if ~isempty(finalpos) && finalpos(1) ~= 0
        %         if ~noNest
        %             if
        %             (any(ismember(nestcenter(1)-nestRange(1):round(s(2)),...
        %         round(finalpos(1)))) && any(ismember(0:nestcenter(2)+...
        %         nestRange(2),round(finalpos(2)))))
        %                 inNest(currentframenr) = 1;
        %             elseif
        %             (any(ismember(nestcenter(1)-nestRange(1)*2:round(s(2)),...
        %         round(finalpos(1)))) &&...
        %                     any(ismember(0:nestcenter(2) +
        %                     nestRange(2)*2,...
        %         round(round(finalpos(2))))))
        %                 nearNest(currentframenr) = 1;
        %             end
        %         end
        
        %Save the position in the trajectory
        trajectory(round(currentframenr),:) = finalpos([1 2]);
        
        %Show the square and dot and make green if animal is moving, red if
        %animal is in nest and blue if animal is stationary
        if showMovie
            set(pn, 'Position', [finalpos(1)-5 finalpos(2)-5 5 5]);
            
            if exist('difScopex1','var')
                set(square, 'Position', [difScopex1 difScopey1 difScope*2 difScope*2]);
            end
            %             if ~noNest
            %                 if inNest(currentframenr)
            %                     set(pn, 'EdgeColor', 'b'); set(pn,
            %                     'FaceColor', 'b');
            %                 elseif mean(vidDif(currentframenr -
            %                 10:currentframenr -1))...
            %             < difTreshold
            %                     set(pn, 'EdgeColor', 'r'); set(pn,
            %                     'FaceColor', 'r');
            %                 end
            %             end
            drawnow
        end
    end
    
    oldframe = Frame;
    oldpos = finalpos;
    
    if makeVideo
        frame = getframe; %#ok<UNRCH>
        writeVideo(writerObj,frame);
    end
end

logmsg('Video analysis is done');


trajectorySmoother = [6 6]; % Amount of frames before and after currentframe for Kalman filtering

% Smooth the trajectory by Kalman filtering
smoothTrajectoryFrames = round(frameRange(trajectorySmoother(1)+1:end - trajectorySmoother(2)));
smoothTrajectory = zeros(numFrames,2);

for i = smoothTrajectoryFrames
    smoothTrajectory(i,1) = mean(trajectory(i-trajectorySmoother(1):i+trajectorySmoother(2),1));
    smoothTrajectory(i,2) = mean(trajectory(i-trajectorySmoother(1):i+trajectorySmoother(2),2));
end

%% This part is flight detection
% if ~noNest
%     nestRangeX = nestcenter(1)-nestRange(1):round(s(2)); nestRangeY =
%     0:nestcenter(2) + nestRange(2);
% end mouseSpeed = zeros(numFrames,1);

%Calculate new inNest and nearNest with smoothed trajectory
% if ~noNest
%     for i = smoothTrajectoryFrames
%         if
%         (any(ismember(nestcenter(1)-nestRange(1):round(s(2)),round(smoothTrajectory(i,1))))
%         &&...
%                 any(ismember(0:nestcenter(2) +
%                 nestRange(2),round(smoothTrajectory(i,2)))))
%             inNest(i) = 1;
%         elseif
%         (any(ismember(nestcenter(1)-nestRange(1)*2:round(s(2)),round(smoothTrajectory(i,1))))
%         &&...
%                 any(ismember(0:nestcenter(2) +
%                 nestRange(2)*2,round(smoothTrajectory(i,2)))))
%             nearNest(i) = 1;
%         end
%     end
%
% else
%     nearNest(smoothTrajectoryFrames) = 0;
% end Calculate Euclidian distance (mouseSpeed) for i =
% smoothTrajectoryFrames(2:end)
%     deltaX = smoothTrajectory(i,1) - smoothTrajectory(i-1,1); deltaY =
%     smoothTrajectory(i,2) - smoothTrajectory(i-1,2); if inNest(i)
%         mouseSpeed(i) = 0;
%     else
%         mouseSpeed(i) = sqrt(deltaX^2 + deltaY^2);
%     end
% end averageMouseSpeed = mean(mouseSpeed(smoothTrajectoryFrames(2:end)));
% running = zeros(numFrames,1); running = mouseSpeed > 4 *
% averageMouseSpeed;

% flightTimes = []; i = smoothTrajectoryFrames(1); while i <
% smoothTrajectoryFrames(end)
%     if all(mouseSpeed(i:i+3)' > 4 * averageMouseSpeed) && ~nearNest(i)
%         startTime = i/frameRate; j = 1; %While mouse is still moving
%         above average while mouseSpeed(i+j) > averageMouseSpeed && i+j <
%         smoothTrajectoryFrames(end)
%             %Check if position is in the nest if any(inNest(i+j + 1:i+j +
%             3)) % look 3 frame further to make
% this a bit more robust
%                 if all(inNest(i+j +3:i + j +20)) % He needs to stay in
%                 the nest for some time
%
%                     stopTime = (i+j + 1)/frameRate;
%
%                     flightTimes = [startTime stopTime]; break;
%                 end
%             end j = j +1;
%         end %Jump to i + j, since in this range a flight trajectory will
%         not be found i = i + j;
%
%     end i = i +1;
%
%
% end

% Show figure of trajectory if 0 %Change into showMovie
%     figure flightFrames = round(flightTimes(1) *frameRate):
%     round(flightTimes(2) *frameRate)+20; noFlightFrames =
%     smoothTrajectoryFrames(1):round(flightTimes(1) *frameRate); hplot =
%     plot(smoothTrajectory(noFlightFrames,1),smoothTrajectory(noFlightFrames,2),'.');
%     hold on; flightPlot =
%     plot(smoothTrajectory(flightFrames,1),smoothTrajectory(flightFrames,2),'.');
%
%     ylim([0 , s(1)]); xlim([0 ,s(2)]); axis ij set(hplot,
%     'Color','black'); square=rectangle('Position', [0, 0, 1, 1],
%     'EdgeColor', 'g',  'Curvature', [0 0]); set(square, 'Position',
%     [nestcenter(1)-nestRange(1) nestcenter(2)-nestRange(2)...
% 2*nestRange(1) 2*nestRange(1)]);
%     set(square, 'EdgeColor',[0 0.7 0]); set(square, 'LineWidth',2);
%     set(flightPlot,'LineStyle','-'); set(hplot,'LineStyle','-');
%     set(gca,'YTickLabel',[]); set(gca,'XTickLabel',[]);
% end logmsg('Flight detection is done \n');

%% This part is freezing detection
freezePeriodNr = 0;
firstHit = 1;
hitnr = 0;
target_frames = round(frameRange(freezeSmoother(1)+1:end-freezeSmoother(2)));
% meanMove = mean(vidDif(frameRange(logical(inNest(frameRange)))));
for i = target_frames
    smoothVidDif(i) = mean(vidDif(i-freezeSmoother(1):i+freezeSmoother(2)));
    if i > 1
        deriv2(i) = smoothVidDif(i)-smoothVidDif(i - 1);
    end
    %     logmsg('smoothVidDif is %i\n',smoothVidDif);
    
end

averageMovement = mean(smoothVidDif(target_frames));
minimalMovement = min(smoothVidDif(target_frames));

% vidlag = sum(freezeSmoother);%+3;  %three frames after the stim start for the
%stim to be visible in the picture

snapframe = []; sfr= []; nose = []; arse = []; stim = []; freezeTimes = [];
k = []; freeze_duration = [];

for i = target_frames
    %    logmsg(['First frame of freezing episode: '
    %    numstr((freezeSmoother(1)+1)]); logmsg(['List frame of freezing
    %    episode: ' numstr((freezeSmoother(1)+1)]);
    
    if smoothVidDif(i) < minimalMovement + difTreshold && deriv2(i) < deriv2Tresh...
            && deriv2(i) > -deriv2Tresh && smoothTrajectory(i,1) ~= 0;
        i;
        % && ~inNest(i) && smoothTrajectory(i,1) ~= 0;
        if firstHit
            startTime = i / frameRate;
            firstHit = 0;
            hitnr = 1;
            
            snapframe = read(vid, i);%+vidlag
            
            snapframe = uint8(double(snapframe).^gamma / (255^gamma) * 255);

            
            sfr = size(snapframe);
            
        else
            hitnr = hitnr + 1;
            %             logmsg('%d\n', hitnr);
        end
    else
        if hitnr/frameRate > freezeTreshold
            stopTime = (i-1) / frameRate;
            freezePeriodNr = freezePeriodNr + 1;
            freezeTimes(freezePeriodNr,1:2) = [startTime stopTime];
            freeze_duration(freezePeriodNr) = stopTime-startTime;
            startf = @(t1,t2) rem([t1,t2],60); st = startf(startTime, stimStart);
            
            %show the snapshot and get the coordinates
            if isempty(snapframe)==0;
%                 figHandles = findall(0,'Type','figure');
%                 fig_n = max(figHandles)+1;
                
                snapfig = figure;
                snapaxes = axes('parent', snapfig);
                image(snapframe, 'Parent', snapaxes); hold on;
                title(snapaxes,sprintf('Frame #%d,StartTime %g:%02.2f,StimStart %g:%02.2f',...
                    i, floor(startTime/60), st(1) ,floor(stimStart/60), st(2)));
                if  ~isempty(freezePeriodNr)
                    for k = freezePeriodNr
                        %get the positions of nose, arse and stim manually
                        p = 1; framesforward = 0;
                        message1 =sprintf('Click first on nose then on arse');
                        if k==1
                            logmsg(message1);
%                             uiwait(msgbox(message1));
                        else
                            logmsg(message1);
                        end
                        
                        [xn, yn] = ginput(2);
                        
                        nose(k, 1:2) = [xn(1), yn(1)];
                        arse(k, 1:2) = [xn(2), yn(2)];
%                         figure;
                        plot([nose(k,1),arse(k,1)],[nose(k,2),arse(k,2)], 'linewidth', 2); %head line
                        hold on;
                        
                        if startTime<ActStartTime || startTime>ActEndTime+0.2
                            message3 = sprintf('press "space" for manual input, OK to continue');
                            %                            if k==1
                            uiwait(msgbox(message3));
%                             logmsg(message3);
                            %                         else
                            %                             logmsg(message3);
                            %                         end
                            [ keyIsDown, ~, keyCode ] = KbCheck;
                            %                            WaitSecs(1); %for
                            %                            finding the
                            %                            keycode
                            m = find(keyCode);
                            if keyIsDown && m==32
                                
                                while p<2   % looking at frames and checking
                                    message4 = ('use left and right arrow keys or n');
                                    %                                     uiwait(msgbox(message3));
                                    logmsg(message4);
                                    [xs(p), ys(p), button] = ginput(1);
                                    switch button
                                        case 28 % left arrow
                                            framesforward = framesforward - 1;
                                            framenr = round(startTime*frameRate)...
                                                +framesforward;
                                            snapframe = read(vid,framenr);image...
                                                (snapframe, 'Parent', snapaxes);
                                            
                                        case 29 % right arrow
                                            framesforward = framesforward + 1;
                                            framenr = round(startTime*frameRate)...
                                                +framesforward;
                                            snapframe = read(vid,framenr );
                                            image(snapframe,'Parent', snapaxes);
                                        case 110
                                            logmessage('no stim visible')
                                            stim(k,:) = [NaN NaN];
                                            p = p + 1;
                                        otherwise
                                            p = p + 1;
                                            if p==2
                                                %                                                 if ~isempty(stim(k,:));
                                                message5 = ('Click on stim');
                                                logmsg(message5)
%                                                 uiwait(msgbox(message5));
                                                [xs(p), ys(p)] = ginput(1);
                                                stim(k,:) = [xs(p) ys(p)]; hold on;
%                                                 figure;
                                                plot([nose(k,1),stim(k,1)],[nose(k,2),stim(k,2)], 'linewidth', 2);%position line
                                                hold on;
                                                xsfr = 1:(sfr(1)+600);
                                                ysfr = stim(k,2)*ones(1,(sfr(1)+600));
                                                plot(xsfr, ysfr, '--', 'color',[.5 .5 .5]); %stim line
                                                %                                                 else
                                                %                                                  logmessage('no stim visible')
                                                %                                                 end
                                            end
                                    end
                                end
                                
                            else
                                stim(k, :) = [NaN NaN];
                            end
                        else
                            message2 = sprintf('Click on stimulus center or press ''n'' for absent stimulus');
                            logmsg(message2);
%                             uiwait(msgbox(message2));
                            [stim(k,1), stim(k,2), button] = ginput(1);
                            if eq(button,110)
                                while p<2   % looking at frames and checking
                                    message3 = ('use left and right arrow keys');
                                    %                                     uiwait(msgbox(message3));
                                    logmsg(message3);
                                    [xs(p), ys(p), button] = ginput(1);
                                    switch button
                                        case 110 % n
                                            logmsg('no stim visible')
                                            stim(k,:) = [NaN NaN];
                                            p = p + 1;
                                        case 28 % left arrow
                                            framesforward = framesforward - 1;
                                            framenr = round(startTime*frameRate)...
                                                +framesforward;
                                            snapframe = read(vid,framenr);
                                            image(snapframe, 'Parent', snapaxes);
                                            
                                        case 29 % right arrow
                                            framesforward = framesforward + 1;
                                            framenr = round(startTime*frameRate)...
                                                +framesforward;
                                            snapframe = read(vid,framenr );
                                            image(snapframe,'Parent', snapaxes);
                                            
                                        otherwise
                                            p = p + 1;
                                            if p==2
                                                message4 = ('Click on stim');
                                                logmsg(message4);
%                                                 uiwait(msgbox(message4));
                                                [xs(p), ys(p)] = ginput(1);
                                                stim(k,:) = [xs(p) ys(p)]; hold on;
                                                plot([nose(k,1),stim(k,1)],[nose(k,2),stim(k,2)], 'linewidth', 2);%position line
                                                hold on;
                                                xsfr = 1:(sfr(1)+600);
                                                ysfr = stim(k,2)*ones(1,(sfr(1)+600));
                                                plot(xsfr, ysfr, '--', 'color',[.5 .5 .5]); %stim line
                                            end
                                    end
                                end
                                
                            else
                                plot([nose(k,1),stim(k,1)],[nose(k,2),stim(k,2)], 'linewidth', 2);%position line
                                hold on;
                                xsfr = 1:(sfr(1)+600);
                                ysfr = stim(k,2)*ones(1,(sfr(1)+600));
                                plot(xsfr, ysfr, '--', 'color',[.5 .5 .5]); %stim line
                            end
                        end
                        k = k+1;
                        
                    end
                else
                    
                    logmsg('no freezing');
                    
                end
            else
                logmsg('no freezing frames captured');
            end
            
            snapframe = [];
        end
        firstHit = 1;
        hitnr = 0;
    end
    
end
if isempty(freezeTimes);
    logmsg('no freezing');
end

mouse_move = (smoothVidDif(target_frames));
move_2der = (deriv2(target_frames));
trajectory_length = length(target_frames);

logmsg('Freeze detection complete');


if makeVideo
    close(writerObj); %#ok<UNRCH>
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
end