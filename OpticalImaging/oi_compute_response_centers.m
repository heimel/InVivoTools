function [img_rf_radial_angle_deg,img_rf_azimuth_deg,img_rf_elevation_deg] = oi_compute_response_centers(avg, record)
%OI_COMPUTE_RESPONSE_CENTERS compute for each stimulus the center of mass
%
%   [img_rf_radial_angle_deg,img_rf_azimuth_rad,img_rf_elevation_rad] =
%         oi_compute_response_centers(avg, record)
%
% 2014, Alexander Heimel
%

img_rf_radial_angle_deg = [];
img_rf_azimuth_deg = [];
img_rf_elevation_deg = [];

logmsg('Calculating response centers');

params = oiprocessparams( record );

if ~isfield(record,'monitorcenter_rel2nose_cm')
    logmsg('Using default monitorcenter_rel2nose position');
    record.monitorcenter_rel2nose_cm = [ 0, 0, 29.5];% x cm left, y cm up, viewing distance cm
end

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

filename = fullfile(oidatapath(record),[record.test '_response_centers.mat']);
if ~exist(filename,'file')
    hwait = waitbar(0,'Calculating response centers');
    for i=1:n_stim
        waitbar((i-1)/n_stim,hwait);
        if max(flatten(avg(:,:,i)))>params.oi_response_center_offset
            [cx(i),cy(i),sx(i),sy(i),cxy(i),PeakOD(i)] = Gaussian2D(thresholdlinear(avg(:,:,i)-params.oi_response_center_offset));
            if PeakOD(i)>params.oi_response_center_threshold
                x(end+1) = cx(i);
                y(end+1) = cy(i);
                monitorpatch_x(end+1) = mod(i-1,nx)+1; %#ok<AGROW>
                monitorpatch_y(end+1) = ceil(i/nx); %#ok<AGROW>
            end
        end
    end
    close(hwait);
    save(filename,'monitorpatch_x','monitorpatch_y','x','y','cx','cy','sx','sy','cxy','PeakOD');
else
    load(filename);
    logmsg(['Loaded precalculated response centers from ' filename ]);
end


 
if length(monitorpatch_x)<2
    logmsg('Too few responses reaching threshold to compute grid');
    return
end



Fmonitorpatch_x = TriScatteredInterp([x(:) y(:)],monitorpatch_x(:)); % interpolation of monitor patch
Fmonitorpatch_y = TriScatteredInterp([x(:) y(:)],monitorpatch_y(:)); % interpolation of monitor patch

[gx,gy] = meshgrid(1:size(avg,2),1:size(avg,1));

img_monitorpatch_x = reshape(Fmonitorpatch_x([gx(:) gy(:)]),size(gx,1),size(gx,2));
img_monitorpatch_y = reshape(Fmonitorpatch_y([gx(:) gy(:)]),size(gx,1),size(gx,2));
[img_rf_radial_angle_deg,img_rf_azimuth_deg,img_rf_elevation_deg] = ...
    compute_angles(img_monitorpatch_x,img_monitorpatch_y,record,params,nx,ny);

% ylimits = [max(1,find(~isnan(nanmean(img_rf_radial_angle_deg,1)),1,'first')-5) ...
%     min(size(img_rf_radial_angle_deg,2),find(~isnan(nanmean(img_rf_radial_angle_deg,1)),1,'last')+5)] ;
% 
% xlimits = [max(1,find(~isnan(nanmean(img_rf_radial_angle_deg,2)),1,'first')-5) ...
%     min(size(img_rf_radial_angle_deg,1),find(~isnan(nanmean(img_rf_radial_angle_deg,2)),1,'last')+5)];
% 
% figure
% subplot(1,3,1)
% imagesc(img_monitorpatch_x')
% axis image off
% ylim(ylimits);
% xlim(xlimits);
% hold on
% plot(cy,cx,'+r');
% plot(y,x,'+g');
% 
% subplot(1,3,2)
% imagesc(img_monitorpatch_y')
% axis image off
% ylim(ylimits);
% xlim(xlimits);
% hold on
% plot(cy,cx,'+r');
% plot(y,x,'+g');
% 
% subplot(1,3,3)
% imagesc(img_rf_radial_angle_deg')
% axis image off
% ylim(ylimits);
% xlim(xlimits);
% hold on
% plot(cy,cx,'+r');
% plot(y,x,'+g');
% colormap hsv

figure
image(imread(fullfile(oidatapath(record),'analysis',record.imagefile)));
hold on
hold on

[c,h] = contour(gy,gx,img_monitorpatch_x,(min(monitorpatch_x)+0.5):(max(monitorpatch_x)-0.5)  );
set(h,'linecolor',[1 1 1]);
[c,h] = contour(gy,gx,img_monitorpatch_y,(min(monitorpatch_y)+0.5):(max(monitorpatch_y)-0.5)  );
set(h,'linecolor',[1 1 1]);

for i=1:length(cx);
    text(cy(i),cx(i),num2str(i),'color',[1 1 1]);
end

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




function [rf_radial_angle_deg,rf_azimuth_deg,rf_elevation_deg,rf_r_cm] = compute_angles(monitorpatch_x,monitorpatch_y,record,params,nx,ny)


rf_x_rel2monitorleft_pxl = (record.stimrect(1) + (monitorpatch_x-0.5)*(record.stimrect(3)-record.stimrect(1))/nx );
rf_x_rel2monitorleft_cm = rf_x_rel2monitorleft_pxl * params.oi_monitor_size_cm(1) / params.oi_monitor_size_pxl(1);
rf_x_rel2nose_cm = rf_x_rel2monitorleft_cm - 0.5*params.oi_monitor_size_cm(1) + record.monitorcenter_rel2nose_cm(1);

rf_y_rel2monitortop_pxl = (record.stimrect(2) + (monitorpatch_y-0.5)*(record.stimrect(4)-record.stimrect(2))/ny );
rf_y_rel2monitortop_cm = rf_y_rel2monitortop_pxl * params.oi_monitor_size_cm(2) / params.oi_monitor_size_pxl(2);
rf_y_rel2nose_cm = -rf_y_rel2monitortop_cm + 0.5*params.oi_monitor_size_cm(2) + record.monitorcenter_rel2nose_cm(2);

[rf_azimuth_rad,rf_elevation_rad,rf_r_cm] = cart2sph( record.monitorcenter_rel2nose_cm(3),rf_x_rel2nose_cm,rf_y_rel2nose_cm);
rf_azimuth_deg = rf_azimuth_rad / pi*180;
rf_elevation_deg = rf_elevation_rad / pi *180;
rf_radial_angle_deg = cart2pol(rf_elevation_rad,rf_azimuth_rad)/pi*180;

