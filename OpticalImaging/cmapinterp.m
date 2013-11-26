function cmap = cmapinterp(rgbs,N)

% CMAPINTERP - Create color table that interpolates among given list of colors
%
%  CMAP = CMAPINTERP(RGBs,N)
%
%  Returns in CMAP a colortable that interpolates among a list of colors given
%  in RGBs.  N colors are returned.
%
%  Example:  CMAPINTERP([1 0 0 ; 0 0 1],3) returns
%   CMAP = [ 1 0 0 ; 0.5 0 0.5 ; 0 0 1 ];
%
%  Note:If the colors do not divide evenly among the N slots in the color table,
%  the rate of change between different pairs of colors can be different.

cmap = zeros(N,3);

m = size(rgbs,1);  % number of colors

pitch = (N-1)/(m-1);

for i=1:m-1,
	ind= round(1+(i-1)*pitch):round(i*pitch);
	linspa = [linspace(rgbs(i,1),rgbs(i+1,1),length(ind)+1)' ...
	          linspace(rgbs(i,2),rgbs(i+1,2),length(ind)+1)' ...
	          linspace(rgbs(i,3),rgbs(i+1,3),length(ind)+1)'];
	cmap(ind,:) = linspa(1:end-1,:);
end;
if round(i*pitch)<N, cmap(end,:) = rgbs(end,:); end;
