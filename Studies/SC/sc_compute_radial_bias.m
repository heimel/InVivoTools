function sc_compute_radial_bias
%SC_COMPUTE_RADIAL_BIAS
%
% 2014, Alexander Heimel


db = load_expdatabase( 'testdb_jander');

mouse{1} = '13.61.2.12';
retinotopy_record_crit{1} = 'mouse=13.61.2.12,test=mouse_E11,stim_type=retinotopy';
stimrect{1} = [320 270 1600 945];
monitorcenter_rel2nose_cm{1} = [ -14,4,29.5]; % x cm left, y cm up, viewing distance cm
orientation_record_crit{1} = 'mouse=13.61.2.12,test=mouse_E12,stim_type=orientation';
significance_record_crit{1} = 'mouse=13.61.2.12,test=mouse_E12,stim_type=significance';
significance_threshold{1} = 0.1;

mouse{2} = '13.61.2.14';
retinotopy_record_crit{2} = 'mouse=13.61.2.14,test=mouse_E7,stim_type=retinotopy';
stimrect{2} = [3*1920/12 1*1080/8 9*1920/12 7*1080/8];
monitorcenter_rel2nose_cm{2} = [ -14,-5,29.5]; % x cm left, y cm up, viewing distance cm
orientation_record_crit{2} = 'mouse=13.61.2.14,test=mouse_E5,stim_type=orientation';
significance_record_crit{2} = 'mouse=13.61.2.14,test=mouse_E5,stim_type=significance';
significance_threshold{2} =1;

mouse{3} = '13.61.2.13';
retinotopy_record_crit{3} = 'mouse=13.61.2.13,test=mouse_E7,stim_type=retinotopy';
stimrect{3} = [2*1920/12 2*1080/8 9*1920/12 8*1080/8];
monitorcenter_rel2nose_cm{3} = [ -14,-5,29.5]; % x cm left, y cm up, viewing distance cm
orientation_record_crit{3} = 'mouse=13.61.2.13,test=mouse_E5,stim_type=orientation';
significance_record_crit{3} = 'mouse=13.61.2.13,test=mouse_E5,stim_type=significance';
significance_threshold{3} =1; % 0.05;

i = 4;
mouse{i} = '13.61.2.07';
retinotopy_record_crit{i} = 'mouse=13.61.2.07,test=mouse_E10,stim_type=retinotopy';
stimrect{i} = [0 0 1200 800];
 monitorcenter_rel2nose_cm{i} = [ -20,-10,29.5];  
crit = 'mouse=13.61.2.07,test=mouse_E4';
crit = 'mouse=13.61.2.07,test=mouse_E5';
orientation_record_crit{i} = [crit ',stim_type=orientation'];
significance_record_crit{i} =  [crit ',stim_type=significance'];
significance_threshold{i} =1; %0.05;

i = 5;
mouse{i} = '13.61.2.19';
retinotopy_record_crit{i} = 'mouse=13.61.2.19,test=mouse_E3,stim_type=retinotopy';
stimrect{i} = [0 0 1000 800];
retinotopy_record = db(find_record(db,retinotopy_record_crit{i}));
monitorpatch_x = [  1  2   3  1  2   3   1  2   3];
monitorpatch_y = [  1  1   1  2  2   2   3  3   3];
x =              [nan 90 105 80 90 105 nan 90 105];
y =              [nan 55  60 40 42  50 nan 35  40];
%override_response_centers( retinotopy_record, monitorpatch_x, monitorpatch_y, x, y )
monitorcenter_rel2nose_cm{i} = [ -15,-3.5,29.5]; % x cm left, y cm up, viewing distance cm
monitorcenter_rel2nose_cm{i} = [ -15,-8,29.5]; % x cm left, y cm up, viewing distance cm
orientation_record_crit{i} = 'mouse=13.61.2.19,test=mouse_E4,stim_type=orientation';
significance_record_crit{i} = 'mouse=13.61.2.19,test=mouse_E4,stim_type=significance';
significance_threshold{i} = 1;%0.1;

