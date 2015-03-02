function [vsf,hsf]=compute_real_sf
%COMPUTE_REAL_SF
%%
% 2014, Alexander Heimel
%


x = -35:35; % cm
y = -26:26; % cm
[gx,gy]=meshgrid(x,y);

sf = 0.05; % cpd

z = 15; % cm
pixels_per_cm = 1152/75;  % should get from robbie

%z=24;
%pixels_per_cm = 800/70.5;  % should get from robbie

[rsf,csf] =  get_real_sf(gx,gy,z,sf,pixels_per_cm);
clim = [min([rsf(:);csf(:)]) max([rsf(:);csf(:)])];

figure;
subplot(1,2,1);
imagesc(rsf,clim)
axis image
title('Radial SF (cpd)');
subplot(1,2,2)
imagesc(csf,clim)
axis image
title('Concentric SF (cpd)');

figure;
imagesc(csf./rsf);
keyboard

function [radial_sf,concentric_sf] = get_real_sf(x,y,z,sf,pixels_per_cm)

cm_per_degree = 2*z*tan(0.5/180*pi);
pixels_per_degree = pixels_per_cm * cm_per_degree

width_pixels = 1/sf * pixels_per_degree; % 
w = width_pixels / pixels_per_cm; % width in cm

h = sqrt(x.^2 + y.^2);
r = sqrt(h.^2 + z.^2);
concentric_angle_deg = atan(w ./r)/pi*180;
radial_angle_deg = atan((h+w)./z)/pi*180 - atan(h./z)/pi*180;
concentric_sf = 1./radial_angle_deg;
radial_sf = 1./concentric_angle_deg;


% [az_mid_rad,el_up_rad,r] = cart2sph( z,x,y+width_cm/2);
% [az_mid_rad,el_dn_rad,r] = cart2sph( z,x,y-width_cm/2);
% real_height_deg = (el_up_rad-el_dn_rad)/pi*180
% real_vert_sf = 1./real_height_deg;
% 
% [az_left_rad,el_mid_rad,r] = cart2sph( z,x-width_cm/2,y);
% [az_right_rad,el_mid_rad,r] = cart2sph( z,x+width_cm/2,y);
% real_width_deg = (az_right_rad-az_left_rad)/pi*180
% real_hori_sf = 1./real_width_deg;
% 
% 
