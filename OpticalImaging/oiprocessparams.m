function params = oiprocessparams(record)
%OIPROCESSPARAMS contains experiment dependent process parameters
%
%  Local changes to settings should be made in processparams_local.m
%  This should be an edited copy of processparams_local_org.m
%
% 2013-2014, Alexander Heimel
%

if nargin<1
    record = [];
end
if isempty(record)
    record.mouse = '';
    record.datatype = 'oi';
    record.stim_type = 'rt_response';
end

if length(record.mouse)>5
    experiment = record.mouse(1:5);
else 
    experiment = '';
end

params.wta_equalize_area = false; % default
switch experiment
    case '12.54'
        params.wta_equalize_area = false;
    case '11.12'
        params.wta_equalize_area = true;
    case '13.61'
          params.wta_equalize_area = false;
    case '13.62'
        params.wta_equalize_area = true;
    otherwise
        if isfield(record,'stim_type')
            switch record.stim_type
                case 'orientation'
                    params.wta_equalize_area = false;
            end
        end
end


params.spatial_filter_width = 3; % pixels
switch experiment
    case '11.12'
        params.spatial_filter_width = 3; % pixels use nan to turn off filter
    case '13.61'
        params.spatial_filter_width = 3; % pixels use nan to turn off filter
end

params.single_condition_clipping = 5;
params.single_condition_differential = false;
params.single_condition_normalize_response = false;
switch record.stim_type
    case {'orientation','direction'}
        params.single_condition_clipping = 10;
        params.single_condition_differential = true;
        params.single_condition_normalize_response = true;
end
switch experiment
    case '13.61'
        params.single_condition_clipping = 40;
end
params.single_condition_show_roi = true;
params.single_condition_show_ror = true;




switch record.datatype
    case 'oi'
        params.extra_baseline_time = 0.6; % extra frames to use for baseline
        % using one, because in first 600 ms after stimulus not much effect
        params.extra_time_after_offset = 2; % s
    case 'fp'
        params.extra_baseline_time = 0.3; % extra frames to use for baseline
        params.extra_time_after_offset = 2; % s
end

if exist('processparams_local.m','file')
    oldparams = params;
    params = processparams_local( params );
    changed_process_parameters(params,oldparams);
end


