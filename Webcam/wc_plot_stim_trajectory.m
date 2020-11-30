function [h,r] = wc_plot_stim_trajectory(record,h,verbose,plotoptions)
%WC_PLOT_POLAR_TRAJECTORY plots position of stims in retinal coordinates
%
%  [H,R] = WC_PLOT_POLAR_TRAJECTORY(RECORDS, H, VERBOSE, PLOTOPTIONS)
%
% H is figure handle
% R is a structure with the azimuths and elevations
% VERBOSE
% PLOTOPTIONS
%    plotoptions.show_stim = true; % gray points
%    plotoptions.show_stimstart = true; % green disks
%    plotoptions.show_freeze = true; % red points
%    plotoptions.show_freezestart = false;
%
% 2019-2020, Alexander Heimel

if nargin<3 || isempty(verbose)
    verbose = true;
end
if nargin<2
    h = [];
end
if nargin<4 || isempty(plotoptions)
    plotoptions.show_stim = true; % gray points
    plotoptions.show_stimstart = true; % green disks
    plotoptions.show_freeze = true; % red points
    plotoptions.show_freezestart = true;
end

if ~isfield(plotoptions,'show_circles') || isempty(plotoptions.show_circles)
    plotoptions.show_circles = true;
end
if ~isfield(plotoptions,'markersize') || isempty(plotoptions.markersize)
    plotoptions.markersize = 3;
end
if ~isfield(plotoptions,'startmarkersize') || isempty(plotoptions.startmarkersize)
    plotoptions.startmarkersize = 6;
end



r = [];
if isempty(record)
    return
end

if length(record)>1
    [h,results(1)] = wc_plot_stim_trajectory(record(1),h,verbose,plotoptions);
    for i=2:length(record)
        [h,results(i)] = wc_plot_stim_trajectory(record(i),h,verbose,plotoptions); %#ok<AGROW>
    end
    flds = fields(results);
    for f = 1:length(flds)
        r.(flds{f}) = vertcat(results.(flds{f}));
    end
    return
end

params = wcprocessparams(record);

r.azimuth = [];
r.elevation = [];
r.azimuth_stimstart = [];
r.elevation_stimstart = [];
r.azimuth_freezestart = [];
r.elevation_freezestart = [];
r.azimuth_freeze = [];
r.elevation_freeze = [];

if ~isfield(record,'measures')
    logmsg(['Not analyzed record ' recordfilter(record)]);
    return
end
if isfield(record,'measures') && isnan(record.measures.stim_seqnr) % problem with stim
    return
end

if isfield(record,'measures') && record.measures.stim_seqnr == 0 % % gray stim
    return
end

if ~isfield(record.measures,'azimuth_trajectory')
    logmsg(['No trajectory info for ' recordfilter(record)]);
    return
end

if ~isfield(record.measures,'ind_freeze')
    record = wc_add_freezing_ind( record, verbose);
end

ind_freeze = record.measures.ind_freeze;

if verbose && ~isoctave && isfield(record.measures,'stim_nose_centered_rotated_cm') && params.wc_plot_stim_nose_centered_rotated
    if isempty(h)
        h = figure('name','Stim trajectory','NumberTitle','off');
    end
    
    % plot stim_nose_centered_rotated_cm
    %recordfilter(record)
    
    ind = find(~isnan(record.measures.stim_nose_centered_rotated_cm(:,1)));
    
    hold on;
    
    if plotoptions.show_circles
        rectangle('Position',[-25 -25 2*25 2*25],'Curvature',[1 1],'edgecolor',0.7*[1 1 1],'linewidth',0.25)
        text(20,-20,'25 cm','Fontsize',18);
        
        rectangle('Position',[-50 -50 2*50 2*50],'Curvature',[1 1],'edgecolor',0.7*[1 1 1],'linewidth',0.25)
        text(37,-37,'50 cm','Fontsize',18);
    end
    
    set(gca,'ydir','reverse')
    axis image
    set(gca,'xaxislocation','origin');
    set(gca,'yaxislocation','origin');
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    xlim([-58 58]);
    ylim([-58 58]);
    
    if plotoptions.show_stim
        if params.wc_plot_trajectory_line
            cmap = parula(length(ind));
            for i=1:length(ind)
                plot([record.measures.stim_nose_centered_rotated_cm(ind(i),1) record.measures.stim_nose_centered_rotated_cm(ind(i)+1,1)],...
                    [record.measures.stim_nose_centered_rotated_cm(ind(i),2) record.measures.stim_nose_centered_rotated_cm(ind(i)+1,2)],...
                    'linewidth',3,'color',cmap(i,:));
            end
        else
            plot(record.measures.stim_nose_centered_rotated_cm(ind,1),...
                record.measures.stim_nose_centered_rotated_cm(ind,2),...
                'o','color',0.8*[1 1 1],...
                'markersize',plotoptions.markersize,...
                'markerfacecolor',0.8*[1 1 1]);
        end
    end
    
    if 0
        for i=1:10:length(ind)  %#ok<UNRCH> % plot stim direction
            plot([record.measures.stim_nose_centered_rotated_cm(ind(i),1) record.measures.stim_nose_centered_rotated_cm(ind(i),1)+record.measures.stim_direction_rotated_cm_per_s(ind(i),1)/10],...
                [record.measures.stim_nose_centered_rotated_cm(ind(i),2) record.measures.stim_nose_centered_rotated_cm(ind(i),2)+record.measures.stim_direction_rotated_cm_per_s(ind(i),2)/10],'-r');
            
        end
    end
    
    if params.wc_plot_stimulus_in_trajectory
        for i=1:10:length(ind) % plot stim x axis
            plot(record.measures.stim_nose_centered_rotated_cm(ind(i),1)+[-0.5 0.5]*record.measures.stim_x_axis_rotated_cm(ind(i),1),...
                record.measures.stim_nose_centered_rotated_cm(ind(i),2)+[-0.5 0.5]*record.measures.stim_x_axis_rotated_cm(ind(i),2),'-k');
            
        end
        for i=1:10:length(ind) % plot stim y axis
            plot(record.measures.stim_nose_centered_rotated_cm(ind(i),1)+[-0.5 0.5]*record.measures.stim_y_axis_rotated_cm(ind(i),1),...
                record.measures.stim_nose_centered_rotated_cm(ind(i),2)+[-0.5 0.5]*record.measures.stim_y_axis_rotated_cm(ind(i),2),'-k');
            
        end
    end   
    
    if  plotoptions.show_stimstart && ~isempty(ind)
        plot(record.measures.stim_nose_centered_rotated_cm(ind(1),1),...
            record.measures.stim_nose_centered_rotated_cm(ind(1),2),...
            'o','color',[1 1 1]*0.7,...
            'markersize',plotoptions.startmarkersize,...
            'markerfacecolor',[1 1 1]*0.7);
    end
    
    if  plotoptions.show_freeze
        plot(record.measures.stim_nose_centered_rotated_cm(ind_freeze,1),...
            record.measures.stim_nose_centered_rotated_cm(ind_freeze,2),...
            'o','color',[ 1 0  0],...
            'markersize',plotoptions.markersize,...
            'markerfacecolor',[ 1 0 0]);
    end
    
    
    if  plotoptions.show_freezestart &&  ~isempty(ind_freeze)
        plot(record.measures.stim_nose_centered_rotated_cm(ind_freeze(1),1),...
            record.measures.stim_nose_centered_rotated_cm(ind_freeze(1),2),...
            'o','color',[ 1 0  0],...
            'markersize',plotoptions.startmarkersize,...
            'markerfacecolor',[ 1 0.1 0.1]);
    end
    
end
