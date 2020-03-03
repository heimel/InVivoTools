function [pfx,pf,px,r,t] = wc_compute_freezing_densities( traj,only_freezestart,verbose)
%COMPUTE_FREEZING_DENSITIES from trajectories
%
%  [PFX,PF,PX,R,T] = COMPUTER_FREEZING_DENSITIES(TRAJ,ONLY_FREEZESTART=FALSE,VERBOSE)
%
% 2019-2020, Alexander Heimel

if nargin<2 || isempty(only_freezestart)
    only_freezestart = false;
end
if nargin<3 || isempty(verbose)
    verbose = true;
end

[z,azimuthedges,elevationedges] = sphhistcounts2(traj.azimuth,traj.elevation);

px = z/sum(z(:));
px(px<0.0005) = 0;

if only_freezestart
    zfreeze = sphhistcounts2(traj.azimuth_freezestart,traj.elevation_freezestart,azimuthedges,elevationedges);
else % all freezing points
    zfreeze = sphhistcounts2(traj.azimuth_freeze,traj.elevation_freeze,azimuthedges,elevationedges);
end
pf = zfreeze/sum(zfreeze(:));

pfx = px;
pfx(pfx<0.0005) = inf;
pfx = pf./(pfx+0.0000001);
pfx = pfx/sum(pfx(:));
%pfx = imgaussfilt(pfx,1, 'Padding','symmetric');

if verbose
    figure('Name','P(x)'); % polar density plot all points
    
elevationcenters = (elevationedges(1:end-1)+elevationedges(2:end))/2;
azimuthcenters = (azimuthedges(1:end-1)+azimuthedges(2:end))/2;
    [r,t] = meshgrid(elevationcenters,azimuthcenters);
    polarcontours(r,t,px,50)
    
    figure('Name','P(freeze at x)') % polar plot freeze only
    polarcontours(r,t,pf,50)

    figure('Name','P(freeze|x)'); % polar density plot  freeze / nonfreeze
    polarcontours(r,t,pfx,50)
end

