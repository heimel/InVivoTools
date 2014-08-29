function [radial_angle_all,orientation_all] = sc_compute_radial_bias
%SC_COMPUTE_RADIAL_BIAS
%
% 2014, Alexander Heimel

disp('monitor center wrt nose for 2014-08-22 = [-17,-2,30]' );
disp('monitor tilt = 0, monitor_slant = 20' );
disp('mouse tilt is 8 deg, left eye lower, (right hemisphere)' );
%errormsg('Recalculate with tilted monitor');

disp('Recalculate retinotopies first');

recalculate = false;
verbose = false;

db = load_expdatabase( 'testdb_jander');

xv = cell(10,1); % for hull
yv = cell(10,1); % for hull

i = 1;
mouse{i} = '13.61.2.03';
retinotopy_record_crit{i} = 'mouse=13.61.2.03,test=mouse_E11,stim_type=retinotopy';
retinotopy_record{i} = db(find_record(db,retinotopy_record_crit{i}));
monitorpatch_x = [ 5  5  5  4   4];
monitorpatch_y = [ 3  4  2  3   4];
x =              [63 55  71 60  54 ];
y =              [54 48  60 58  53 ];
override_response_centers( retinotopy_record{i}, monitorpatch_x, monitorpatch_y, x, y, verbose)
stimrect{i} = [0 0 1080 1080];
monitorcenter_rel2nose_cm{i} = [ 00,25,29.5]; %
monitorcenter_rel2nose_cm{i} = [ -5,-5,15]; %
monitor_tilt_deg{i} = 30; % deg
monitor_slant_deg{i} = 20;% deg
orientation_record_crit{i} = 'mouse=13.61.2.03,test=mouse_E10,stim_type=orientation';
significance_record_crit{i} = 'mouse=13.61.2.03,test=mouse_E10,stim_type=significance';
significance_threshold{i} = 1; %0.05;
i = i + 1;



mouse{i} = '13.61.2.07';
retinotopy_record_crit{i} = 'mouse=13.61.2.07,test=mouse_E10,stim_type=retinotopy';
retinotopy_record{i} = db(find_record(db,retinotopy_record_crit{i}));
if recalculate
    [monitorpatch_x,monitorpatch_y,x,y] = getgridcoordinates(retinotopy_record{i});
end
monitorpatch_x = [1 2 3 4 5 1 2 3 4 5 1 2 3 4 5 1 2 3 4 5];
monitorpatch_y = [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4];
x = [34.8 42.1 51.2 57.8 61.3 32.4 37.4 44.1 56.5 61.6 28.3 31.2 38.7 48.7 54.9 25.8 27.9 31.7 38.3 56.1];
y = [68.7 71.8 74.5 74.6 74.6 62.8 64 64.4 66.8 68 56 52.7 49 44.6 42.1 48.8 46.1 42.6 39.3 40.7];
override_response_centers( retinotopy_record{i}, monitorpatch_x, monitorpatch_y, x, y, verbose)
stimrect{i} = [0 0 1200 800];
monitorcenter_rel2nose_cm{i} = [ -20,-10,29.5];
monitorcenter_rel2nose_cm{i} = [ -10,-15,30];
monitorcenter_rel2nose_cm{i} = [-17,-15,30]; %
monitor_tilt_deg{i} = 0; % deg
monitor_slant_deg{i} = 20;% deg
disp('Two tests, we could combine them');
crit = 'mouse=13.61.2.07,test=mouse_E4';
%crit = 'mouse=13.61.2.07,test=mouse_E5';
orientation_record_crit{i} = [crit ',stim_type=orientation'];
significance_record_crit{i} =  [crit ',stim_type=significance'];
significance_threshold{i} =0.01; %0.05;
i = i + 1;


mouse{i} = '13.61.2.12';
retinotopy_record_crit{i} = 'mouse=13.61.2.12,test=mouse_E11,stim_type=retinotopy';
retinotopy_record{i} = db(find_record(db,retinotopy_record_crit{i}));

