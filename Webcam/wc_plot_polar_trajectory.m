function [h,r] = wc_plot_polar_trajectory(record,h,verbose,plotoptions)
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

r = [];
if isempty(record)
    return
end

if length(record)>1
    [h,results(1)] = wc_plot_polar_trajectory(record(1),h,verbose,plotoptions);
    for i=2:length(record)
        [h,results(i)] = wc_plot_polar_trajectory(record(i),h,verbose,plotoptions); %#ok<AGROW>
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
% r.azimuth_stimstart = [];
% r.elevation_stimstart = [];
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


r.azimuth = record.measures.azimuth_trajectory;
r.elevation = record.measures.elevation_trajectory;

ind_stimstart = find(~isnan(r.azimuth),1,'first');

ind_freeze = record.measures.ind_freeze;
if ~isempty(ind_freeze)
    r.azimuth_freezestart = r.azimuth(ind_freeze(1));
    r.elevation_freezestart = r.elevation(ind_freeze(1));
end
r.azimuth_freeze =  r.azimuth(ind_freeze);
r.elevation_freeze =  r.elevation(ind_freeze);


if verbose && ~isoctave
    if isempty(h)
        h = figure('name','Polar trajectory','NumberTitle','off');
    end
    
    polarplot(0,0,'.','color',[1 1 1])
    set(gca,'ThetaDir','clockwise') % to fit with movie
    set(gca,'RtickLabel',[]);
    set(gca,'ThetatickLabel',[]);
    hold on
    set(gca,'rlim',[0 atan(55/25)]);
    set(gca,'rticklabelmode','auto');
    set(gca,'rtick',[30 45 60]/180*pi);
    set(gca,'rticklabel',{'60^o','45^o','30^o'});
    set(gca,'RAxisLocation',-60);
    
    
    if plotoptions.show_stim
        polarplot(r.azimuth,pi/2-r.elevation,'o','color',0.8*[1 1 1],'markerfacecolor',0.8*[1 1 1],'markersize',3)
    end
    if plotoptions.show_stimstart
        polarplot(r.azimuth(ind_stimstart),pi/2-r.elevation(ind_stimstart),'go','markersize',4,'markerfacecolor',[0 1 0]);
    end
    if plotoptions.show_freeze
        polarplot(r.azimuth_freeze,pi/2-r.elevation_freeze,'ro','markerfacecolor',[1 0 0],'markersize',3);
    end
    if plotoptions.show_freezestart
        polarplot(r.azimuth_freezestart,pi/2-r.elevation_freezestart,'ro','markerfacecolor',[1 0 0],'markersize',4);
    end
    
end
