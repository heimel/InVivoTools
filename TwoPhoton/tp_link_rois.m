function record = tp_link_rois( record )
%TP_LINK_ROIS links rois to neurite rois
%
% RECORD = TP_LINK_ROIS( RECORD )
%
% 2011-2013, Alexander Heimel
%

params = tpreadconfig(record);

if isempty(params)
    logmsg('No image information. Cannot link ROIs');
    return
end

processparams = tpprocessparams(record);

maximum_distance_pxl = processparams.max_roi_linking_distance_um / params.x_step ;

%logmsg('Linking parameters are set in tpprocesparams');

roilist = record.ROIs.celllist;

ind_neurites = find(cellfun(@is_neurite,{roilist.type}));
ind_no_neurites = find(~cellfun(@is_neurite,{roilist.type}));

% each no_neurite_roi will be connected to closest neurite_roi within
% maximum_distance_pxl

for j = ind_neurites
    neurite_poly(j) = interpolate_poly(interpolate_poly(interpolate_poly(roilist(j)))); %#ok<AGROW>
end


for i = ind_no_neurites
    roilist(i).neurite = [NaN Inf];
    center_roi1.xi = median(roilist(i).xi); % take center
    center_roi1.yi = median(roilist(i).yi); % take center
    center_roi1.zi = median(roilist(i).zi); % take center
    
    for j = ind_neurites
        dis = distance_point2polygon( center_roi1,neurite_poly(j) );
        if dis <= maximum_distance_pxl
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
    end % i
end % j

if isfield(roilist,'neurite')
    for i = 1:length(roilist)
        record.measures(i).distance2neurite = roilist(i).neurite(2) *  params.x_step;
        if isinf(record.measures(i).distance2neurite)
            record.measures(i).distance2neurite = NaN;
        end
    end
end

record.ROIs.celllist = roilist; 


function dis = distance_point2polygon( point,poly)
dis = min(sqrt( (poly.xi-point.xi).^2 + (poly.yi-point.yi).^2 + (poly.zi-point.zi).^2 ));
if isnan(dis) % perhaps no z-coordinate
    dis = min(sqrt( (poly.xi-point.xi).^2 + (poly.yi-point.yi).^2 ));
end


function poly_fine = interpolate_poly( poly )
% doubles number of interpolation points of poly
poly_fine.xi(1:2:2*length(poly.xi)-1) = poly.xi;
poly_fine.xi(2:2:2*length(poly.xi)-2) = (poly.xi(1:end-1)+poly.xi(2:end))/2;
poly_fine.yi(1:2:2*length(poly.yi)-1) = poly.yi;
poly_fine.yi(2:2:2*length(poly.yi)-2) = (poly.yi(1:end-1)+poly.yi(2:end))/2;
poly_fine.zi(1:2:2*length(poly.zi)-1) = poly.zi;
poly_fine.zi(2:2:2*length(poly.zi)-2) = (poly.zi(1:end-1)+poly.zi(2:end))/2;




