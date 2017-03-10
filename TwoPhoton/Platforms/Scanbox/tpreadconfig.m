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
% Scanbox version
%
% 2017, Alexander Heimel
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
persistent per_record per_params

if ~isempty(per_record)
    strip_record = rmfields(record,{'ROIs','measures'});
    if strip_record==per_record
        params = per_params;
        return
    end
end


fname = tpfilename(record);
mfname = [fname(1:end-4) '.mat'];

if ~exist(mfname,'file')
    logmsg([fname ' does not exist.']);
    params = [];
    per_params = params;
    per_record = rmfields(record,{'ROIs','measures'});
    return
end

load(mfname);

%inf = tiffinfo(fname,1, tpscratchfilename(record,[],'tiffinfo') );

%params = inf; % a little lazy, perhaps better to only copy the necessary fields
% params.frame_timestamp = inf.frame_timestamp; % list of all frame timestamps in s
% params.frame_period = inf.frame_period;

recordsPerBuffer = info.recordsPerBuffer;
if(info.scanmode==0)
    recordsPerBuffer = info.recordsPerBuffer*2;
end

switch info.channels
    case 1
        info.nchan = 2;      % both PMT0 & 1
        factor = 1;
    case 2
        info.nchan = 1;      % PMT 0
        factor = 2;
    case 3
        info.nchan = 1;      % PMT 1
        factor = 2;
end
params.NumberOfChannels = info.nchan;

info.nsamples = (info.sz(2) * recordsPerBuffer * 2 * info.nchan);
d = dir(fname);

params.BitsPerSample = 16;
%x = sbxread(fname,1,2)

params.lines_per_frame = info.sz(1);
params.Height = params.lines_per_frame;
params.pixels_per_line = info.sz(2);
params.Width = params.pixels_per_line;
params.number_of_frames = d.bytes / info.nsamples;
params.NumberOfFrames = params.number_of_frames;

params.scanline_period = 0.002; % scanline period in s
params.scanline_period__us = params.scanline_period *1e6; %scanline period in us

params.dwell_time = params.scanline_period / params.pixels_per_line; % pixel dwell time in us
params.dwell_time__us =  params.dwell_time*1e6;

frame_rate = info.resfreq/params.lines_per_frame*(2-info.scanmode); %% use actual resonant freq...


params.frame_period = 1/frame_rate; % s
params.frame_period__us = params.frame_period * 1e6; % frame period in us

logmsg('Still need to set frame timestamps correctly using info.frame(1) and info.line(1)')

params.frame_timestamp = ((0:(params.number_of_frames-1)) - info.frame(1) ) *params.frame_period ;
%params.frame_timestamp = ((0:(params.number_of_frames-1)) ) *params.frame_period;
params.frame_timestamp__us = params.frame_timestamp * 1E6; % list of all frame timestamps in s

params.third_axis_name = 't'; % to treat is as a movie
per_params = params;
per_record = rmfields(record,{'ROIs','measures'});

