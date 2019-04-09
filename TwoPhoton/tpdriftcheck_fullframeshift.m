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
% 2019, Laila Bl?mer

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

skipframes = processparams.drift_correction_skip_firstframes;
xmarge = [processparams.drift_correction_searchx(1) processparams.drift_correction_searchx(end)];
ymarge = [processparams.drift_correction_searchy(1) processparams.drift_correction_searchx(end)];

% make sure xmarge and ymarge are positive
if ~isempty(xmarge(xmarge<0))
    xmarge(xmarge<0) = xmarge(xmarge<0) * -1;
end
if ~isempty(ymarge(ymarge<0))
    ymarge(ymarge<0) = ymarge(ymarge<0) * -1;
end

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

writevideo = false;

if writevideo
    % initiate video file for drift corrected frames
    driftvideofilename = tpscratchfilename(record,[],'driftcorrected.avi');
    driftvideo = VideoWriter(driftvideofilename);
    open(driftvideo);
    
    % initiate video for uncorrected frames
    videofilename = tpscratchfilename(record,[],'driftUNcorrected.avi');
    experimentvideo = VideoWriter(videofilename);
    open(experimentvideo);
    
    logmsg(['Writing drift corrected frames as video ' driftvideofilename]);
    logmsg(['Writing uncorrected frames as video ' videofilename]);
end


% for f=1:howoften:(n_timestamps-avgframes)
for f=1:howoften:500
    if verbose
        hwaitbar = waitbar(f/(n_timestamps-avgframes));
    end
    t(end+1) = 1;
    im1 = zeros(params.lines_per_frame,params.pixels_per_line);
    for j=0:avgframes-1 % averaging frames
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
    if verbose && ~mod(f-1,howoften*100)
        logmsg(['Frame ' num2str(f) ' shift is ' int2str(dr(end,:))]);
    end
    xrange = processparams.drift_correction_searchx;
    yrange = processparams.drift_correction_searchy;
    
    
    
    %% shift frame based on drlast
    if writevideo  % write drift video file
        if f >= skipframes
            im2 = tpreadframe(record,channel,f);
            
            if length(size(im2))==3 % i.e. rgb
                im2 = nanmean(im2,3);
            else
                im2 = im2uint8(im2);
            end
            
            im_cor = uint8(ones(size(im2,1)+2*sum(xmarge),size(im2,2)+2*sum(ymarge)));
            im_uncor = uint8(ones(size(im2,1)+2*sum(xmarge),size(im2,2)+2*sum(ymarge)));
            for i = 1:size(im2,1)
                for j = 1:size(im2,2)
                    im_cor(i+2*xmarge(1)+drlast(1),j+2*ymarge(1)+drlast(2)) = im2(i,j);
                    im_uncor(i+2*xmarge(1),j+2*ymarge(1)) = im2(i,j);
                end
            end
            im3 = im_cor;
            im4 = im_uncor;          
            imstack(:,:,f) = im4;
            
            if ~isempty(dr)
                writeVideo(driftvideo, im3);
            end
            
            writeVideo(experimentvideo, im4);
        end
    end
end

if writevideo
    close(driftvideo);
    close(experimentvideo);
    logmsg(['Drift corrected video saved as ' driftvideofilename]);
    logmsg(['Uncorrected frames to video saved as ' videofilename]);
end

if verbose
    close(hwaitbar);
end