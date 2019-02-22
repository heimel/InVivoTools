function record = wc_track_mouse(record, stimStart, verbose)
%WC_TRACK_MOUSE tracks mouse in movie from record or filename
%
% 2019, Alexander Heimel

if nargin<3 || isempty(verbose)
    verbose = true;
end

% parameters
secBefore = 2; % s
makeVideo = false;
step = false;
gamma = 0.3; % for showing image


difScope = 50; % The range around mouse that is included in pixelchange analysis %was 60
% nestRange = [80 60]; % x, y in pixels, range from nestcenter at which
% mouse ist reated as in nest
freezeSmoother = [5,5]; % Amount of frames that freeze analysis is averaging
% over before and after current frame
difTreshold = 0.3; % treshold + minimum movement for difference between frames
% to be considered as no difference, fraction of average movement %was 0.3
freezeTreshold = 0.5; % in seconds, treshold for %was 1
deriv2Tresh = 0.08; % Treshold for 2nd derivative of vidDif %was 0.05

if nargin<2
    stimStart = [];
end

% defaults
%stimStart = 9*60 + 28 +3;
if isempty(record)
    stimStart = 571.6-10;
    %stimStart = 564.5+10;
    record = '\\vs01\MVP\Shared\InVivo\Experiments\172005\172005.1.16\2018-12-04\tinyhat\t00018\..\webcam_picam01_2018-12-04_15_14_15.h264.mp4';
    %    record = db(find_record(db,'mouse=172005.1.16,date=2018-12-04,epoch=t00018'))
    %    record = db(find_record(db,'mouse=172005.1.16,date=2018-12-04,epoch=t00004'))
    record = db(find_record(db,'mouse=172005.1.14,date=2018-11-19,epoch=t00002'));
    
end

%
% if ~exist('db','var') || isempty(db)
%     experiment('17.20.02')
%     host('tinyhat')
%     db = load_testdb('wc');
%     record = db(15535);
% end

if ~exist('record','var') || isempty(record)
    p = pwd;
    cd('\\vs01\MVP\Shared\InVivo\Experiments');
    [filename,pathname] = uigetfile('*.*');
    record = fullfile(pathname,filename);
    cd(p);
end

if ~isstruct(record)
    filename = record;
    record = [];
    record.mouse = '';
    record.stimstartframe = [];
    stimduration = 3;
else
    [~,filename] = wc_getmovieinfo(record);
    sf = getstimsfile(record);
    stimduration = duration(sf.saveScript);
end

secAfter = stimduration ; % two seconds after stimulus


if isempty(filename) || ~exist(filename,'file')
    logmsg(['Cannot find movie for ' recordfilter(record)]);
    return
end

logmsg(['Analyzing ' filename]);
vid = VideoReader(filename);

frameRate = get(vid, 'FrameRate');

Frame = readFrame(vid);
s = size(Frame);


if isempty(stimStart)
    if ~isempty(record.stimstartframe)
        stimStart = record.stimstartframe / frameRate;
    else
        stimStart = 0;
    end
end

% what about the line below. Is this in record.stimstarframe already
%starttime = (wcinfo(1).stimstart-par.wc_playbackpretime) * par.wc_timemultiplier + par.wc_timeshift;


% Time range that needs to be analyzed
timeRange = [max(0,stimStart-secBefore) stimStart+secAfter];

if verbose
    figRaw = figure('Name','Raw');
    logmsg('Press + or - to change gamma');
else
    figRaw = [];
end

% To record video
if makeVideo
    writerObj = VideoWriter('mousetracking1.avi'); %#ok<UNRCH>
    writerObj.FrameRate = frameRate;
    open(writerObj);
end

% Make a background by averageing frames in bgframes
% The background is complemented so black shapes become white and can be
% substracted from each other.
logmsg('Computing background');
f = 1;
n_samples = 50;
bgtimeRange(1) = max(0,timeRange(1)-120); % extend by 2 minute
bgtimeRange(2) = min(vid.Duration,timeRange(2)+120); % add 2 minute
skip = diff(bgtimeRange)/n_samples;
bg = zeros([size(Frame) n_samples ],class(Frame));
vid.CurrentTime = bgtimeRange(1);
while vid.CurrentTime<= (bgtimeRange(2)-skip) && hasFrame(vid)
    Frame = readFrame(vid);
    bg(:,:,:,f) = Frame;
    vid.CurrentTime = vid.CurrentTime + skip; % jump 3s
    f = f+1;
end
bg = median(bg,4); % mode better?
bg16 = int16(bg);

% The actual videoanalysis part
% Runs a for loop trough all frames that need to be analysed specified by
% frameRange. For every frame, the background is substracted. Then, the
% resulting image is tresholded to have the remainig shape which is assumed
% to be the mouse. From this, the position of the mouse is calculated.
% Around this position the mean pixelvalue change is calculated that is
% used later for freeze detection.

logmsg('Detecting mouse');
vid.CurrentTime = timeRange(1);

n_frames = ceil((timeRange(2)-timeRange(1)) * frameRate);
frametimes = NaN(n_frames,1);
stim = NaN(n_frames,2);
body = NaN(n_frames,2);
arse = NaN(n_frames,2);
nose = NaN(n_frames,2);
vidDif = NaN(n_frames,1); % for the difference per frame
Frame = [];
i = 1;

DisableKeysForKbCheck(231); % ignore for laptop Alexander

