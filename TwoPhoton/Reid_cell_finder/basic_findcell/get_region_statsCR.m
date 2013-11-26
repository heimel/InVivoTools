function  [strr,Centroid, EquivDiameter, Eccentricity,Extent,MajorAxisLength,MinorAxisLength] = get_region_statsCR(labelimage)
% get region statistics, usually for cell regions
% Uses regionprops in Image Processing toolbox
%  returns: Centroid (nLbl,2)
%    and 3 more arrays of nLbl elements ('Scalar'):
%  'EquivDiameter' - Scalar; the diameter of a circle with the same area as the 
%   region. Computed as sqrt(4*Area/pi). 
% 'Eccentricity' - Scalar; the eccentricity of the ellipse that has the same 
%   second-moments as the region. The eccentricity is the ratio of the distance 
%   between the foci of the ellipse and its major axis length. 
%   The value is between 0 and 1. (0 and 1 are degenerate cases; an ellipse 
%   whose eccentricity is 0 is actually a circle, while an ellipse whose eccentricity 
%   is 1 is a line segment.) 
%  'Extent' - Scalar; the proportion of the pixels in the bounding box that are also in the 
%    region.  Computed as the Area divided by area of the bounding box. CR:
%    this will be a small number for funny shapes
% 
% input: labelimage: 2D image with connected regions labelled with indices
% output:
% strr: structure with all of the outputs,
% then many variables with obvious names.
% CR started 040903


%function strr = get_region_statsCR(labelimage)  THIS IS FOR DEBUGGING

[xDim,yDim]=size(labelimage);

nLbl=max(max(labelimage));

strr=regionprops(labelimage,'Centroid', 'EquivDiameter', ...
        'Eccentricity','Extent','MajorAxisLength','MinorAxisLength');
centroidtmp={strr.Centroid};  % this is a CR crazy kludge to make a 2 by nLbl array
    % by making an intermediate cell array....  otherwise I got a 1 by
    % 2*nLbl array
Centroid = cell2mat(centroidtmp')';
EquivDiameter = [strr.EquivDiameter]; 
Eccentricity = [strr.Eccentricity];
Extent = [strr.Extent ];
MajorAxisLength = [strr.MajorAxisLength];
MinorAxisLength  = [strr.MinorAxisLength];
return
% OLD DELETED PROGRAMS:
%for j=1:nLbl
for j=1:2
    [xinds,yinds]=find(labelimage==j);  % 1-D indices 
    npix=length(xinds)
end

