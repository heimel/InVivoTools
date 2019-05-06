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
    logmsg([mfname ' does not exist.']);
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

params.slices = length(info.otwave);
if ~isempty(record.slice)
    if ischar(record.slice)
        params.slice = str2double(record.slice);
    else
        params.slice = record.slice;
    end
elseif isfield(info,'Section')
    params.slice = info.Section;
end

if params.slices>1 && ~isfield(params,'slice')
    logmsg([ num2str(params.slices) ' slices present in file. Loading all. Specify in slice field']);
end

params.lines_per_frame = info.sz(1);
params.Height = params.lines_per_frame;
params.pixels_per_line = info.sz(2);
params.Width = params.pixels_per_line;
params.number_of_frames = d.bytes / info.nsamples;
if isfield(params,'slice') && ~isfield(info,'Section')
    params.number_of_frames = floor(params.number_of_frames/params.slices);
end
params.NumberOfFrames = params.number_of_frames;

frame_rate = info.resfreq/params.lines_per_frame*(2-info.scanmode); %% use actual resonant freq...
params.frame_period = 1/frame_rate; % s
logmsg(['Computed from resonance frame period = ' num2str(params.frame_period)]);

params.scanline_period = params.frame_period / params.lines_per_frame; % scanline period in s
params.scanline_period__us = params.scanline_period *1e6; %scanline period in us

params.dwell_time = params.scanline_period / params.pixels_per_line; % pixel dwell time in us
params.dwell_time__us =  params.dwell_time*1e6;

stims = getstimsfile(record);
if ~isempty(stims) && isfield(info,'frame')
    time_between_triggers = (stims.MTI2{end}.startStopTimes(1)-stims.MTI2{1}.startStopTimes(1));
    frames_between_triggers =  info.frame(end)-info.frame(2) +...
        (info.line(end)-info.line(1))/params.lines_per_frame;
    params.frame_period = time_between_triggers/frames_between_triggers;
else
    logmsg('Could not find stimulus file. Frame period may be wrong');
end

params.frame_period__us = params.frame_period * 1e6; % frame period in us

logmsg(['Computed from stim file frame period = ' num2str(params.frame_period)]);

if isfield(info,'frame')
    if ~isempty(stims)
        params.frame_timestamp = ...
            ((0:(params.number_of_frames-1)) - info.frame(1) ) *params.frame_period ...
            -info.line(1)/params.lines_per_frame*params.frame_period;
    else
        params.frame_timestamp = ((0:(params.number_of_frames-1)) - info.frame(1) ) *params.frame_period ;
    end
else
    params.frame_timestamp = ((0:(params.number_of_frames-1))  ) *params.frame_period ;
    logmsg('Do not have trigger frames. Frame timestamps start at 0s');
end

if isfield(params,'slice')
    params.frame_timestamp = params.frame_timestamp(1)  + ...
        (params.frame_timestamp-params.frame_timestamp(1))* params.slices  + ...
        (params.slice-1)*params.frame_period;
    
    if isfield(info,'Section') % result from sbxsplit
        params.frame_timestamp = params.frame_timestamp + ...
            (params.slices)*params.frame_period ; % first frame of each slice thrown out
    end
end

params.frame_timestamp__us = params.frame_timestamp * 1E6; % list of all frame timestamps in s

params.third_axis_name = 't'; % to treat is as a movie
per_params = params;
per_record = rmfields(record,{'ROIs','measures'});

