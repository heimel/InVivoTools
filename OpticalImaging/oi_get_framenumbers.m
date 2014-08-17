function [response_framenumbers,baseline_framenumbers] = oi_get_framenumbers(record)
%OI_GET_FRAMENUMBERS
%
%  [response_framenumbers,baseline_framenumbers] = oi_get_framenumbers(record)
%
% 2014, Alexander Heimel
%
params = oiprocessparams(record);

filenames = fullfilelist(oidatapath(record),convert_cst2cell(record.test));
d = dir([filenames{1} '*BLK']);
if isempty(d)
    baseline_framenumbers = [];
    response_framenumbers = [];
    errormsg(['Cannot find files for record ' recordfilter(record)]);
    return
end
fileinfo = imagefile_info(fullfile(oidatapath(record),d(1).name));

baseline_framenumbers =...
    (1: floor((record.stim_onset+ params.extra_baseline_time)/fileinfo.frameduration)  );

if isempty(baseline_framenumbers)
    baseline_framenumbers = 1;
end

if ~isempty(record.stim_offset)
    response_framenumbers = setdiff( (1:ceil( (record.stim_offset+params.extra_time_after_offset) /fileinfo.frameduration)),baseline_framenumbers);
else
    response_framenumbers = setdiff( (1:size(ratio,1)),baseline_framenumbers);
end

response_framenumbers = response_framenumbers(response_framenumbers<=fileinfo.n_images);
