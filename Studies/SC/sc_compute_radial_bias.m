%SC_COMPUTE_RADIAL_BIAS 

[db,filename] = load_expdatabase( 'testdb_jander');

retinotopy_record_crit = {'mouse=13.61.2.12,test=mouse_E11'};
orientation_record_crit = {'mouse=13.61.2.12,test=mouse_E12,stim_type=orientation'};
significance_record_crit = {'mouse=13.61.2.12,test=mouse_E12,stim_type=significance'};


for i=1:length(retinotopy_record_crit)
    % retinotopy and radial map
    retinotopy_record = db(find_record(db,retinotopy_record_crit{i}));
    [retinotopy_record,avg] = analyse_testrecord( retinotopy_record);
    [img_rf_radial_angle_deg,img_rf_azimuth_deg,img_rf_elevation_deg] = oi_compute_response_centers(avg, retinotopy_record);
    img_rf_radial_angle_deg = mod(img_rf_radial_angle_deg,180);
    
    % orientation map
    orientation_record = db(find_record(db,orientation_record_crit{i}));
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
    
    fname = fullfile(oidatapath(record),[record.test '_significance.mat']);
    if exist(fname,'file')
        load(fname);
    else
        [significance_record,avg] = analyse_testrecord( significance_record);
    end
    
    %,'signif_between_groups','signif_response','comp_conds');
    
    
    
    
    ylimits = [max(1,find(~isnan(nanmean(img_rf_radial_angle_deg,1)),1,'first')-5) ...
        min(size(img_rf_radial_angle_deg,2),find(~isnan(nanmean(img_rf_radial_angle_deg,1)),1,'last')+5)] ;
    
    xlimits = [max(1,find(~isnan(nanmean(img_rf_radial_angle_deg,2)),1,'first')-5) ...
        min(size(img_rf_radial_angle_deg,1),find(~isnan(nanmean(img_rf_radial_angle_deg,2)),1,'last')+5)];
    
    figure
    
    subplot(2,3,1);
    imagesc(img_rf_azimuth_deg')
    axis image off
    ylim(ylimits);
    xlim(xlimits);
    title('Azimuth map');
    set(get(gca,'children'),'Alphadata',~isnan(img_rf_azimuth_deg'))
    colorbar

    subplot(2,3,2);
    imagesc(img_rf_elevation_deg')
    axis image off
    ylim(ylimits);
    xlim(xlimits);
    title('Elevation map');
    set(get(gca,'children'),'Alphadata',~isnan(img_rf_azimuth_deg'))
    colorbar


        subplot(2,3,3);

    image(repmat(double(signif_between_groups'<0.01),[1 1 3]))
    axis image off
    ylim(ylimits);
    xlim(xlimits);
    set(get(gca,'children'),'Alphadata',~isnan(img_rf_azimuth_deg'))
    title('Significant orientation preference');
    h = colorbar;
    set(h,'visible','off');

    mask = ~isnan(img_rf_azimuth_deg') & (signif_between_groups'<0.01);
    
    subplot(2,3,4);
    imagesc(img_rf_radial_angle_deg')
    axis image off
    ylim(ylimits);
    xlim(xlimits);
    title('Radial angle map');
    set(get(gca,'children'),'Alphadata',mask)
    h = colorbar;
    set(h,'ytick',[0.5 45 90 135 179.5]);
    set(h,'yticklabel',{'0','45','90','135','180'})

    subplot(2,3,5);
    imagesc(img_orientation')
    axis image off
    ylim(ylimits);
    xlim(xlimits);
    title('Orientation map');
    colormap hsv
    set(get(gca,'children'),'Alphadata',mask)
    h = colorbar;
    set(h,'ytick',[0.5 45 90 135 179.5]);
    set(h,'yticklabel',{'0','45','90','135','180'})


end

%oi_compute_response_centers(avg, record)