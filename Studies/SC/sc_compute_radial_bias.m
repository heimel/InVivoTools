%SC_COMPUTE_RADIAL_BIAS 

[db,filename] = load_expdatabase( 'testdb_jander');

retinotopy_record_crit = {'mouse=13.61.2.12,test=mouse_E11'};
orientation_record_crit = {'mouse=13.61.2.12,test=mouse_E12,stim_type=orientation'};


for i=1:length(retinotopy_record_crit)
    retinotopy_record = db(find_record(db,retinotopy_record_crit{i}));
    
    [retinotopy_record,avg] = analyse_testrecord( retinotopy_record);
    [img_rf_radial_angle_deg,img_rf_azimuth_rad,img_rf_elevation_rad] = oi_compute_response_centers(avg, record);
    
    orientation_record = db(find_record(db,orientation_record_crit{i}));
    [orientation_record,avg] = analyse_testrecord( orientation_record);
           
    multfac = 2; % 
    polavg = zeros(size(avg,1),size(avg,2));
    for c=1:size(avg,3)
        polavg = polavg + avg(:,:,c) * exp(multfac*pi*1i*orientation_record.stim_parameters(c)/180);
    end
    img_orientation = angle(polavg); 
    
    img_orientation(isnan(img_rf_radial_angle_deg)) = nan;
    
    figure;
    subplot(1,2,1);

    imagesc(mod(img_rf_radial_angle_deg,180)')
    axis image off
    %axis([90 140 70 120])
    title('Radial angle map');
    colorbar
    subplot(1,2,2);
    imagesc(img_orientation')
    axis image off
    %   axis([90 140 70 120])
    title('Orientation map');
    colormap hsv
end

%oi_compute_response_centers(avg, record)