function params=tpreadconfig( records )
%TPREADCONFIG read twophoton experiment config file
%
% PARAMS. =
%  params.number_of_frames = total number of frames
%  params.lines_per_frame = lines per frame
%  params.pixels_per_line = number of pixels per line
%  params.frame_period = frame period, in s
%  params.frame_period__us = frame period, in us
%  params.scanline_period = scanline period in s
%  params.scanline_period__us = scanline period in us
%  params.dwell_time = pixel dwell time
%  params.dwell_time__us = pixel dwell time, in us
%  params.frame_timestamp = list of all frame timestamps
%  params.frame_timestamp__us = id, in us
%
% ImageJ version
%
% 2014, Alexander Heimel
%

for i = 1:length(records)
    param = tpreadconfig_single( records(i) );
    if isempty(param)
        params = [];
        return
    else
        params(i) = param;
    end
end

function params = tpreadconfig_single( record )
fname = tpfilename(record);

if ~exist(fname,'file')
    disp(['TPREADCONFIG: ' fname ' does not exist.']);
    params = [];
    return
end

inf = tiffinfo(fname,1, tpscratchfilename(record,[],'tiffinfo') );

params = inf; % a little lazy, perhaps better to only copy the necessary fields
% params.frame_timestamp = inf.frame_timestamp; % list of all frame timestamps in s
% params.frame_period = inf.frame_period;

params.lines_per_frame = inf.Height;
params.pixels_per_line = inf.Width;
params.number_of_frames = inf.NumberOfFrames;


if isfield(inf,'ParsedImageDescription') && isfield(inf.ParsedImageDescription,'SecondsPerScanLine')
    params.scanline_period = inf.ParsedImageDescription.SecondsPerScanLine; % scanline period in s
else
    warning('TPREADCONFIG:NO_SECONDSPERSCANLINE','No SecondsPerScanLine in multitiff image description. Choosing arbitrary scanline time');
    warning('OFF','TPREADCONFIG:NO_SECONDSPERSCANLINE');
    params.scanline_period = 0.002; % scanline period in s
end
params.scanline_period__us = params.scanline_period *1e6; %scanline period in us

params.dwell_time = params.scanline_period / params.pixels_per_line; % pixel dwell time in us
params.dwell_time__us =  params.dwell_time*1e6;

if ~isfield( inf, 'frame_period')
    params.frame_period = 1; % arbitrarily set to 1
end
params.frame_period__us = params.frame_period * 1e6; % frame period in us

if ~isfield( inf, 'frame_timestamp')
    params.frame_timestamp = (0:(inf.NumberOfFrames-1))*params.frame_period;
end
params.frame_timestamp__us = params.frame_timestamp * 1E6; % list of all frame timestamps in s