stimrect{i} = [320 270 1600 945];
monitorpatch_x = [3 4 5 6 7 1 2 3 4 5 6 7  2 3 4 5 6 7 1 2 3 4 5 6 3 4 5];
monitorpatch_y = [1 1 1 1 1 2 2 2 2 2 2 2  3 3 3 3 3 3 4 4 4 4 4 4 5 5 5];
x = [113 119 125 131 134 101 105 109 115 123 130 136  103 106 110 117 125 131 97.4 99.5 103 108 113 117 101 104 110];
y = [104 103 101 99.9 103 96.5 96.4 96.2 95.4 95.7 94.7 93.8 93.3 92.4 91 91.5 92.1 90 87.7 87.3 87.4 86 87.1 81.5 79.9 77.2 75.1];
if recalculate || 1
    override_response_centers( retinotopy_record{i}, monitorpatch_x, monitorpatch_y, x, y, verbose )
end
% hull = [19 6 1 5 12 18 17 16 24 27 19];
% xv{i} = y(hull);
% yv{i} = x(hull);
monitorcenter_rel2nose_cm{i} = [ -5,0,15]; %
monitorcenter_rel2nose_cm{i}=[-15,-5,30] % 0.80
monitorcenter_rel2nose_cm{i}=[-14,-5,30]; % 0.81
monitorcenter_rel2nose_cm{i}=[-13,-5,30]; % 0.82
monitorcenter_rel2nose_cm{i}=[-12,-5,30]; % 0.82
monitorcenter_rel2nose_cm{i}=[-12,-6,30]; % 0.84
monitorcenter_rel2nose_cm{i}=[-12,-7,30]; % 0.85
monitorcenter_rel2nose_cm{i}=[-12,-8,30]; % 0.86
monitorcenter_rel2nose_cm{i}=[-10,0,30]; % 0.86
monitor_tilt_deg{i} = -30; % deg  % best estimate to fit data. Forgot to measure for mouse
monitor_slant_deg{i} = 20;% deg
orientation_record_crit{i} = 'mouse=13.61.2.12,test=mouse_E12,stim_type=orientation';
significance_record_crit{i} = 'mouse=13.61.2.12,test=mouse_E12,stim_type=significance';
significance_threshold{i} = 0.1;
i = i + 1;

mouse{i} = '13.61.2.13';
retinotopy_record_crit{i} = 'mouse=13.61.2.13,test=mouse_E7,stim_type=retinotopy';
stimrect{i} = [2*1920/12 2*1080/8 9*1920/12 8*1080/8];
monitorcenter_rel2nose_cm{i} = [ -10,-10,30]; % x cm left, y cm up, viewing distance cm
monitorcenter_rel2nose_cm{i} = [ -5,-5,15]; %
monitor_tilt_deg{i} = 0; % deg
monitor_slant_deg{i} = 20;% deg
orientation_record_crit{i} = 'mouse=13.61.2.13,test=mouse_E5,stim_type=orientation';
significance_record_crit{i} = 'mouse=13.61.2.13,test=mouse_E5,stim_type=significance';
significance_threshold{i} = 1; % 0.05;
i = i + 1;

mouse{i} = '13.61.2.14';
retinotopy_record_crit{i} = 'mouse=13.61.2.14,test=mouse_E7,stim_type=retinotopy';
stimrect{i} = [3*1920/12 1*1080/8 9*1920/12 7*1080/8];
monitor_tilt_deg{i} = 0; % deg
monitor_slant_deg{i} = 20;% deg
monitorcenter_rel2nose_cm{i} = [ -14,-5,30]; % x cm left, y cm up, viewing distance cm
monitorcenter_rel2nose_cm{i} = [ -5,-5,20]; %
orientation_record_crit{i} = 'mouse=13.61.2.14,test=mouse_E5,stim_type=orientation';
significance_record_crit{i} = 'mouse=13.61.2.14,test=mouse_E5,stim_type=significance';
significance_threshold{i} =1;


mouse{i} = '13.61.2.19';
retinotopy_record_crit{i} = 'mouse=13.61.2.19,test=mouse_E3,stim_type=retinotopy';
stimrect{i} = [0 0 1000 800];
retinotopy_record{i} = db(find_record(db,retinotopy_record_crit{i}));
monitorpatch_x = [  1  2   3  1  2   3   1  2   3];
monitorpatch_y = [  1  1   1  2  2   2   3  3   3];
x =              [nan 90 105 80 90 105 nan 90 105];
y =              [nan 55  60 40 42  50 nan 35  40];
if recalculate || 1
    override_response_centers( retinotopy_record{i}, monitorpatch_x, monitorpatch_y, x, y , verbose)
