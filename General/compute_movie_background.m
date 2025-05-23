function bg16 = compute_movie_background(vid,time_range)
%COMPUTE_MOVIE_BACKGROUND computes the non-changing background in a movie
% 
%  BG16 = COMPUTE_MOVIE_BACKGROUND( VID, [TIMERANGE] )
%  BG16 = COMPUTE_MOVIE_BACKGROUND( FILENAME, [TIMERANGE] )
%
%  Computes the non-changing background in a movie as the median image.
%
%  VID is an open video object.
%  FILENAME is a video filename.
%  TIMERANGE is a 2x1 vector with start and end time to use
%
% 2025, Alexander Heimel, based on wc_compute_background

if ischar(vid)
    filename = vid;
    if ~exist(filename,'file')
        logmsg(['Cannot find movie for ' recordfilter(record)]);
        return
    end
    vid = VideoReader(filename);
end

if nargin<2 || isempty(time_range)
    time_range = [0 vid.Duration];
end    

logmsg('Computing background');

f = 1;
n_samples = 30;
bgtimeRange(1) = max(min(1,vid.Duration),time_range(1)-120); % add 2 minutes earlier, skip first second for autogain changes
bgtimeRange(2) = min(vid.Duration,time_range(2)+120); % add 2 minutes later
skip = diff(bgtimeRange)/(n_samples+1);
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

% cluster to get different mouse positions
bgflat = reshape(bg,[size(bg,1)*size(bg,2)*size(bg,3) size(bg,4)]);
km = kmeans(double(bgflat),5,'Start','uniform');
%km = kmeans(double(bgflat),5);
[km,bgs] = kmeans(double(bgflat'),5);
bgs = uint8(reshape(bgs,[size(bgs,1) size(bg,1) size(bg,2) size(bg,3)]));
bgs = shiftdim(bgs,1);
bg = bgs;

bg = median(bg,4); % mode better?
bg16 = int16(bg);




