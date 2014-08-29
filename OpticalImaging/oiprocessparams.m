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


params.average_image_normmethod = 'subtractframe_ror'; % Delta R/R_baseline / (1+delta R_ROR/ROR_baseline)

params.wta_equalize_area = false;
params.wta_show_roi = true;
params.wta_show_ror = true;
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
% switch record.stim_type
%     case 'orientation'
%         params.spatial_filter_width = 1;
% end
% 

params.single_condition_clipping = 5; 
  % number of standard deviations to clip and scale images to.
  % when set to 0, no clipping occurs
params.single_condition_differential = false;
params.single_condition_normalize_response = false;
params.single_condition_show_roi = true;
params.single_condition_show_ror = true;
params.single_condition_show_monitor_center = true;
switch record.stim_type
    case {'orientation','direction'}
        params.single_condition_clipping = 0;
        params.single_condition_differential = true;
        params.single_condition_normalize_response = true;
end
switch experiment
    case '13.61'
        params.single_condition_clipping = 0;
end

% reference image
params.reference_show_lambda = true;
params.reference_show_roi = true;

switch record.datatype
    case 'oi'
        params.extra_baseline_time = 0.6; % extra frames to use for baseline
        % using one, because in first 600 ms after stimulus not much effect
        params.extra_time_after_offset = 2; % s
    case 'fp'
        params.extra_baseline_time = 0.3; % extra frames to use for baseline
        params.extra_time_after_offset = 2; % s
end


% for oi_compute_response_centers
params.oi_response_center_offset = 0.001;
params.oi_response_center_threshold = 0.003;

params.oi_monitor_size_cm = [NaN NaN];
params.oi_monitor_size_pxl = [NaN NaN];
switch record.setup
    case 'jander' % correct on 2014-08-16
        params.oi_monitor_size_cm = [92 52];
        params.oi_monitor_size_pxl = [1920 1080];
end

%%%%

if exist('processparams_local.m','file')
    oldparams = params;
    params = processparams_local( params );
    changed_process_parameters(params,oldparams);
end


