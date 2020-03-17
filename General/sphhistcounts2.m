function [n,azimuthedges,elevationedges] = sphhistcounts2(azimuth,elevation,azimuthedges,elevationedges)
%SPHHISTCOUNTS is spherical version of histcounts2
%
%  [N,AZIMUTHEDGES,ELEVATIONEDGES] = ...
%        SPHHISTCOUNTS2(AZIMUTH,ELEVATION,AZIMUTHEDGES,ELEVATIONEDGES)
%
% 2020, Alexander Heimel

if nargin<3 || isempty(azimuthedges)
    d_azimuths = 2*pi/12 ;% 2*pi/12  ;
    azimuthedges = -pi:d_azimuths:pi;
end
if nargin<4 || isempty(elevationedges)
    elevationedges = 4;
end

if numel(elevationedges)==1 % number of areas specified
    n_elevationedges = elevationedges;
    elevationedges = zeros(1,n_elevationedges);
    for i=0:n_elevationedges-1
        elevationedges(i+1) = asin(i / (n_elevationedges-1));
    end
end



ind = ~isnan(azimuth) & ~isnan(elevation);
% n = histcounts2(azimuth(ind),pi/2-elevation(ind),...
%     'xbinedges',azimuthedges,'ybinedges',elevationedges);

n = histcounts2(azimuth(ind),elevation(ind),azimuthedges,elevationedges);
