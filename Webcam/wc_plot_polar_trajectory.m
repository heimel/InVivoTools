function [h,r] = wc_plot_polar_trajectory(record,h,verbose)
%WC_PLOT_POLAR_TRAJECTORY plots position of stims in retinal coordinates
%
%  [H,R] = WC_PLOT_POLAR_TRAJECTORY(RECORD, H)
%
% H is figure handle
% R is a structure with the azimuths and elevations
%
% 2019, Alexander Heimel

if nargin<3 || isempty(verbose)
    verbose = true;
end

if ~isfield(record,'measures') || ~isfield(record.measures,'azimuth_trajectory')
    logmsg(['No trajectory info for ' recordfilter(record)]);
    return
end

if nargin<2 || isempty(h)
    if verbose
        h = figure('name','Stim trajectory');
    else
        h = [];
    end
end

azimuth = record.measures.azimuth_trajectory;
elevation = record.measures.elevation_trajectory;

r.azimuth = azimuth;
r.elevation = elevation;

if verbose
    polarplot(azimuth,pi/2-elevation,'.','color',0.8*[1 1 1])
    set(gca,'ThetaDir','clockwise') % to fit with movie
    hold on
end

ind = find(~isnan(azimuth),1,'first');

r.azimuth_stimstart = azimuth(ind);
r.elevation_stimstart = elevation(ind);

if verbose
    h = polarplot(r.azimuth_stimstart,pi/2-r.elevation_stimstart,'go');
    set(h,'MarkerFaceColor',get(h,'Color'));
end


t = record.measures.frametimes;
if isfield(record.measures,'freezetimes')
    freezetimes = record.measures.freezetimes;
else
    logmsg(['Record is not manually analyzed, ' recordfilter(record)]);
    freezetimes = record.measures.freezetimes_aut;
end

r.azimuth_freezestart = [];
r.elevation_freezestart = [];
r.azimuth_freeze = [];
r.elevation_freeze = [];

for i = 1:size(freezetimes,1)
    ind = find(t>=freezetimes(i,1) & t<=freezetimes(i,2));
    if ~isempty(ind)
        indind = find(~isnan(ind),1,'first');
        if ~isempty(indind)
            r.azimuth_freezestart = [r.azimuth_freezestart;azimuth(ind(indind))];
            r.elevation_freezestart = [r.elevation_freezestart;elevation(ind(indind))];
        end
        r.azimuth_freeze = [r.azimuth_freeze;azimuth(ind)];
        r.elevation_freeze = [r.elevation_freeze;elevation(ind)];
        
        if verbose
            hf = polarplot(azimuth(ind),pi/2-elevation(ind),'r.-');
            set(hf,'linewidth',3);
        end
        
        azimuth(ind) = NaN;
        elevation(ind) = NaN;
    end
    
end

r.azimuth_nonfreeze = azimuth;
r.elevation_nonfreeze = elevation;
