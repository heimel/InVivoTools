function l = tp_get_neurite_length( roi, record, params )
%TP_GET_NEURITE_LENGTH returns length of rois
%
% 2012-2015, Alexander Heimel
%
if nargin<3
    params = [];
end

if isempty(roi)
    l = NaN;
    return
end
if length(roi.xi)==1
    l = 0;
    return
end

if isempty(params)
    tpsetup(record);
    params = tpreadconfig(record);
end

if isempty(params)
    logmsg(['Cannot read image information and can thus not compute lengths. ' recordfilter(record)] );
    l = 0;
    return
end
    
if length(roi.zi)<length(roi.xi)
    roi.zi = roi.zi*ones(size(roi.xi));
end

% remove last point if it is same as first point, i.e. circular
if roi.xi(1)==roi.xi(end) &&roi.yi(1)==roi.yi(end) && roi.zi(1)==roi.zi(end)
    roi.xi(end) = [];
    roi.yi(end) = [];
    roi.zi(end) = [];
end

if ~isfield(params,'z_step')
    params.z_step = 0;
    logmsg(['Image is not a z-stack. ' recordfilter(record)]);
end

l = sum(sqrt( ...
    (params.x_step*diff(roi.xi)).^2 + ...
    (params.y_step*diff(roi.yi)).^2 + ...
    (params.z_step*diff(roi.zi)).^2 ));


