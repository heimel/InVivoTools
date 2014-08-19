%function sc_compute_radial_bias
%SC_COMPUTE_RADIAL_BIAS
%
% 2014, Alexander Heimel

clear all

db = load_expdatabase( 'testdb_jander');

mouse{1} = '13.61.2.12';
retinotopy_record_crit{1} = 'mouse=13.61.2.12,test=mouse_E11,stim_type=retinotopy';
stimrect{1} = [320 270 1600 945];
monitorcenter_rel2nose_cm{1} = [ -14,4,29.5]; % x cm left, y cm up, viewing distance cm
orientation_record_crit{1} = 'mouse=13.61.2.12,test=mouse_E12,stim_type=orientation';
significance_record_crit{1} = 'mouse=13.61.2.12,test=mouse_E12,stim_type=significance';
significance_threshold{1} = 0.05;

mouse{2} = '13.61.2.14';
retinotopy_record_crit{2} = 'mouse=13.61.2.14,test=mouse_E7,stim_type=retinotopy';
stimrect{2} = [3*1920/12 1*1080/8 9*1920/12 7*1080/8];
monitorcenter_rel2nose_cm{2} = [ -14,-5,29.5]; % x cm left, y cm up, viewing distance cm
orientation_record_crit{2} = 'mouse=13.61.2.14,test=mouse_E5,stim_type=orientation';
significance_record_crit{2} = 'mouse=13.61.2.14,test=mouse_E5,stim_type=significance';
significance_threshold{2} = 0.05;

mouse{3} = '13.61.2.13';
retinotopy_record_crit{3} = 'mouse=13.61.2.13,test=mouse_E7,stim_type=retinotopy';
stimrect{3} = [2*1920/12 2*1080/8 9*1920/12 8*1080/8];
monitorcenter_rel2nose_cm{3} = [ -14,-5,29.5]; % x cm left, y cm up, viewing distance cm
orientation_record_crit{3} = 'mouse=13.61.2.13,test=mouse_E5,stim_type=orientation';
significance_record_crit{3} = 'mouse=13.61.2.13,test=mouse_E5,stim_type=significance';
significance_threshold{3} = 0.05;

i = 4;
mouse{i} = '13.61.2.07';
retinotopy_record_crit{i} = 'mouse=13.61.2.07,test=mouse_E10,stim_type=retinotopy';
stimrect{i} = [0 0 1440 1080];
% unknown stimrect and monitorcenter!!!
monitorcenter_rel2nose_cm{i} = [ -20,-10,29.5]; % 0.10
 monitorcenter_rel2nose_cm{i} = [ -15,-10,29.5]; % 0.05 
 monitorcenter_rel2nose_cm{i} = [ -10,-10,29.5]; % 0.19
% monitorcenter_rel2nose_cm{i} = [ -5,-10,29.5]; % 0.31
% monitorcenter_rel2nose_cm{i} = [ 0,-10,29.5]; % 0.39
% monitorcenter_rel2nose_cm{i} = [ 5,-10,29.5]; % 0.36
% monitorcenter_rel2nose_cm{i} = [ 10,-10,29.5]; % 0.25
% 
% monitorcenter_rel2nose_cm{i} = [ 0,-20,29.5]; % 0.39
% monitorcenter_rel2nose_cm{i} = [ 0,-15,29.5]; % 0.41
% monitorcenter_rel2nose_cm{i} = [ 0,-10,29.5]; % 0.39
% monitorcenter_rel2nose_cm{i} = [ 0,-5,29.5]; % 0.31
% monitorcenter_rel2nose_cm{i} = [ 0,0,29.5]; % 0.13
% 
% 
% monitorcenter_rel2nose_cm{i} = [ 0,-15,29.5]; % 0.13


crit = 'mouse=13.61.2.07,test=mouse_E4';
crit = 'mouse=13.61.2.07,test=mouse_E5';
orientation_record_crit{i} = [crit ',stim_type=orientation'];
significance_record_crit{i} =  [crit ',stim_type=significance'];
significance_threshold{i} = 1; %0.05;

i=5
mouse{i} = '13.61.2.19';
retinotopy_record_crit{i} = 'mouse=13.61.2.19,test=mouse_E3,stim_type=retinotopy';
stimrect{i} = [0 0 1080 1080];
monitorcenter_rel2nose_cm{i} = [ -14,-5,29.5]; % x cm left, y cm up, viewing distance cm
orientation_record_crit{i} = 'mouse=13.61.2.19,test=mouse_E4,stim_type=orientation';
significance_record_crit{i} = 'mouse=13.61.2.19,test=mouse_E4,stim_type=significance';
significance_threshold{i} = 0.05;




% other mice?
errormsg('Still check out 13.61.2.07, 13.61.2.03');

for i=1:length(retinotopy_record_crit)
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
        errormsg('Could not find orientation');
    end
    [orientation_record,avg] = analyse_testrecord( orientation_record);
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
    
    logmsg('WORKING ON CC. DOES NOT SHOW THE RIGHT ANSWER YET');
    
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
    image(repmat(double(signif_between_groups'<significance_threshold{i}),[1 1 3]))
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
end

%oi_compute_response_centers(avg, record)