i = 6;
mouse{i} = '13.61.2.03';
retinotopy_record_crit{i} = 'mouse=13.61.2.03,test=mouse_E11,stim_type=retinotopy';
retinotopy_record = db(find_record(db,retinotopy_record_crit{i}));
monitorpatch_x = [ 5  5  5  4   4];
monitorpatch_y = [ 3  4  2  3   4];
x =              [63 55  71 60  52 ];
y =              [54 48  60 62  58 ];
%override_response_centers( retinotopy_record, monitorpatch_x, monitorpatch_y, x, y )
stimrect{i} = [0 0 1080 1080];
monitorcenter_rel2nose_cm{i} = [ 0,-3.5,29.5]; % x cm left, y cm up, viewing distance cm
orientation_record_crit{i} = 'mouse=13.61.2.03,test=mouse_E10,stim_type=orientation';
significance_record_crit{i} = 'mouse=13.61.2.03,test=mouse_E10,stim_type=significance';
significance_threshold{i} = 1; %0.05;

radial_angle_all = [];
orientation_all = [];    



for i=1 :length(retinotopy_record_crit)
    % retinotopy and radial map
    retinotopy_record = db(find_record(db,retinotopy_record_crit{i}));
    if isempty(retinotopy_record)
        errormsg('Could not find retinotopy');
    end
    
    retinotopy_record.stimrect = stimrect{i};
    retinotopy_record.monitorcenter_rel2nose_cm = monitorcenter_rel2nose_cm{i};
    [retinotopy_record,avg] = analyse_testrecord( retinotopy_record);
    
    
    
    [img_rf_radial_angle_deg,img_rf_azimuth_deg,img_rf_elevation_deg] = ...
        oi_compute_response_centers(avg, retinotopy_record);
    img_rf_radial_angle_deg = mod(img_rf_radial_angle_deg,180);
    
    % orientation map
    orientation_record = db(find_record(db,orientation_record_crit{i}));
    if isempty(orientation_record)
        errormsg(['Could not find record matching ' orientation_record_crit{i}] );
    end
    [orientation_record,avg] = analyse_testrecord( orientation_record);

