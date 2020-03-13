function record = wc_compute_overheadstim_angles( record, verbose)
%COMPUTE_OVERHEADSTIM_ANGLES computes elevation and azimuth of a stimulus relative to mouse
%
%  RECORD = COMPUTE_OVERHEADSTIM_ANGLES( RECORD, VERBOSE)
%
%     RECORD.MEASURES.AZIMUTH is horizontal angles in radii, in front of animal is 0, left
%     of animal is -pi/2
%
%    RECORD.MEASURES.ELEVATION is altitude angle in radii. Above mouse is pi/2
%
% 2018-2020, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = true;
end

params = wcprocessparams(record);

% get stimulus extent
stimsfile = getstimsfile(record);

stimparams = getparameters(stimsfile.saveScript);
if ~isfield(stimparams,'extent_deg')
   logmsg('Not an flyover stimulus');
   return
end

if ~isfield(record.measures,'arena')
    logmsg(['Arena missing in ' recordfilter(record)]);
    return
end

stim_extent_deg = stimparams.extent_deg;
% correction because screen height was wrongly set on stimulus computer
if length(stim_extent_deg)==1 % i.e. disk
    stim_extent_deg(2) = stim_extent_deg(1);
end

stim_extent_deg = stimsfile.NewStimViewingDistance / params.wc_screen_distance_cm * stim_extent_deg;
stim_extent_cm = 2*params.wc_screen_distance_cm*tan(stim_extent_deg/180*pi/2);

nose_pxl = record.measures.nose_trajectory;
arse_pxl = record.measures.arse_trajectory;
stim_pxl = record.measures.stim_trajectory;


movmedsamples = 10;
nose_pxl = movmedian(nose_pxl,movmedsamples,'omitnan');
arse_pxl = movmedian(arse_pxl,movmedsamples,'omitnan');


camera_width = record.measures.framesize(2); % pxl
camera_height = record.measures.framesize(1); % pxl

floor_pxl_per_cm = camera_width / params.wc_cagefloor_width_cm ; % assume floor spans screen
monitor_pxl_per_cm = record.measures.arena(3) / params.wc_screenwidth_cm;     % 350 pixels


% nose_pxl = [n x 2], n rows of x,y coordinates of nose in camera pixels
% arse_pxl = [n x 2], n rows of x,y coordinates of arse in camera pixels
% stim_pxl = [n x 2], n rows of x,y coordinates of stim center in camera pixels

% switch to center camera coordinates (necessary to do before scaling to cm)
nose_pxl(:,1) = nose_pxl(:,1) - camera_width/2;
nose_pxl(:,2) = nose_pxl(:,2) - camera_height/2;
arse_pxl(:,1) = arse_pxl(:,1) - camera_width/2;
arse_pxl(:,2) = arse_pxl(:,2) - camera_height/2;
stim_pxl(:,1) = stim_pxl(:,1) - camera_width/2;
stim_pxl(:,2) = stim_pxl(:,2) - camera_height/2;


% switch to (uncorrected) centimeters (full widths of floor and monitor)
nose_cm = nose_pxl / floor_pxl_per_cm;
arse_cm = arse_pxl / floor_pxl_per_cm;
stim_cm = stim_pxl / monitor_pxl_per_cm;

% transform pxls to cm by reverse fisheye transform
if 0
    nose_cm = reverse_fisheye(nose_cm,fishparams_floor); %#ok<UNRCH>
    arse_cm = reverse_fisheye(arse_cm,fishparams_floor);
    stim_cm = reverse_fisheye(stim_cm,fishparams_ceiling);
else
    warning('COMPUTER_OVERHEADSTIM_ANGLES:NOFISHEYE','No fish eye undistortion performed');
    warning('off','COMPUTER_OVERHEADSTIM_ANGLES:NOFISHEYE');
end

% make the nose center
arse_cm_nose_centered = arse_cm - nose_cm;
stim_cm_nose_centered = stim_cm - nose_cm;
stim_direction_cm_per_s = diff(stim_cm)*record.measures.framerate;
stim_direction_cm_per_s(end+1,:) = stim_direction_cm_per_s(end,:);
stim_x_axis_cm = stim_direction_cm_per_s./repmat(sqrt(sum(stim_direction_cm_per_s .* stim_direction_cm_per_s,2)),1,2);
stim_y_axis_cm = [-stim_x_axis_cm(:,2) stim_x_axis_cm(:,1)];

