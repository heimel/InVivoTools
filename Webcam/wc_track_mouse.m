function record = wc_track_mouse(record, stimstart, verbose)
%WC_TRACK_MOUSE tracks mouse in movie from record or filename
%
% 2019, Alexander Heimel

if nargin<3 || isempty(verbose)
    verbose = true;
end
if nargin<2
    stimstart = [];
end

params = wcprocessparams(record);

% parameters
makeVideo = false;
gamma = 0.3; % for showing image

difScope = 50; % The range around mouse that is included in pixelchange analysis %was 60
% nestRange = [80 60]; % x, y in pixels, range from nestcenter at which
% mouse is treated as in nest
difTreshold = 0.3; % threshold + minimum movement for difference between frames
% to be considered as no difference, fraction of average movement %was 0.3
deriv2Tresh = 0.08; % Treshold for 2nd derivative of vidDif %was 0.05

% defaults
if isempty(record)
    stimstart = 571.6-10;
    record = db(find_record(db,'mouse=172005.1.14,date=2018-11-19,epoch=t00002'));
end

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
    wcinfo = wc_getmovieinfo(record);
else
    [wcinfo,filename] = wc_getmovieinfo(record);
    sf = getstimsfile(record);
    stimduration = duration(sf.saveScript);
end

if isempty(filename) || ~exist(filename,'file')
    logmsg(['Cannot find movie for ' recordfilter(record)]);
    return
end

logmsg(['Analyzing ' filename]);
vid = VideoReader(filename);

framerate = get(vid, 'FrameRate');

Frame = readFrame(vid);
s = size(Frame);

if isempty(stimstart)
    stimstart = wc_getstimstart( record, framerate );
end

% Time range that needs to be analyzed
timeRange = [max(0,stimstart-params.wc_analyse_time_before_onset) ...
    stimstart + stimduration + params.wc_analyse_time_after_offset];

if verbose
    figRaw = figure('Name','Raw');
    if makeVideo
        writerObj = VideoWriter('mousetracking1.avi'); %#ok<UNRCH>
        writerObj.FrameRate = framerate;
        open(writerObj);
    end
else
    figRaw = [];
end

% Make a background by averageing frames in bgframes
% The background is complemented so black shapes become white and can be
% substracted from each other.
bg = double(wc_compute_background(record,vid,timeRange));

% The actual videoanalysis part
% Runs a for loop trough all frames that need to be analysed specified by
% frameRange. For every frame, the background is substracted. Then, the
% resulting image is tresholded to have the remainig shape which is assumed
% to be the mouse. From this, the position of the mouse is calculated.
% Around this position the mean pixelvalue change is calculated that is
% used later for freeze detection.

logmsg(['Detecting mouse starting from ' num2str(timeRange(1)) ' s.']);
vid.CurrentTime = timeRange(1);

n_frames = ceil((timeRange(2)-timeRange(1)) * framerate);
frametimes = NaN(n_frames,1);
stim = NaN(n_frames,2);
body = NaN(n_frames,2);
arse = NaN(n_frames,2);
nose = NaN(n_frames,2);
vidDif = NaN(n_frames,1); % for the difference per frame
Frame = [];
i = 1;

DisableKeysForKbCheck(231); % ignore for laptop Alexander

if isfield(record.measures,'arena') 
    screenrect = record.measures.arena;
else
    screenrect = [];
end

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
    
    [body(i,:),arse(i,:),nose(i,:),stim(i,:)] = ...
        get_mouse_position( Frame,bg,[],figRaw,screenrect);
    
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
        if makeVideo
            frame = getframe; %#ok<UNRCH>
            writeVideo(writerObj,frame);
        end
    end
    
    i = i + 1;
end

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

smoothVidDif = movmean(vidDif,2*params.wc_freeze_smoother);
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
        if hitnr/framerate > params.wc_freezeduration_threshold
            stopFreezeTime = frametimes(i-1);
            freezePeriodNr = freezePeriodNr + 1;
            freezeTimes(freezePeriodNr,1:2) = [startFreezeTime stopFreezeTime]; %#ok<AGROW>
            freeze_duration(freezePeriodNr) = stopFreezeTime-startFreezeTime; %#ok<AGROW>
            arse(freezePeriodNr,:) = record.measures.arse_trajectory(i,:); %#ok<AGROW>
            nose(freezePeriodNr,:) = record.measures.nose_trajectory(i,:); %#ok<AGROW>
            if isfield(record.measures,'stim_trajectory') && ~isempty(record.measures.stim_trajectory)
                stim(freezePeriodNr,:) = record.measures.stim_trajectory(i,:); %#ok<AGROW>
            else
                stim(freezePeriodNr,:) = [NaN NaN]; %#ok<AGROW>
            end
        end
        firstHit = true;
        hitnr = 0;
    end
end
% check if freezing was continuing
if hitnr/framerate > params.wc_freezeduration_threshold
    stopFreezeTime = frametimes(i-1);
    freezePeriodNr = freezePeriodNr + 1;
    freezeTimes(freezePeriodNr,1:2) = [startFreezeTime stopFreezeTime]; 
    freeze_duration(freezePeriodNr) = stopFreezeTime-startFreezeTime; 
    arse(freezePeriodNr,:) = record.measures.arse_trajectory(i,:); 
    nose(freezePeriodNr,:) = record.measures.nose_trajectory(i,:); 
    if isfield(record.measures,'stim_trajectory') && ~isempty(record.measures.stim_trajectory)
        stim(freezePeriodNr,:) = record.measures.stim_trajectory(i,:); 
    else
        stim(freezePeriodNr,:) = [NaN NaN]; 
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
record.measures.framerate = framerate;