%     orientation_record.stim_parameters = [45 0 90 135 225 180 270 315];
%     orientation_record.stim_parameters = rand(1,8)*360
    
    multfac = 2; %
    polavg = zeros(size(avg,1),size(avg,2));
    for c=1:size(avg,3)
        polavg = polavg + avg(:,:,c) * exp(multfac*pi*1i*orientation_record.stim_parameters(c)/180);
    end
    img_orientation = angle(polavg);
    img_orientation = mod(img_orientation/pi*180,360)/2;
    img_orientation(isnan(img_rf_radial_angle_deg)) = nan;
    
    % significance map
    significance_record = db(find_record(db,significance_record_crit{i}));
    if isempty(significance_record)
        significance_record = orientation_record;
        significance_record.stim_type = 'significance';
    end
    fname = fullfile(oidatapath(significance_record),[significance_record.test '_significance.mat']);
    if exist(fname,'file')
        load(fname);
    else
        [significance_record,avg] = analyse_testrecord( significance_record);
        load(fname);
    end
    
    mask = ~isnan(img_rf_azimuth_deg) ;
    
    mask = ~isnan(img_rf_azimuth_deg) & (signif_between_groups<significance_threshold{i});
    
    radial_angle_all = [radial_angle_all ; img_rf_radial_angle_deg(mask)];
    orientation_all = [orientation_all; img_orientation(mask)];    
    
    ccc = circ_corrcc(2* img_rf_radial_angle_deg(logical(mask))/180*pi,2* img_orientation(mask)/180*pi);
    logmsg(['Mouse ' mouse{i} ' circ. corrcoeff radial and orientation map (all) = ' num2str(ccc)]);
    
    mask = ~isnan(img_rf_azimuth_deg) & (signif_between_groups<significance_threshold{i});
    if ~any(mask(:))
        mask =  ~isnan(img_rf_azimuth_deg);
        logmsg('No significant pixels. Setting threshold to inf.');
        significance_threshold{i} = inf;
    end
    ccc = circ_corrcc( 2*img_rf_radial_angle_deg(logical(mask))/180*pi,2*img_orientation(mask)/180*pi);
    logmsg(['Mouse ' mouse{i} ' circ. corrcoeff radial and orientation map (sign) = ' num2str(ccc)]);
    
    
    % making figures
    figure('Name',mouse{i});
    colormap hsv
    ylimits = [max(1,find(~isnan(nanmean(img_rf_radial_angle_deg,1)),1,'first')-5) ...
        min(size(img_rf_radial_angle_deg,2),find(~isnan(nanmean(img_rf_radial_angle_deg,1)),1,'last')+5)] ;
    
    xlimits = [max(1,find(~isnan(nanmean(img_rf_radial_angle_deg,2)),1,'first')-5) ...
        min(size(img_rf_radial_angle_deg,1),find(~isnan(nanmean(img_rf_radial_angle_deg,2)),1,'last')+5)];
    
    subplot(2,3,1);
    imagesc(img_rf_azimuth_deg')
    set(gca,'clim',[-50 20])
    axis image off
    ylim(ylimits);
    xlim(xlimits);
    title('Azimuth map');
    set(get(gca,'children'),'Alphadata',~isnan(img_rf_azimuth_deg'))
    colorbar
    
    subplot(2,3,2);
    imagesc(img_rf_elevation_deg')
    set(gca,'clim',[-30 30])
    axis image off
    ylim(ylimits);
    xlim(xlimits);
    title('Elevation map');
    set(get(gca,'children'),'Alphadata',~isnan(img_rf_azimuth_deg'))
    colorbar
    
    subplot(2,3,3);
    if significance_threshold{i}<1
        image(repmat(double(signif_between_groups'<significance_threshold{i}),[1 1 3]))
    else
        imagesc(signif_between_groups')
    end
    axis image off
    ylim(ylimits);
    xlim(xlimits);
    set(get(gca,'children'),'Alphadata',~isnan(img_rf_azimuth_deg'))
    title('Significant\newlineorientation preference');
    h = colorbar;
    set(h,'visible','off');
    
        subplot(2,3,4);
    imagesc(img_rf_radial_angle_deg')
    set(gca,'clim',[0 180])
    axis image off
    ylim(ylimits);
    xlim(xlimits);
    title('Radial angle map');
    set(get(gca,'children'),'Alphadata',mask')
    h = colorbar;
    set(h,'ytick',[0.5 45 90 135 179.5]);
    set(h,'yticklabel',{'0','45','90','135','180'})
    
    subplot(2,3,5);
    imagesc(img_orientation')
    set(gca,'clim',[0 180])
    axis image off
    ylim(ylimits);
    xlim(xlimits);
    title('Orientation map');
    set(get(gca,'children'),'Alphadata',mask')
    h = colorbar;
    set(h,'ytick',[0.5 45 90 135 179.5]);
    set(h,'yticklabel',{'0','45','90','135','180'})
    
    subplot(2,3,6)
     plot(flatten(img_rf_radial_angle_deg(mask)),...
        flatten(img_orientation(mask)),'.k')
    axis([0 180 0 180])
    axis square
    xlabel('Radial angle (deg)');
    ylabel('Orientation (deg)');
    box off
    
end


figure('name','All mice');
plot(radial_angle_all,orientation_all,'.k')
axis([0 180 0 180])
axis square
xlabel('Radial angle (deg)');
ylabel('Orientation (deg)');
box off
xyline

circ_corrcc(radial_angle_all/180*pi*2,orientation_all/180*pi*2)
%circ_corrcc(radial_angle_all/180*pi,orientation_all/180*pi)

save(fullfile(getdesktopfolder,'orientation_radial.mat'),'radial_angle_all','orientation_all');
global radial_angle_all orientation_all

angle_diffs = angle(exp(1i*(radial_angle_all-orientation_all)/180*pi));
angle_diffs(angle_diffs>pi/2) = angle_diffs(angle_diffs>pi/2)-pi;
figure;
hist(angle_diffs/pi*180,30)
xlabel('Angular difference (deg)');
ylabel('n pixels');




function override_response_centers( retinotopy_record, monitorpatch_x, monitorpatch_y, x, y )
filename = fullfile(oidatapath(retinotopy_record),[retinotopy_record.test '_response_centers.mat']);
cx = x;
cy = y;
ind = ~isnan(x);
monitorpatch_x = monitorpatch_x(ind);
monitorpatch_y = monitorpatch_y(ind);
x = x(ind);
y = y(ind);
save(filename,'monitorpatch_x','monitorpatch_y','x','y','cx','cy');

figure
subplot(1,2,1)
image(imread(fullfile(oidatapath(retinotopy_record),'analysis',retinotopy_record.imagefile)));
axis image
hold on
for i=1:length(x);
    text(y(i),x(i),[ num2str(monitorpatch_x(i)) ',' num2str(monitorpatch_y(i))],'color',[1 1 1],'horizontalalignment','center');
end
subplot(1,2,2)
show_retinotopy_colors(retinotopy_record);
