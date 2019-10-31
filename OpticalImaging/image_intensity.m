function [h,complexmap] = image_intensity(img,intensity,colmap,scalerange)
%IMAGE_INTENSITY
%
%  [H, COMPLEXMAP] = IMAGE_INTENSITY(IMG,INTENSITY,COLMAP,SCALERANGE)
%
%   IMG is the winner-take-all map with the number of winning conditions
%       for each pixel
%   INTENSITY is a map of the response strength
%   COLMAP is the colormap to use
%   SCALERANGE is the range of normalized intensities to use. [0,1] by
%       default
%
%  2004-2019, Alexander Heimel
%

if nargin<4 || isempty(scalerange)
   scalerange = [0 1]; 
end

if nargin<3 || isempty(colmap)
    colmap = hsv(5);
end

huemap = ind2rgb( img, colmap );

% remove infinities
intensity( isinf(intensity) & intensity>0 ) = max(intensity(~isinf(intensity)));
intensity( isinf(intensity) & intensity<0 ) = min(intensity(~isinf(intensity)));

intensity = intensity - min(intensity(:));
maxintensity = max(intensity(:)) * scalerange(2);
minintensity = maxintensity * scalerange(1);

% rescale intensity within range to [0,1]
intensity( intensity>maxintensity ) = maxintensity;
intensity( intensity<minintensity ) = minintensity;
intensity = (intensity - minintensity)/(maxintensity-minintensity);

% compute intensity scale map
complexmap = huemap .* repmat(intensity,1,1,3);

% clip final color map (should be superfluous after scaling intensity)
complexmap(:) = min(complexmap(:),1);
complexmap(:) = max(complexmap(:),0);

h = figure('Name','WTA map');
image(complexmap);
axis equal off