stim_x_axis_cm = stim_x_axis_cm * stim_extent_cm(1);
stim_y_axis_cm = stim_y_axis_cm * stim_extent_cm(2);

% logmsg('RANDOMIZING DATA' );
% arse_cm_nose_centered = -10 + 20*rand(size(arse_cm_nose_centered));
% stim_cm_nose_centered = -10 + 20*rand(size(arse_cm_nose_centered));
% stim_cm_nose_centered = 10*arse_cm_nose_centered;

%phi = cart2pol(arse_cm_nose_centered(:,1),arse_cm_nose_centered(:,2));
phi = cart2pol(arse_cm_nose_centered(:,1),arse_cm_nose_centered(:,2));
phi = pi - phi;


%  logmsg('DEBUGGING');
%  phi = zeros(size(phi));
% phi = 2*pi*rand(size(phi));

stim_nose_centered_rotated_cm = NaN(length(phi),2);
stim_direction_rotated_cm_per_s = NaN(length(phi),2);
stim_x_axis_rotated_cm = NaN(length(phi),2);
stim_y_axis_rotated_cm = NaN(length(phi),2);
for i=1:length(phi)
    stim_nose_centered_rotated_cm(i,:) = ...
        [cos(-phi(i)) sin(-phi(i));
        -sin(-phi(i)) cos(-phi(i))] * stim_cm_nose_centered(i,:)';
    
    stim_direction_rotated_cm_per_s(i,:) = ...
        [cos(-phi(i)) sin(-phi(i));
        -sin(-phi(i)) cos(-phi(i))] * stim_direction_cm_per_s(i,:)';
    
    stim_x_axis_rotated_cm(i,:) = ...
        [cos(-phi(i)) sin(-phi(i));
        -sin(-phi(i)) cos(-phi(i))] * stim_x_axis_cm(i,:)';

    stim_y_axis_rotated_cm(i,:) = ...
        [cos(-phi(i)) sin(-phi(i));
        -sin(-phi(i)) cos(-phi(i))] * stim_y_axis_cm(i,:)';

end



stim_nose_centered_rotated_cm(:,3) = params.wc_screen_distance_cm;


%logmsg('debugging')
%stim_nose_centered_rotated_cm(:,1) = stim_nose_centered_rotated_cm(end:-1:1,1);
%stim_nose_centered_rotated_cm(:,1) = stim_nose_centered_rotated_cm(:,1) -100;


[azimuth,elevation,~] = cart2sph(...
    stim_nose_centered_rotated_cm(:,1),...
    stim_nose_centered_rotated_cm(:,2),...
    stim_nose_centered_rotated_cm(:,3));



record.measures.azimuth_trajectory = azimuth;
record.measures.elevation_trajectory = elevation;

record.measures.stim_nose_centered_rotated_cm =  stim_nose_centered_rotated_cm;
record.measures.stim_direction_rotated_cm_per_s = stim_direction_rotated_cm_per_s;
record.measures.stim_x_axis_rotated_cm = stim_x_axis_rotated_cm;
record.measures.stim_y_axis_rotated_cm = stim_y_axis_rotated_cm;