end
monitorcenter_rel2nose_cm{i} = [ -20,-8,29.5]; %
monitorcenter_rel2nose_cm{i} = [ -5,-5,15]; %
monitorcenter_rel2nose_cm{i} = [-17,-5,30];
monitor_tilt_deg{i} = 0; % deg
monitor_slant_deg{i} = 20;% deg
orientation_record_crit{i} = 'mouse=13.61.2.19,test=mouse_E4,stim_type=orientation';
significance_record_crit{i} = 'mouse=13.61.2.19,test=mouse_E4,stim_type=significance';
significance_threshold{i} = 1;%0.1;
i = i + 1;



mouse{i} = '13.61.2.20';
retinotopy_record_crit{i} = 'mouse=13.61.2.20,test=mouse_E1,stim_type=retinotopy';
retinotopy_record{i} = db(find_record(db,retinotopy_record_crit{i}));
filename = fullfile(oidatapath(retinotopy_record{i}),[retinotopy_record{i}.test '_response_centers.mat']);
load(filename);
monitorpatch_x = [ 1 2 1 2  ];
monitorpatch_y = [ 1 1 2 2 ];
x =          [103  107   98  104 ];
y =              [66 65 56 56 ];
override_response_centers( retinotopy_record{i}, monitorpatch_x, monitorpatch_y, x, y , verbose)
stimrect{i} = [0 0 1920 1080];
monitorcenter_rel2nose_cm{i} = [ -20,0,15]; %
monitor_tilt_deg{i} = 0; % deg
monitor_slant_deg{i} = 20;% deg
orientation_record_crit{i} = 'mouse=13.61.2.20,test=mouse_E6,stim_type=orientation';
i = i + 1;

mouse{i} = '13.61.2.21';
retinotopy_record_crit{i} = 'mouse=13.61.2.21,test=mouse_E5,stim_type=retinotopy';
retinotopy_record{i} = db(find_record(db,retinotopy_record_crit{i}));
stimrect{i} = [480 270 1280 810];
monitorcenter_rel2nose_cm{i} = [-17,3,30]; %
monitor_tilt_deg{i} = 0; % deg
monitor_slant_deg{i} = 20;% deg
orientation_record_crit{i} = 'mouse=13.61.2.21,test=mouse_E6,stim_type=orientation';
i = i + 1;



mice = 1:length(mouse);
n_mice = length(mice);


radial_angle_all = [];
orientation_all = [];


