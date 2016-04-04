function [angular_area,mean_angle,azimuth_angle,elevation_angle] = rect2visualangle( rect, monitor)
%RECT2VISUALANGLE compute the angular area of a rect in radians
%
% [ANGULAR_AREA,MEAN_ANGLE,AZIMUTH_ANGLE,ELEVATION_ANGLE] = RECT2VISUALANGLE( RECT, MONITOR)
%
%    RECT = [LEFT TOP RIGHT BOTTOM]
%    MONITOR contains monitor dimensions as specified in PXL2SPH
%
%    RECT will be clipped to monitor boundaries, if MONITOR is specified
%
%    ANGULAR_AREA is area spanned by RECT in square radians
%    MEAN_ANGLE is geometric mean of AZIMUTH_ANGLE and ELEVATION_ANGLE in radians
%
% 2016, Alexander Heimel
%

if nargin<2 
    monitor = [];
end

left = rect(1);
top = rect(2);
right = rect(3);
bottom = rect(4);

if ~isempty(monitor)
    left = max(left,0);
    left = min(left,monitor.size_pxl(1));
    right = max(right,0);
    right = min(right,monitor.size_pxl(1)); 

    top = max(top,0);
    top = min(top,monitor.size_pxl(2));
    bottom = max(bottom,0);
    bottom = min(bottom,monitor.size_pxl(2)); 
end

left_azimuth = pxl2sph( left,(top+bottom)/2,monitor);
right_azimuth = pxl2sph( right,(top+bottom)/2,monitor);
[~,top_elevation] = pxl2sph( (left+right)/2,top,monitor);
[~,bottom_elevation] = pxl2sph( (left+right)/2,bottom,monitor);

% angular_area = int delevation int dazimuth cos(elevation)
angular_area = (right_azimuth - left_azimuth)*(sin(top_elevation)-sin(bottom_elevation));
azimuth_angle = abs(right_azimuth - left_azimuth);
elevation_angle = abs(top_elevation - bottom_elevation);
mean_angle = sqrt(azimuth_angle * elevation_angle);
