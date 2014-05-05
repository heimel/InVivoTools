function params = oiprocessparams(record)
%OIPROCESSPARAMS contains experiment dependent process parameters
%
% 2013-2014, Alexander Heimel
%

if nargin<1
    record = [];
end
if isempty(record)
    record.mouse = '';
    record.datatype = 'oi';
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
    case '13.61'
          params.wta_equalize_area = true;
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
    case '13.61'
        params.spatial_filter_width = 10; % pixels use nan to turn off filter
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
