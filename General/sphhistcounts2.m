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
    d_elevation = 0.4; % 0.4
    elevationedges = [];
    elevationedges(1) = 0;
    elevationedges(2) = d_elevation;
    while elevationedges(end)<1.0
        elevationedges(end+1) = acos(2*cos(elevationedges(end))-cos(elevationedges(end-1))); %#ok<AGROW>
    end
end


ind = ~isnan(azimuth) & ~isnan(elevation);
% n = histcounts2(azimuth(ind),pi/2-elevation(ind),...
%     'xbinedges',azimuthedges,'ybinedges',elevationedges);

n = histcounts2(azimuth(ind),pi/2-elevation(ind),azimuthedges,elevationedges);
