function [azimuth_rad,elevation_rad,r_cm] = pxl2sph( x_pxl,y_pxl,monitor)
%PXL2SPH transforms monitor position in pixels to spherical coordinates in radians
%
% [AZIMUTH_DEG,ELEVATION_DEG,R_CM] = PXL2SPH( X_PXL,Y_PXL,MONITOR)
%
% monitor = 
%   size_cm,  2x1 vector, e.g. [51 29] cm
%   size_pxl,  2x1 vector, e.g. [1920 1080] 
%   center_rel2nose_cm, 3x1 vector, [x y z]
%          x is right relative to nose  (positive is right)
%          y is height relative to nose (positive is up)
%          z is depth relative to nose (positive is in front of nose)
%   tilt_deg, is 0 by default. Positive values are right-side up, as seen
%          by the mouse
%   slant_deg, is 0 by default. Positive values are left towards the mouse
%
% 2016, Alexander Heimel

if nargin<3 || isempty(monitor)
    monitor.size_cm = [51 29];
    monitor.size_pxl = [1920 1080];
    monitor.center_rel2nose_cm = [0 0 15];
    disp(['PXL2SPH: Defaulting to monitor size ' mat2str(monitor.size_cm) ...
        ' and resolution ' mat2str(monitor.size_cm) ' and position ' ...
        mat2str(monitor.center_rel2nose_cm) ]);
end
    
if ~isfield(monitor,'tilt_deg')
    monitor.tilt_deg = 40;
end

if ~isfield(monitor,'slant_deg')
    monitor.slant_deg = 0;
end

[x_cm,y_cm,z_cm] = monitorposition2realworld_cm(x_pxl,y_pxl,monitor);

[azimuth_rad,elevation_rad,r_cm] = cart2sph( z_cm,x_cm,y_cm);

function [x,y,z] = monitorposition2realworld_cm(x_pxl,y_pxl,monitor)

monitor.tilt_rad = monitor.tilt_deg/180*pi;
monitor.slant_rad = monitor.slant_deg/180*pi;

x_rel2monitorleft_pxl = x_pxl;
x_rel2monitorleft_cm = x_rel2monitorleft_pxl * monitor.size_cm(1) / monitor.size_pxl(1);
x_rel2monitorcenter_cm = x_rel2monitorleft_cm - 0.5*monitor.size_cm(1);

y_rel2monitortop_pxl = y_pxl;
y_rel2monitortop_cm = y_rel2monitortop_pxl * monitor.size_cm(2) / monitor.size_pxl(2);
y_rel2monitorcenter_cm = -y_rel2monitortop_cm + 0.5*monitor.size_cm(2);

y_rel2nose_cm = monitor.center_rel2nose_cm(2) + ...
    cos(monitor.tilt_rad)*y_rel2monitorcenter_cm +  sin(monitor.tilt_rad)*x_rel2monitorcenter_cm;

x_rel2nose_cm = monitor.center_rel2nose_cm(1) + ...
    -sin(monitor.tilt_rad)*y_rel2monitorcenter_cm +  cos(monitor.tilt_rad)*x_rel2monitorcenter_cm;

y = y_rel2nose_cm;
x = cos(monitor.slant_rad)*x_rel2nose_cm ;
z = monitor.center_rel2nose_cm(3) + sin(monitor.slant_rad)*x_rel2nose_cm;


