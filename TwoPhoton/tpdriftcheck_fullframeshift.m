function [dr,howoften,avgframes] = tpdriftcheck_fullframeshift(record, channel, refrecord, verbose)
%  TPDRIFTCHECK - Checks two-photon data for drift
%
%    DR = TPDRIFTCHECK(DIRNAME,CHANNEL,REFDIRNAME, HOWOFTEN, AVGFRAMES, VERBOSE)
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

if nargin<4 || isempty(verbose)
    verbose = true;
end
if nargin<3 || isempty(refrecord)
    refrecord = record;
end
if nargin<2 || isempty(channel)
    channel = 1;
end

params = tpreadconfig(record);
processparams = tpprocessparams(record);
howoften = processparams.drift_correction_howoften;
avgframes = processparams.drift_correction_avgframes;

im0 = tppreview(refrecord,avgframes,1+processparams.drift_correction_skip_firstframes,channel,[],[],verbose);  % the first image
n_timestamps = length(params.frame_timestamp);

dr = [];
drlast = [0 0];

refisdifferent = 0;
if refrecord==record % this is reference data
    xrange = processparams.drift_correction_searchx; 
    yrange = processparams.drift_correction_searchy;
else
    xrange = processparams.drift_correction_refsearchx; 
    yrange = processparams.drift_correction_refsearchy; 
    refisdifferent = 1;
    logmsg(['Searching range from ref ' int2str(processparams.drift_correction_refsearchx) ' for x.']);
    logmsg(['Searching range from ref ' int2str(processparams.drift_correction_refsearchy) ' for y.']);
end;

logmsg(['Searching range ' int2str(processparams.drift_correction_searchx) ' for x.']);
logmsg(['Searching range ' int2str(processparams.drift_correction_searchy) ' for y.']);

fov = [ 1+processparams.drift_field_of_view_margins(3) ...
    params.lines_per_frame - processparams.drift_field_of_view_margins(4) ...
    1+processparams.drift_field_of_view_margins(1) ...
    params.pixels_per_line - processparams.drift_field_of_view_margins(2) ]; % field of view to use for correction
    
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
    dr(length(t),[1 2]) = driftcheck(...
        im0(fov(1):fov(2),fov(3):fov(4),:),...
        im1(fov(1):fov(2),fov(3):fov(4),:),...
        drlast(1,1)+xrange,drlast(1,2)+yrange,1);
    if refisdifferent
        % refine search of first frame
        dr(length(t),[1 2]) = driftcheck(...
            im0(fov(1):fov(2),fov(3):fov(4),:),...
            im1(fov(1):fov(2),fov(3):fov(4),:),...
            dr(length(t),1)+processparams.drift_correction_searchx,...
            dr(length(t),2)+processparams.drift_correction_searchy,1);
        refisdifferent = 0;
    end
    drlast = dr(length(t),[1 2]);
    if verbose
        logmsg(['Frame ' num2str(f) ' shift is ' int2str(dr(end,:))]);
    end
    xrange = processparams.drift_correction_searchx; 
    yrange = processparams.drift_correction_searchy;
end
if verbose
    close(hwaitbar);
end