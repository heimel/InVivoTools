function record = tp_link_rois( record, linkall )
%TP_LINK_ROIS links rois to neurite rois
%
% RECORD = TP_LINK_ROIS( RECORD, LINKALL )
%
% if length(record.ROIs.celllist(i).neurite) == 2 then ROI was linked by computer
% if length(record.ROIs.celllist(i).neurite) == 1 then ROI was linked by hand 
%
% 2011-2015, Alexander Heimel
%

if nargin<2 || isempty(linkall)
    linkall = false;
end

params = tpreadconfig(record);

if isempty(params)
    logmsg('No image information. Cannot link ROIs');
    return
end

processparams = tpprocessparams(record);

roilist = record.ROIs.celllist;

if ~isfield(roilist,'neurite')
    % i.e. nothing has been linked
    linkall = true;
end

ind_neurites = find(cellfun(@is_neurite,{roilist.type}));
ind_no_neurites = find(~cellfun(@is_neurite,{roilist.type}));

% each no_neurite_roi will be connected to closest neurite_roi within processparams.max_roi_linking_distance_um

for j = ind_neurites
    neurite_poly(j) = interpolate_poly(interpolate_poly(interpolate_poly(roilist(j)))); %#ok<AGROW>
    roilist(j).neurite =[roilist(j).index tp_get_neurite_length(roilist(j),record)];
end


if linkall
    for i = ind_no_neurites
        roilist(i).neurite = [NaN Inf];
        center_roi1.xi = median(roilist(i).xi); % take center
        center_roi1.yi = median(roilist(i).yi); % take center
        center_roi1.zi = median(roilist(i).zi); % take center
        for j = ind_neurites
            dis = distance_point2polygon( center_roi1,neurite_poly(j),params);
            if dis <= processparams.max_roi_linking_distance_um
                if isempty(roilist(i).neurite)
                    roilist(i).neurite(1) = roilist(j).index;
                    roilist(i).neurite(2) = dis;
                else % only replace if closer
                    if dis <  roilist(i).neurite(2)
                        roilist(i).neurite(1) = roilist(j).index;
                        roilist(i).neurite(2) = dis;
                    end
                end
            end
        end % j
    end % i
end
record.ROIs.celllist = roilist;




% copy ROI info to measures and recompute distances, do not link
if isfield(record.ROIs.celllist,'neurite')
    for i = 1:length(record.ROIs.celllist)
        record.measures(i).distance2neurite = NaN;
        record.measures(i).linked2neurite = NaN;

        if isnan(record.ROIs.celllist(i).neurite(1))
            continue
        end

        ind_neurite = find(record.ROIs.celllist(i).neurite(1));
        if isempty(ind_neurite)
            errormsg(['Unable to find neurite with index ' num2str(record.ROIs.celllist(i).neurite(1)) ' of ROI ' num2str(record.ROIs.celllist(i).index)]);
            return
        end
        if record.ROIs.celllist(i).index == record.ROIs.celllist(i).neurite(1)
            continue % because ROI is neurite itself
        end
        
        center_roi.xi = median(record.ROIs.celllist(i).xi); % take center
        center_roi.yi = median(record.ROIs.celllist(i).yi); % take center
        center_roi.zi = median(record.ROIs.celllist(i).zi); % take center
        dis = distance_point2polygon( center_roi,neurite_poly(ind_neurite),params ) ;
        
        if isinf(dis)
            logmsg(['Infinite distance to neurite for ROI ' num2str(record.measures(i).index)]);
            continue
        end
        
        record.measures(i).linked2neurite = record.ROIs.celllist(i).neurite(1);
        record.measures(i).distance2neurite = dis ;
    end
end


function dis = distance_point2polygon( point,poly,params)
dis = min(sqrt(params.x_step^2 * (poly.xi-point.xi).^2 + ...
    params.y_step^2 *(poly.yi-point.yi).^2 + ...
    params.z_step^2 *(poly.zi-point.zi).^2 ));
if isnan(dis) % perhaps no z-coordinate
    dis = min(sqrt( params.x_step^2 *(poly.xi-point.xi).^2 + ...
        params.y_step^2 *(poly.yi-point.yi).^2 ));
end


function poly_fine = interpolate_poly( poly )
% doubles number of interpolation points of poly
poly_fine.xi(1:2:2*length(poly.xi)-1) = poly.xi;
poly_fine.xi(2:2:2*length(poly.xi)-2) = (poly.xi(1:end-1)+poly.xi(2:end))/2;
poly_fine.yi(1:2:2*length(poly.yi)-1) = poly.yi;
poly_fine.yi(2:2:2*length(poly.yi)-2) = (poly.yi(1:end-1)+poly.yi(2:end))/2;
poly_fine.zi(1:2:2*length(poly.zi)-1) = poly.zi;
poly_fine.zi(2:2:2*length(poly.zi)-2) = (poly.zi(1:end-1)+poly.zi(2:end))/2;




