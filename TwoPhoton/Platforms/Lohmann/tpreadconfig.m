function params=tpreadconfig( records )
%TPREADCONFIG read twophoton experiment config file
%
%  PARAMS = TPREADCONFIG( RECORDS )
%
%    check HELP TP_ORGANIZATION for RECORD structure
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
% lohmann version
%
% 2009, Alexander Heimel
%

for i = 1:length(records)
    try
        params(i) = tpreadconfig_single( records(i) );
    catch ME
        disp(['TPREADCONFIG: ' ME.identifier]);
        params = [];
    end
end

function params = tpreadconfig_single( record )


fname  =tpfilename(record);
if ~exist(fname,'file')
    errordlg([fname ' does not exist.']);
    params = [];
   return
end

inf = tiffinfo(fname,1, tpscratchfilename(record,[],'tiffinfo') );
    
params = inf;
params.number_of_frames = inf.NumberOfFrames;
params.lines_per_frame = inf.Height;
params.pixels_per_line = inf.Width;

disp('LOHMANN/TPREADCONFIG: Hard coding XYT sequence');
params.third_axis_name = 't';


if isfield(inf,'ParsedImageDescription') && isfield(inf.ParsedImageDescription,'SecondsPerScanLine')
    params.scanline_period = inf.ParsedImageDescription.SecondsPerScanLine; % scanline period in s
    params.frame_period = params.Main.Lines_per_frame * params.scanline_period; % frame period in s
elseif isfield(record,'frame_period')
    params.frame_period = record.frame_period;
    params.scanline_period = params.frame_period / params.lines_per_frame; % scanline period
elseif ~isempty(record.stepsize)
    params.frame_period = record.stepsize;
    params.scanline_period = params.frame_period / params.lines_per_frame; % scanline period
else    
    warning('Could not find frame period. Using default value of 1s. This is unlikely to be correct. Set in step size field');
    params.frame_period = 1; % 1Hz, easy to read framenumber from time
    params.scanline_period = params.frame_period / params.lines_per_frame; % scanline period
end

params.scanline_period__us= params.scanline_period *1e6; %scanline period in us
params.frame_period__us = params.frame_period * 1e6; % frame period in us

params.dwell_time = params.scanline_period / params.pixels_per_line; % pixel dwell time in us
params.dwell_time__us =  params.dwell_time*1e6;

params.frame_timestamp = (0:params.number_of_frames-1)*params.frame_period; % list of all frame timestamps in s
params.frame_timestamp__us   = params.frame_timestamp * 1E6;