azimuth_lim = [-80 20];
elevation_lim = [-40 40];
for i=mice % :length(retinotopy_record_crit)
    % retinotopy and radial map
    retinotopy_record{i} = db(find_record(db,retinotopy_record_crit{i}));
    if isempty(retinotopy_record{i})
        errormsg('Could not find retinotopy');
    end
    
    retinotopy_record{i}.stimrect = stimrect{i};
    retinotopy_record{i}.monitorcenter_rel2nose_cm = monitorcenter_rel2nose_cm{i};
    retinotopy_record{i}.monitor_tilt_deg = monitor_tilt_deg{i};
    retinotopy_record{i}.monitor_slant_deg = monitor_slant_deg{i};
    filename = fullfile(oidatapath(retinotopy_record{i}),[retinotopy_record{i}.test '_avg.mat']);
    if exist(filename,'file')
        load(filename);
    else
        [retinotopy_record{i},avg] = analyse_testrecord( retinotopy_record{i});
        save(filename,'avg');
    end
    
    [img_rf_radial_angle_deg{i},img_rf_azimuth_deg{i},img_rf_elevation_deg{i}] = ...
        oi_compute_response_centers(avg, retinotopy_record{i},recalculate);
    
    
    % ipsi hemifield set to 0
    img_rf_radial_angle_deg{i}(img_rf_radial_angle_deg{i}>0 & img_rf_radial_angle_deg{i}<180) = 0;
    
    % blurring
    if 1
        img_radial =exp(2i*img_rf_radial_angle_deg{i}/180*pi);
        img_radial(isnan(img_radial)) = 0;
        img_radial = spatialfilter(img_radial,6,'pixel');
        img_radial = angle(img_radial)/pi*180/2;
        img_radial(isnan(img_rf_radial_angle_deg{i})) = nan;
    else
        img_radial =img_rf_radial_angle_deg{i};
    end
    
    
    img_rf_radial_angle_deg{i} = mod(img_radial,180);
    %    img_rf_radial_angle_deg{i} = mod(img_rf_radial_angle_deg{i},180);
    
    % orientation map
    orientation_record = db(find_record(db,orientation_record_crit{i}));
    if isempty(orientation_record)
        errormsg(['Could not find record matching ' orientation_record_crit{i}] );
        return
    end
    if length(orientation_record)>1
        errormsg(['More than one record matching ' orientation_record_crit{i}] );
        return
    end        
    filename = fullfile(oidatapath(orientation_record),[orientation_record.test '_avg.mat']);
    if exist(filename,'file')
        load(filename);
    else
        [orientation_record,avg] = analyse_testrecord( orientation_record);
        save(filename,'avg');
    end
    
    %     orientation_record.stim_parameters = [45 0 90 135 225 180 270 315];
    %     orientation_record.stim_parameters = rand(1,8)*360
    
    multfac = 2; %
    %     avg(:,:,1) = avg(:,:,2)*1.04;
    %     avg(:,:,2) = avg(:,:,2)*0.95;
    %     avg(:,:,3) = avg(:,:,3)*0.93;
    
    polavg = zeros(size(avg,1),size(avg,2));
    for c=1:size(avg,3)
        polavg = polavg + avg(:,:,c) * exp(multfac*pi*1i*orientation_record.stim_parameters(c)/180);
    end
    img_orientation{i} = angle(polavg);
    img_orientation{i} = mod(img_orientation{i}/pi*180,360)/2;
    img_orientation{i}(isnan(img_rf_radial_angle_deg{i})) = nan;
    
    if 0
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
    end
    
    mask{i} = ~isnan(img_rf_azimuth_deg{i}) ;
    %mask = ~isnan(img_rf_azimuth_deg) & (signif_between_groups<significance_threshold{i});
    
    if ~isempty(xv{i})
        [mx,my]=meshgrid(1:size(mask{i},2),1:size(mask{i},1));
        in=inpolygon(mx,my,yv{i},xv{1});
        mask{i} = mask{i} & in;
    end
    
    radial_angle_all = [radial_angle_all ; img_rf_radial_angle_deg{i}(mask{i})]; %#ok<AGROW>
    orientation_all = [orientation_all; img_orientation{i}(mask{i})]; %#ok<AGROW>
    
    ccc = circ_corrcc(2* img_rf_radial_angle_deg{i}(mask{i})/180*pi,2* img_orientation{i}(mask{i})/180*pi);
    logmsg(['Mouse ' mouse{i} ' circ. corrcoeff radial and orientation map (all) = ' num2str(ccc)]);
    
    if 0
        mask{i} = ~isnan(img_rf_azimuth_deg{i}) & (signif_between_groups<significance_threshold{i});
        if ~any(mask{i}(:))
            mask{i} =  ~isnan(img_rf_azimuth_deg{i});
            logmsg('No significant pixels. Setting threshold to inf.');
            significance_threshold{i} = inf;
        end
        ccc = circ_corrcc( 2*img_rf_radial_angle_deg{i}(mask{i})/180*pi,2*img_orientation{i}(mask{i})/180*pi);
        logmsg(['Mouse ' mouse{i} ' circ. corrcoeff radial and orientation map (sign) = ' num2str(ccc)]);
    end
end


