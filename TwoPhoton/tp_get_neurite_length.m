function l = tp_get_neurite_length( roi, record )
%TP_GET_NEURITE_LENGTH returns length of rois
%
% 2012, Alexander Heimel
%
if isempty(roi)
    l = NaN;
    return
end
if length(roi.xi)==1
    l = 0;
    return
end

tpsetup(record);
params = tpreadconfig(record);
if isempty(params)
    disp(['TP_GET_NEURITE_LENGTH: Cannot read image information and can thus not compute lengths. ' recordfilter(record)] );
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
    disp(['TP_GET_NEURITE_LENGTH: Image is not a z-stack. ' recordfilter(record)]);
end

l = sum(sqrt( ...
    (params.x_step*diff(roi.xi)).^2 + ...
    (params.y_step*diff(roi.yi)).^2 + ...
    (params.z_step*diff(roi.zi)).^2 ));