if 0 && verbose
    figure('Name','Tracks','NumberTitle','off');
    % movements in camera centered coordinates
    subplot(2,2,1)
    hold on;
    set(gca,'ydir','reverse')
    plot(stim_pxl(:,1),stim_pxl(:,2));
    axis image
    axis([-320 320 -240 240]);
    ind = find(~isnan(stim_pxl(:,1)));
    %cmap = parula(length(ind));
    cmap = jet(length(ind));
    for i=1:length(ind)
        plot( [nose_pxl(ind(i),1) arse_pxl(ind(i),1)],...
            [nose_pxl(ind(i),2) arse_pxl(ind(i),2)],'color',cmap(i,:));
        plot( [nose_pxl(ind(i),1) nose_pxl(ind(i),1)],...
            [nose_pxl(ind(i),2) nose_pxl(ind(i),2)],'*','color',cmap(i,:));
        plot([stim_pxl(ind(i),1) stim_pxl(ind(i)+1,1)],...
            [stim_pxl(ind(i),2) stim_pxl(ind(i)+1,2)],'color',cmap(i,:));
    end
    text(stim_pxl(ind(1),1),stim_pxl(ind(1),2),'B','horizontalalignment','Center')
    text(stim_pxl(ind(end),1),stim_pxl(ind(end),2),'E','horizontalalignment','Center')
    
    
    subplot(2,2,2)
    hold on;
    set(gca,'ydir','reverse')
    plot(stim_cm(:,1),stim_cm(:,2));
    axis image
    xlim([-0.5 0.5]*params.wc_cagefloor_width_cm);
    ylim([-0.5 0.5]*params.wc_cagefloor_width_cm*480/640);
    for i=1:length(ind)
        plot( [nose_cm(ind(i),1) arse_cm(ind(i),1)],...
            [nose_cm(ind(i),2) arse_cm(ind(i),2)],'color',cmap(i,:));
        plot( [nose_cm(ind(i),1) nose_cm(ind(i),1)],...
            [nose_cm(ind(i),2) nose_cm(ind(i),2)],'*','color',cmap(i,:));
        plot([stim_cm(ind(i),1) stim_cm(ind(i)+1,1)],...
            [stim_cm(ind(i),2) stim_cm(ind(i)+1,2)],'color',cmap(i,:));
    end
    
    
    text(stim_pxl(ind(1),1),stim_pxl(ind(1),2),'B','horizontalalignment','Center')
    text(stim_pxl(ind(end),1),stim_pxl(ind(end),2),'E','horizontalalignment','Center')
    
    subplot(2,2,3)
    for i=1:length(ind)
        polarplot([phi(ind(i)) phi(ind(i)+1)],[i i+1],'color',cmap(i,:));
        hold on
        
        %    plot([i i+1],[phi(ind(i)) phi(ind(i)+1)],'color',cmap(i,:));
    end
    %ylabel('Head direction (rad)');
    
    % stim movements in mouse centered coordinates
    subplot(2,2,4)
    hold on;
    set(gca,'ydir','reverse')
    axis image
    for i=1:length(ind)
        plot([record.measures.stim_nose_centered_rotated_cm(ind(i),1) record.measures.stim_nose_centered_rotated_cm(ind(i)+1,1)],...
            [record.measures.stim_nose_centered_rotated_cm(ind(i),2) record.measures.stim_nose_centered_rotated_cm(ind(i)+1,2)],'color',cmap(i,:));
    end
    
    if 0
        for i=1:10:length(ind) % plot stim direction
            plot([record.measures.stim_nose_centered_rotated_cm(ind(i),1) record.measures.stim_nose_centered_rotated_cm(ind(i),1)+record.measures.stim_direction_rotated_cm_per_s(ind(i),1)/10],...
                [record.measures.stim_nose_centered_rotated_cm(ind(i),2) record.measures.stim_nose_centered_rotated_cm(ind(i),2)+record.measures.stim_direction_rotated_cm_per_s(ind(i),2)/10],'-r');
            
        end
    end

    for i=1:10:length(ind) % plot stim x axis
        plot(record.measures.stim_nose_centered_rotated_cm(ind(i),1)+[-0.5 0.5]*record.measures.stim_x_axis_rotated_cm(ind(i),1),...
            record.measures.stim_nose_centered_rotated_cm(ind(i),2)+[-0.5 0.5]*record.measures.stim_x_axis_rotated_cm(ind(i),2),'-k');
        
    end
    for i=1:10:length(ind) % plot stim y axis
        plot(record.measures.stim_nose_centered_rotated_cm(ind(i),1)+[-0.5 0.5]*record.measures.stim_y_axis_rotated_cm(ind(i),1),...
            record.measures.stim_nose_centered_rotated_cm(ind(i),2)+[-0.5 0.5]*record.measures.stim_y_axis_rotated_cm(ind(i),2),'-k');
        
    end

    
    
    text(record.measures.stim_nose_centered_rotated_cm(ind(1),1),...
        record.measures.stim_nose_centered_rotated_cm(ind(1),2),'B','horizontalalignment','Center')
    text(record.measures.stim_nose_centered_rotated_cm(ind(end),1),...
        record.measures.stim_nose_centered_rotated_cm(ind(end),2),'E','horizontalalignment','Center')
    
end





