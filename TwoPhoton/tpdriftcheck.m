function method = tpdriftcheck(record, channel, refrecord,  method, recompute, verbose)
%TPDRIFTCHECK - Checks two-photon data for drift
%
%    TPDRIFTCHECK(RECORD, CHANNEL, REFRECORD, METHOD, RECOMPUTE=FALSE, VERBOSE=TRUE)
%
%  Reports drift across a twophoton time-series record.  Drift is
%  calculated by computing the correlation for pixel shifts within
%  the search space specified.
%
%  RECORD is a record describing the data, see HELP TP_ORGANIZATION
%  relative to data at the beginning of REFRECORD
%  CHANNEL is the channel to be read.
%
%  A 'driftcorrect.mat' file is written to the directory, detailing shifted frames.
%
% This wrapper around drift or motion correction algorithms
%
% 200X, Steve Van Hooser
% 200X-2017, Alexander Heimel

if nargin<6 || isempty(verbose)
    verbose = true;
end
if nargin<5 || isempty(recompute)
    recompute = false;
end
if nargin<4 || isempty(method)
    method = 'fullframeshift';
end
if nargin<3
    refrecord = [];
end
if nargin<2
    channel = [];
end

switch method
    case '?'
        % return possible methods
        method = {'fullframeshift','greenberg'};
        return
end

logmsg(['Drift correcting by ' method ' ' recordfilter(record)]);
driftfilename = tpscratchfilename( record, [], 'drift');

if ~recompute && exist(driftfilename,'file')
    logmsg(['Not recomputing driftfile ' driftfilename ]);
    return
end

howoften = 10;
avgframes = 5; % only implemented for tpdriftcheck_steve

params = tpreadconfig(record);
total_n_frames = params.number_of_frames;

switch method
    case 'fullframeshift'
        searchx = -6:2:6;
        searchy = -6:2:6;
        refsearchx = -100:10:100;
        refsearchy = -100:10:100;
        dr = tpdriftcheck_fullframeshift(record, channel, searchx, searchy, ...
            refrecord, refsearchx, refsearchy, howoften, avgframes, verbose);
    case 'greenberg'
        analysed_n_frames = fix( (total_n_frames-1)/howoften+1);
        data = zeros(params.lines_per_frame,params.pixels_per_line,analysed_n_frames,'uint8');
        cfr = 1;
        for fr = 1:howoften:total_n_frames
            data(:,:,cfr) = tpreadframe(record,channel,fr);
            cfr = cfr+1;
        end
        base_image = mean(data,3);
        
        [~,~, ~,~,~,xpixelposition,ypixelposition] ...
            = tpdriftcheck_greenberg(data,base_image);
end
logmsg(['Computed drift correction for ' recordfilter(record)]);

% interpolate values
newframeind = 1:total_n_frames;
frameind = 1:howoften:total_n_frames-avgframes;
switch method
    case 'fullframeshift'
        drift.x = round(interp1(frameind,dr(:,1),newframeind,'linear','extrap')');
        drift.y = round(interp1(frameind,dr(:,2),newframeind,'linear','extrap')'); %#ok<STRNU>
    case 'greenberg'
        drift.xpixelpos = interp1(frameind,shiftdim(xpixelposition(:,:,:),2),newframeind,'linear','extrap');
        drift.ypixelpos = interp1(frameind,shiftdim(ypixelposition(:,:,:),2),newframeind,'linear','extrap');
        % image mean drifts:
        drift.x = round(mean(mean(drift.xpixelpos,3),2)-(params.pixels_per_line+1)/2);
        drift.y = round(mean(mean(drift.ypixelpos,3),2)-(params.lines_per_frame+1)/2);
end
save(driftfilename,'method','drift','-mat');


