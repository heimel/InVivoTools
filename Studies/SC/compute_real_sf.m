function [vsf,hsf]=compute_real_sf
%COMPUTE_REAL_SF
%
% 2014, Alexander Heimel
%


z = 15; % cm
x = -35:35; % cm
y = -26:26; % cm
[gx,gy]=meshgrid(x,y);

sf = 1; % cpd
pixels_per_cm = 800/70.5;  % should get from robbie

[vsf,hsf] =  get_real_sf(gx,gy,z,sf,pixels_per_cm)

figure;
subplot(2,1,1);
imagesc(vsf)
subplot(2,1,2);
imagesc(hsf)

function [real_vert_sf,real_hori_sf] = get_real_sf(x,y,z,sf,pixels_per_cm)

cm_per_degree = 2*z*tan(0.5/180*pi);
pixels_per_degree = pixels_per_cm * cm_per_degree;

width_pixels = 1/sf * pixels_per_degree; % 
width_cm = width_pixels / pixels_per_cm;


[az_mid_rad,el_up_rad,r] = cart2sph( z,x,y+width_cm/2);
[az_mid_rad,el_dn_rad,r] = cart2sph( z,x,y-width_cm/2);
real_height_deg = (el_up_rad-el_dn_rad)/pi*180
real_vert_sf = 1./real_height_deg;

[az_left_rad,el_mid_rad,r] = cart2sph( z,x-width_cm/2,y);
[az_right_rad,el_mid_rad,r] = cart2sph( z,x+width_cm/2,y);
real_width_deg = (az_right_rad-az_left_rad)/pi*180
real_hori_sf = 1./real_width_deg;