row = 1;
n_cols = 6;
n_rows = n_mice + 1;
figure('Name','All maps');
for i = mice
    colormap hsv
    colormap(periodic_colormap(64))
    
    
    ylimits = [max(1,find(~isnan(nanmean(img_rf_radial_angle_deg{i},1)),1,'first')-5) ...
        min(size(img_rf_radial_angle_deg{i},2),find(~isnan(nanmean(img_rf_radial_angle_deg{i},1)),1,'last')+5)] ;
    
    xlimits = [max(1,find(~isnan(nanmean(img_rf_radial_angle_deg{i},2)),1,'first')-5) ...
        min(size(img_rf_radial_angle_deg{i},1),find(~isnan(nanmean(img_rf_radial_angle_deg{i},2)),1,'last')+5)];
    
    ycenter = mean(ylimits);
    xcenter = mean(xlimits);
    xlimits = [-20 20]+xcenter;
    ylimits = [-20 20]+ycenter;
    
    col = 1;
    subplot(n_rows,n_cols,(row-1)*n_cols+col);
    get(gca,'Position')
    image(imread(fullfile(oidatapath(retinotopy_record{i}),'analysis',retinotopy_record{i}.imagefile)));
    set(gca,'clim',azimuth_lim)
    axis image off
    ylim(ylimits);
    xlim(xlimits);
    set(get(gca,'children'),'Alphadata',0.5+0.5*double(~isnan(img_rf_azimuth_deg{i}')))
    col = col + 1;
    
    subplot(n_rows,n_cols,(row-1)*n_cols+col);
    imagesc(img_rf_azimuth_deg{i}')
    set(gca,'clim',azimuth_lim)
    axis image off
    ylim(ylimits);
    xlim(xlimits);
    %    title('Azimuth map');
    set(get(gca,'children'),'Alphadata',~isnan(img_rf_azimuth_deg{i}'))
    %     if i==n_mice
    %         colorbar('SouthOutside');
    %     end
    col = col + 1;
    
    subplot(n_rows,n_cols,(row-1)*n_cols+col);
    imagesc(img_rf_elevation_deg{i}')
    set(gca,'clim',elevation_lim)
    axis image off
    ylim(ylimits);
    xlim(xlimits);
    set(get(gca,'children'),'Alphadata',~isnan(img_rf_azimuth_deg{i}'))
    col = col + 1;
    
    subplot(n_rows,n_cols,(row-1)*n_cols+col);
    imagesc(img_rf_radial_angle_deg{i}')
    set(gca,'clim',[0 180])
    axis image off
    ylim(ylimits);
    xlim(xlimits);
    %   title('Radial angle map');
    set(get(gca,'children'),'Alphadata',mask{i}')
    col = col + 1;
    
    subplot(n_rows,n_cols,(row-1)*n_cols+col);
    imagesc(img_orientation{i}')
    set(gca,'clim',[0 180])
    axis image off
    ylim(ylimits);
    xlim(xlimits);
    set(get(gca,'children'),'Alphadata',mask{i}')
    col = col + 1;
    
    subplot(n_rows,n_cols,(row-1)*n_cols+col);
    plot(flatten(img_rf_radial_angle_deg{i}(mask{i})),...
        flatten(img_orientation{i}(mask{i})),'.k')
    axis([0 180 0 180])
    axis square
    %  xlabel('Radial angle (deg)');
    %  ylabel('Orientation (deg)');
    box off
    xyline
    
    row = row+1;
end

%subplot('position',[0.14 0.05 0.07 0.05]);
col = 2;
subplot(n_rows,n_cols,(row-1)*n_cols+col);
imagesc(azimuth_lim(1):azimuth_lim(2),1,linspace(azimuth_lim(1),azimuth_lim(2),100));
colormap hsv
set(gca,'ytick',[]);
title('Azimuth')
col = col + 1;

%subplot('position',[0.29 0.05 0.07 0.05]);
subplot(n_rows,n_cols,(row-1)*n_cols+col);
imagesc(elevation_lim(1):elevation_lim(2),1,linspace(elevation_lim(1),elevation_lim(2),100));colormap hsv
set(gca,'ytick',[]);
title('Elevation')
col = col + 1;

%subplot('position',[0.50 0.05 0.07 0.05]);
subplot(n_rows,n_cols,(row-1)*n_cols+col);
imagesc(0:180,1,linspace(0,180,100));colormap hsv
set(gca,'ytick',[]);
title('Radial angle')
col = col + 1;

% subplot('position',[0.65 0.05 0.07 0.05]);
subplot(n_rows,n_cols,(row-1)*n_cols+col);
imagesc(0:180,1,linspace(0,180,100));colormap hsv
set(gca,'ytick',[]);
title('Orientation angle')
col = col + 1;


figure('name','All mice');
subplot(1,2,1)
hold on
plot(radial_angle_all,orientation_all,'.k')
plot(radial_angle_all-180,orientation_all,'.k')
plot(radial_angle_all+180,orientation_all,'.k')
axis equal
axis([-90 200 0 180])
xlabel('Radial angle (deg)');
ylabel('Orientation (deg)');
box off
xyline('-r');

ind = find(radial_angle_all~=0 & radial_angle_all~=180);

dor = orientation_all-radial_angle_all;
logmsg(['Difference of orientation and radial angle = ' num2str(mean(dor)) ' +- ' num2str(std(dor)) ' deg']);
logmsg(['Difference of orientation and radial angle (pos ang) = ' num2str(mean(dor(ind))) ' +- ' num2str(std(dor(ind))) ' deg']);

[r,p] = circ_corrcc(radial_angle_all/180*pi*2,orientation_all/180*pi*2);

logmsg(['Circ. corrcc = ' num2str(r) ', p = ' num2str(p)]);

[r,p] = circ_corrcc(radial_angle_all(ind)/180*pi*2,orientation_all(ind)/180*pi*2);
logmsg(['Circ. corrcc (positive angles) = ' num2str(r) ', p = ' num2str(p)]);

[r,p] = circ_corrcc(radial_angle_all(ind)/180*pi,orientation_all(ind)/180*pi);
logmsg(['Circ. corrcc (positive angles) = ' num2str(r) ', p = ' num2str(p)]);

save(fullfile(getdesktopfolder,'orientation_radial.mat'),'radial_angle_all','orientation_all');

angle_diffs = angle(exp(1i*(radial_angle_all-orientation_all)/180*pi));
angle_diffs(angle_diffs>pi/2) = angle_diffs(angle_diffs>pi/2)-pi;
angle_diffs(angle_diffs<-pi/2) = angle_diffs(angle_diffs<-pi/2)+pi;
%angle_diffs(angle_diffs>pi/2) = angle_diffs(angle_diffs>pi/2)-pi;
subplot(1,2,2)
hist(angle_diffs/pi*180,30)
xlabel('Angular difference (deg)');
ylabel('n pixels');
axis square



function override_response_centers( retinotopy_record, monitorpatch_x, monitorpatch_y, x, y,verbose )
if nargin<6
    verbose = true;
end

filename = fullfile(oidatapath(retinotopy_record),[retinotopy_record.test '_response_centers.mat']);
cx = x;
cy = y;
ind = ~isnan(x);
monitorpatch_x = monitorpatch_x(ind);
monitorpatch_y = monitorpatch_y(ind);
x = x(ind);
y = y(ind);
save(filename,'monitorpatch_x','monitorpatch_y','x','y','cx','cy');

if verbose
    
    figure('name',subst_ctlchars([retinotopy_record.mouse '-' retinotopy_record.test ': Grid']));
    subplot(1,2,1)
    image(imread(fullfile(oidatapath(retinotopy_record),'analysis',retinotopy_record.imagefile)));
    axis image
    hold on
    for i=1:length(x);
        text(y(i),x(i),[ num2str(monitorpatch_x(i)) ',' num2str(monitorpatch_y(i))],'color',[1 1 1],'horizontalalignment','center');
    end
    
    subplot(1,2,2)
    show_retinotopy_colors(retinotopy_record);
    
   
    show_single_condition_maps(retinotopy_record);
    n_x = retinotopy_record.stim_parameters(1);
    n_y = retinotopy_record.stim_parameters(2);
    
    h= get(gcf,'userdata');
    for i=1:length(x)
        axes(h.single_condition( (monitorpatch_y(i)-1)*n_x + monitorpatch_x(i)));
        hold on
        plot(y(i),x(i),'+r');
    end
    
end




function [monitorpatch_x,monitorpatch_y,x,y] = getgridcoordinates(retinotopy_record) %#ok<STOUT,REDEF>
retinotopy_record = analyse_testrecord( retinotopy_record);
filename = fullfile(oidatapath(retinotopy_record),[retinotopy_record.test '_response_centers.mat']);
load(filename);
disp(['monitorpatch_x = ' mat2str(monitorpatch_x) ';']);
disp(['monitorpatch_y = ' mat2str(monitorpatch_y) ';']);
disp(['x = ' mat2str(x) ';']);
disp(['y = ' mat2str(y) ';']);
