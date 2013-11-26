function [dr] = tpdriftcheck_fullframeshift(record, channel, searchx, searchy, refrecord, refsearchx, refsearchy, howoften, avgframes)

%  TPDRIFTCHECK - Checks two-photon data for drift
%
%    [DR,IM3] = TPDRIFTCHECK(DIRNAME,CHANNEL,SEARCHX, SEARCHY,
%       REFDIRNAME,REFSEARCHX, REFSEARCHY, ...
%	HOWOFTEN,AVGFRAMES, WRITEIT, PLOTIT)
%
%  Reports drift across a twophoton time-series record.  Drift is
%  calculated by computing the correlation for pixel shifts within
%  the search space specified.  SEARCHX and SEARCHY are vectors
%  containing offsets from 0 (no drift).  REFSEARCHX and
%  REFSEARCHY are the offsets to check during the initial
%  effort to find a match between frames acquired in different
%  directories.
%
%  DIRNAME is the directory in which to check for drift
%  relative to image IM0.  CHANNEL is the channel to be read.
%
%  The fraction of frames to be searched is specified in HOWOFTEN.  If
%  HOWOFTEN is 1, all frames are searched; if HOWOFTEN is 10, only one
%  of every 10 frames is searched.
%
%  AVGFRAMES specifies the number of frames to average together.
%
%  If WRITEIT is 1, then a 'driftcorrect.mat' file is written to the
%  directory, detailing shifted frames.
%
%  DR is a two-dimensional vector that contains the X and Y shifts for
%  each frame.
%
%  If PLOTIT is 1, the results are plotted in a new figure.
%


if isempty(refrecord)
    refrecord = record;
end

im0 = tppreview(refrecord,avgframes,1,channel);  % the first image
params = tpreadconfig(record);
n_timestamps=length(params.frame_timestamp);

dr = [];
drlast = [0 0];

refisdifferent = 0;
if refrecord==record, % this is reference data
    xrange = searchx; yrange = searchy;
else
    xrange = refsearchx; 
    yrange = refsearchy; 
    refisdifferent = 1;
end;

t = [];
hwaitbar = waitbar(0,'Checking frames...');
for f=1:howoften:(n_timestamps-avgframes)
    hwaitbar = waitbar(f/(n_timestamps-avgframes));
    %fprintf(['Checking frame ' int2str(f) ' of ' int2str(n_timestamps) '.\n']);
    t(end+1) = 1;
    im1 = zeros(params.lines_per_frame,params.pixels_per_line);
    for j=0:avgframes-1,
        im1(:,:,j+1)=tpreadframe(record,channel,f+j);
    end;
    im1 = mean(im1,3);
    dr(length(t),[1 2]) = driftcheck(im0,im1,drlast(1,1)+xrange,drlast(1,2)+yrange,1);
    if refisdifferent,
        % refine search of first frame
        dr(length(t),[1 2]) = driftcheck(im0,im1,dr(length(t),1)+searchx,dr(length(t),2)+searchy,1);
        refisdifferent = 0;
    end;
    drlast = dr(length(t),[1 2]);
    disp(['Shift is ' int2str(dr(end,:))]);
    disp(['Searching ' int2str(dr(end,1)+xrange) ' in x.']);
    disp(['Searching ' int2str(dr(end,2)+yrange) ' in y.']);
    xrange = searchx; yrange = searchy;
end;
close(hwaitbar);
