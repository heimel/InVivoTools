function bg16 = wc_compute_background(record,vid,timeRange)
%WC_COMPUTE_BACKGROUND computes the non-changing background in a movie
% 
%  BG16 = WC_COMPUTE_BACKGROUND( RECORD, VID, TIMERANGE )
%
% 2019, Alexander Heimel


if nargin<2 || isempty(vid)
    [~,filename] = wc_getmovieinfo(record);
    sf = getstimsfile(record);
    stimduration = duration(sf.saveScript);

    if isempty(filename) || ~exist(filename,'file')
        logmsg(['Cannot find movie for ' recordfilter(record)]);
        return
    end
    vid = VideoReader(filename);
end

if nargin<3 || isempty(timeRange)
    if ~isempty(record.stimstartframe)
        frameRate = get(vid, 'FrameRate');
        stimStart = record.stimstartframe / frameRate;
    else
        stimStart = 0;
    end
    secBefore = 2; % s
    timeRange = [max(0,stimStart-secBefore) stimStart+stimduration];
end    

%logmsg('Computing background');
f = 1;
n_samples = 30;
bgtimeRange(1) = max(0,timeRange(1)-120); % add 2 minutes earlier
bgtimeRange(2) = min(vid.Duration,timeRange(2)+120); % add 2 minutes later
skip = diff(bgtimeRange)/n_samples;
Frame = readFrame(vid);
bg = zeros([size(Frame) n_samples ],class(Frame));
try
    vid.CurrentTime = bgtimeRange(1);
catch me
    logmsg([me.message ' in ' recordfilter(record)]);
    bg16 = [];
    return
end
    
    
while vid.CurrentTime<= (bgtimeRange(2)-skip) && hasFrame(vid)
    Frame = readFrame(vid);
    bg(:,:,:,f) = Frame;
    try
        vid.CurrentTime = vid.CurrentTime + skip; % jump 3s
    catch me
        logmsg(me.message);
        break
    end
    f = f+1;
end
bg = median(bg,4); % mode better?
bg16 = int16(bg);