while vid.CurrentTime < timeRange(2) && hasFrame(vid)
    frametimes(i) = vid.CurrentTime;
    oldframe = Frame;
    Frame = readFrame(vid);
    
    if verbose
        figure(figRaw);
        gFrame = uint8(double(Frame).^gamma / (255^gamma) * 255);
        hImage = image(gFrame); %#ok<NASGU>
        axis image off
        hold on
    end
    
    %     bg16(bg16==0) = NaN;
    %     Frame = double(Frame);
    %     Frame = imgaussfilt(Frame,3);
    %     bg16 = double(bg16);
    %     bg16 = imgaussfilt(bg16,3);
    %     frame_bg_subtracted = bg16 - Frame;
    %
    frame_bg_subtracted = bg16 - int16(Frame);
    
    frame_bg_subtracted = abs(frame_bg_subtracted);
    
    frame_bg_subtracted = double(frame_bg_subtracted);
    frame_bg_subtracted = frame_bg_subtracted ./ (double(bg16) + 40);
    
    if isfield(record.measures,'arena')
        screenrect = record.measures.arena;
    else
        screenrect = [];
    end
    
    [body(i,:),arse(i,:),nose(i,:),stim(i,:)] = ...
        get_mouse_position( frame_bg_subtracted,[],figRaw,screenrect);
    
    % This part defines the scope in which the difference between last
    % frame is calculated
    if any(isnan(body(i,:))) || i==1
        vidDif(i) = 0;
    else
        frameDif = abs(Frame - oldframe);
        difScopex1 = max(1,round(body(i,1) - difScope));
        difScopex2 = min(s(2),round(body(i,1)+ difScope));
        difScopey1 = max(1,round(body(i,2) - difScope));
        difScopey2 = min(s(1),round(body(i,2)+ difScope));
        frameDifMouse = frameDif(difScopey1:difScopey2,difScopex1:difScopex2,:);
        vidDif(i) = mean(frameDifMouse(:));
    end
    % Show the frame and already set the difscope square and dot for
    % position of mouse
    if verbose
        text(s(2)-70,s(1)-20,[num2str(vid.CurrentTime,'%0.2f') ' s'],'Color','white','horizontalalignment','right');
        drawnow
    end
    
    if makeVideo
        frame = getframe; %#ok<UNRCH>
        writeVideo(writerObj,frame);
    end
    
    
    % detect keys
    [ keyIsDown, ~, keyCode ] = KbCheck;
    if keyIsDown
        disp(['Pressed: ' num2str(find(keyCode))]);
        if keyCode(160)
            if gamma>0.1
                gamma = gamma - 0.1;
                logmsg(['Gamma = ' num2str(gamma)]);
            end
        end
        if keyCode(189)
            gamma = gamma + 0.1;
            logmsg(['Gamma = ' num2str(gamma)]);
        end
        if keyCode(32)
            step = not(step);
        end
    end
    
    if step
        pause
    end
    i = i + 1;
end
logmsg('Video analysis is done');

record.measures.frametimes = frametimes;
record.measures.body_trajectory = body;
record.measures.arse_trajectory = arse;
record.measures.nose_trajectory = nose;
record.measures.stim_trajectory_raw = stim;

record = wc_cleanup_stimulus_trajectory(record,verbose);


% Freezing detection
freezePeriodNr = 0;
firstHit = 1;
hitnr = 0;

smoothVidDif = movmean(vidDif,2*freezeSmoother);
deriv2 = diff(smoothVidDif);
minimalMovement = min(smoothVidDif);
nomotion = smoothVidDif(1:end-1) < (minimalMovement + difTreshold) & abs(deriv2) < deriv2Tresh;

freezeTimes = [];
freeze_duration = [];
arse = [];
nose = [];
stim = [];
for i = 1:length(nomotion)
    if nomotion(i)
        if firstHit
            startFreezeTime = frametimes(i);
            firstHit = false;
            hitnr = 1;
        else
            hitnr = hitnr + 1;
        end
    else % motion again
        if hitnr/frameRate > freezeTreshold
            stopFreezeTime = frametimes(i-1);
            freezePeriodNr = freezePeriodNr + 1;
            freezeTimes(freezePeriodNr,1:2) = [startFreezeTime stopFreezeTime]; %#ok<AGROW>
            freeze_duration(freezePeriodNr) = stopFreezeTime-startFreezeTime; %#ok<AGROW>
            arse(freezePeriodNr,:) = record.measures.arse_trajectory(i,:);
            nose(freezePeriodNr,:) = record.measures.nose_trajectory(i,:);
            if isfield(record.measures,'stim_trajectory') && ~isempty(record.measures.stim_trajectory)
                stim(freezePeriodNr,:) = record.measures.stim_trajectory(i,:);
            else
                stim(freezePeriodNr,:) = [NaN NaN];
            end
        end
        firstHit = true;
        hitnr = 0;
    end
end
if isempty(freezeTimes)
    logmsg('No freezing detected');
end
logmsg('Freeze detection complete');

if makeVideo
    close(writerObj); %#ok<UNRCH>
end

record.measures.freezetimes_aut = freezeTimes;
record.measures.freeze_duration_aut = freeze_duration;
record.measures.arse_aut = arse;
record.measures.nose_aut = nose;
record.measures.stim_aut = stim;
record.measures.mousemove_aut = smoothVidDif;



