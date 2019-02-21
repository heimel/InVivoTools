function [h,r] = wc_plot_polar_trajectory(record,h)
%WC_PLOT_POLAR_TRAJECTORY plots position of stims in retinal coordinates
%
%  [H,R] = WC_PLOT_POLAR_TRAJECTORY(RECORD, H)
%
% H is figure handle
% R is a structure with the azimuths and elevations
%
% 2019, Alexander Heimel


if ~isfield(record,'measures') || ~isfield(record.measures,'azimuth_trajectory')
    logmsg(['No trajectory info for ' recordfilter(record)]);
    return
end

if nargin<2 || isempty(h)
    h = figure('name','Stim trajectory');
end

azimuth = record.measures.azimuth_trajectory;
elevation = record.measures.elevation_trajectory;

r.azimuth = azimuth;
r.elevation = elevation;

% disp('RANDOMIZING!');
% azimuth = azimuth + 2*pi*rand(1,1);

indnnan = ~isnan(azimuth);


polarplot(azimuth,pi/2-elevation,'.','color',0.8*[1 1 1])
set(gca,'ThetaDir','clockwise') % to fit with movie
hold on
%polarplot(azimuth(indnnan),pi/2-elevation(indnnan),'-','color',0.8*[1 1 1])
ind = find(~isnan(azimuth),1,'first');

r.azimuth_stimstart = azimuth(ind);
r.elevation_stimstart = elevation(ind);

h = polarplot(r.azimuth_stimstart,pi/2-r.elevation_stimstart,'go');
set(h,'MarkerFaceColor',get(h,'Color'));


% ind = find(~isnan(azimuth),1,'last');
% h = polarplot(azimuth(ind),pi/2-elevation(ind),'ro');
% set(h,'MarkerFaceColor',get(h,'Color'));

t = record.measures.frametimes;
if isfield(record.measures,'freezetimes')
    freezetimes = record.measures.freezetimes;
else
    freezetimes = record.measures.freezetimes_aut;
end

r.azimuth_freezestart = [];
r.elevation_freezestart = [];
r.azimuth_freeze = [];
r.elevation_freeze = [];
for i = 1:size(freezetimes,1)
    if ~isfield(record.measures,'pos_theta') || isnan( record.measures.pos_theta(i))
        % not a proper freeze as determined by manual operator
        continue
    end
    ind = find(t>=freezetimes(i,1) & t<=freezetimes(i,2));
    if ~isempty(ind)
        indind = find(~isnan(ind),1,'first');
        if ~isempty(indind)
            r.azimuth_freezestart = [r.azimuth_freezestart;azimuth(ind(indind))];
            r.elevation_freezestart = [r.elevation_freezestart;elevation(ind(indind))];
%             hf = polarplot(azimuth(ind(indind)),pi/2-elevation(ind(indind)),'ro');
%             set(hf,'MarkerFaceColor',get(hf,'Color'));
        end
        r.azimuth_freeze = [r.azimuth_freeze;azimuth(ind)];
        r.elevation_freeze = [r.elevation_freeze;elevation(ind)];
        hf = polarplot(azimuth(ind),pi/2-elevation(ind),'r.-');
        set(hf,'linewidth',3);
        
        azimuth(ind) = NaN;
        elevation(ind) = NaN;
    end
    
    
%     ind = find(t>=freezetimes(i,1) & t>=freezetimes(i,2)-0.5 & t<=freezetimes(i,2));
%     if ~isempty(ind)
%         hf = polarplot(azimuth(ind),pi/2-elevation(ind),'.-','color',[1 0.7 0.7]);
%         set(hf,'linewidth',3);
%     end
    
    
end


r.azimuth_nonfreeze = azimuth;
r.elevation_nonfreeze = elevation;
