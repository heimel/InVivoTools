function [scale,min_error]=optimal_xscaling(x1,y1,x2,y2)
%OPTIMAL_XSCALING of function x1,y1 to data x2,y2 by scaling x1
%
% 2009, Alexander Heimel

% coarse scale
scale_range=logspace(-3,3,10);
[scale,min_error]=optimal_xscaling_local(x1,y1,x2,y2,scale_range);
% fine scale
scale_range=linspace(scale/3,scale*3,100);
[scale,min_error]=optimal_xscaling_local(x1,y1,x2,y2,scale_range);

function [scale,min_error]=optimal_xscaling_local(x1,y1,x2,y2,scale_range)
min_error=inf;
for s=scale_range
	x_scaled=x1*s;
	ind=findclosest(x_scaled,x2);
	error= sum( (y2 - y1(ind)).^2);
	if error<min_error
		min_error=error;
		scale=s;
	end
end

