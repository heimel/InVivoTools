function [img_rf_radial_angle_deg,img_rf_azimuth_rad,img_rf_elevation_rad] = oi_compute_response_centers(avg, record)
%OI_COMPUTE_RESPONSE_CENTERS compute for each stimulus the center of mass
%
%   [img_rf_radial_angle_deg,img_rf_azimuth_rad,img_rf_elevation_rad] =
%         oi_compute_response_centers(avg, record)
%
% 2014, Alexander Heimel
%

params.oi_response_center_offset = 0.001;
params.oi_response_center_threshold = 0.003;

params.oi_monitorcenter_rel2nose_cm = [ 0,0]; % x cm left, y cm up
params.oi_viewing_distance_cm = 29.5;
params.oi_monitor_size_cm = [92 52];
params.oi_monitor_size_pxl = [1920 1080];


logmsg('Calculating response centers');
n_stim = size(avg,3);

switch record.stim_type
    case {'retinotopy','rt_response'}
        nx = record.stim_parameters(1);
        ny = record.stim_parameters(2);
    case {'sf_contrast','contrast_sf'}
        nx = length(record.stim_sf);
        ny = length(record.stim_contrast);
    otherwise
        nx = n_stim;
        ny = 1;
end


x = [];
y = [];
monitorpatch_x = [];
monitorpatch_y = [];
cx = NaN(n_stim,1);
cy = NaN(n_stim,1);
sx = NaN(n_stim,1);
sy = NaN(n_stim,1);
cxy = NaN(n_stim,1);
PeakOD = NaN(n_stim,1);

for i=1:n_stim
    if max(flatten(avg(:,:,i)))>params.oi_response_center_offset
        [cx(i),cy(i),sx(i),sy(i),cxy(i),PeakOD(i)] = Gaussian2D(thresholdlinear(avg(:,:,i)-params.oi_response_center_offset));
        if PeakOD(i)>params.oi_response_center_threshold
            x(end+1) = cx(i);
            y(end+1) = cy(i);
            monitorpatch_x(end+1) = mod(i-1,nx)+1;
            monitorpatch_y(end+1) = ceil(i/nx);
        end
    end        
end

if length(x)<2
    logmsg('Too few responses reaching threshold to compute grid');
    return
end



Fmonitorpatch_x = TriScatteredInterp([x(:) y(:)],monitorpatch_x(:)); % interpolation of monitor patch
Fmonitorpatch_y = TriScatteredInterp([x(:) y(:)],monitorpatch_y(:)); % interpolation of monitor patch

[gx,gy] = meshgrid(1:size(avg,2),1:size(avg,1)); 

img_monitorpatch_x = reshape(Fmonitorpatch_x([gx(:) gy(:)]),size(gx,1),size(gx,2));
img_monitorpatch_y = reshape(Fmonitorpatch_y([gx(:) gy(:)]),size(gx,1),size(gx,2));
[img_rf_radial_angle_deg,img_rf_azimuth_rad,img_rf_elevation_rad] = ...
    compute_angles(img_monitorpatch_x,img_monitorpatch_y,record,params,nx,ny);

figure
subplot(1,3,1)
imagesc(img_monitorpatch_x')
axis image off
hold on
plot(cy,cx,'+r');
plot(y,x,'+g');

subplot(1,3,2)
imagesc(img_monitorpatch_y')
axis image off
hold on
plot(cy,cx,'+r');
plot(y,x,'+g');

subplot(1,3,3)
imagesc(img_rf_radial_angle_deg')
axis image off
hold on
plot(cy,cx,'+r');
plot(y,x,'+g');

colormap hsv

figure
image(imread(fullfile(oidatapath(record),'analysis',record.imagefile)));
hold on
plot(cy,cx,'+r');
plot(y,x,'+w');
hold on
% contour(gx,gy,reshape(Fmx([gx(:) gy(:)]),size(gx,1),size(gx,2))  )
% contour(gx,gy,reshape(Fmy([gx(:) gy(:)]),size(gx,1),size(gx,2))  )

[c,h] = contour(gy,gx,img_monitorpatch_x,(min(monitorpatch_x)+0.5):(max(monitorpatch_x)-0.5)  );
set(h,'linecolor',[1 1 1]);
[c,h] = contour(gy,gx,img_monitorpatch_y,(min(monitorpatch_y)+0.5):(max(monitorpatch_y)-0.5)  );
set(h,'linecolor',[1 1 1]);
% [c,h] = contour(gy,gx,img_rf_radial_angle_deg ,[1 90 ]);
% set(h,'linecolor',[1 1 1]);

% figure
% for i=1:n_stim
%     subplot(nx,ny,i)
%     imagesc(avg(:,:,i)');
%     axis image off
%     colormap gray
%     hold on
%     if PeakOD(i)>params.oi_response_center_threshold
%         plot(cy(i),cx(i),'+r');
%     end
% end




function [rf_radial_angle_deg,rf_azimuth_rad,rf_elevation_rad,rf_r_cm] = compute_angles(monitorpatch_x,monitorpatch_y,record,params,nx,ny)


rf_x_rel2monitorleft_pxl = (record.stimrect(1) + (monitorpatch_x-0.5)*(record.stimrect(3)-record.stimrect(1))/nx );
rf_x_rel2monitorleft_cm = rf_x_rel2monitorleft_pxl * params.oi_monitor_size_cm(1) / params.oi_monitor_size_pxl(1);
rf_x_rel2nose_cm = rf_x_rel2monitorleft_cm - 0.5*params.oi_monitor_size_cm(1) + params.oi_monitorcenter_rel2nose_cm(1);

rf_y_rel2monitortop_pxl = (record.stimrect(2) + (monitorpatch_y-0.5)*(record.stimrect(4)-record.stimrect(2))/ny );
rf_y_rel2monitortop_cm = rf_y_rel2monitortop_pxl * params.oi_monitor_size_cm(2) / params.oi_monitor_size_pxl(2);
rf_y_rel2nose_cm = -rf_y_rel2monitortop_cm + 0.5*params.oi_monitor_size_cm(2) + params.oi_monitorcenter_rel2nose_cm(2);

[rf_azimuth_rad,rf_elevation_rad,rf_r_cm] = cart2sph( params.oi_viewing_distance_cm,rf_x_rel2nose_cm,rf_y_rel2nose_cm);

rf_radial_angle_deg = cart2pol(rf_elevation_rad,rf_azimuth_rad)/pi*180;

