function dr = tpdriftcheck_fullframeshift(record, channel, searchx, searchy, refrecord, refsearchx, refsearchy, howoften, avgframes, verbose)
%  TPDRIFTCHECK - Checks two-photon data for drift
%
%    DR = TPDRIFTCHECK(DIRNAME,CHANNEL,SEARCHX, SEARCHY,
%       REFDIRNAME,REFSEARCHX, REFSEARCHY, HOWOFTEN, AVGFRAMES, VERBOSE)
%
%  Reports drift across a twophoton time-series record.  Drift is
%  calculated by computing the correlation for pixel shifts within
%  the search space specified.  SEARCHX and SEARCHY are vectors
%  containing offsets from 0 (no drift).  REFSEARCHX and
%  REFSEARCHY are the offsets to check during the initial
%  effort to find a match between frames acquired in different
%  directories.
%  
%  CHANNEL is the channel to be read.
%
%  The fraction of frames to be searched is specified in HOWOFTEN.  If
%  HOWOFTEN is 1, all frames are searched; if HOWOFTEN is 10, only one
%  of every 10 frames is searched.
%
%  AVGFRAMES specifies the number of frames to average together.
%
%  DR is a two-dimensional vector that contains the X and Y shifts for
%  each frame.
%
% 200X, Steve Van Hooser
% 200X-2017, Alexander Heimel

if nargin<10 || isempty(verbose)
    verbose = true;
end
if nargin<9 || isempty(avgframes)
    avgframes = 5;
end
if nargin<8 || isempty(howoften)
    howoften = 10;
end
if isempty(channel)
    channel = 1;
end
if isempty(refrecord)
    refrecord = record;
end

im0 = tppreview(refrecord,avgframes,1,channel,[],[],verbose);  % the first image
params = tpreadconfig(record);
n_timestamps = length(params.frame_timestamp);

dr = [];
drlast = [0 0];

refisdifferent = 0;
if refrecord==record % this is reference data
    xrange = searchx; 
    yrange = searchy;
else
    xrange = refsearchx; 
    yrange = refsearchy; 
    refisdifferent = 1;
    logmsg(['Searching range from ref ' int2str(refsearchx) ' for x.']);
    logmsg(['Searching range from ref ' int2str(refsearchy) ' for y.']);
end;

logmsg(['Searching range ' int2str(searchx) ' for x.']);
logmsg(['Searching range ' int2str(searchy) ' for y.']);

t = [];
if verbose
    hwaitbar = waitbar(0,'Checking frames...');
end
for f=1:howoften:(n_timestamps-avgframes)
    if verbose
        hwaitbar = waitbar(f/(n_timestamps-avgframes));
    end
    t(end+1) = 1;
    im1 = zeros(params.lines_per_frame,params.pixels_per_line);
    for j=0:avgframes-1
        im1(:,:,j+1) = tpreadframe(record,channel,f+j);
    end
    im1 = mean(im1,3);
    dr(length(t),[1 2]) = driftcheck(im0,im1,drlast(1,1)+xrange,drlast(1,2)+yrange,1);
    if refisdifferent
        % refine search of first frame
        dr(length(t),[1 2]) = driftcheck(im0,im1,dr(length(t),1)+searchx,dr(length(t),2)+searchy,1);
        refisdifferent = 0;
    end
    drlast = dr(length(t),[1 2]);
    if verbose
        logmsg(['Frame ' num2str(f) ' shift is ' int2str(dr(end,:))]);
    end
    xrange = searchx; 
    yrange = searchy;
end
if verbose
    close(hwaitbar);
end