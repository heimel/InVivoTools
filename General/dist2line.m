function [d,x1,y1] = dist2line(m,b,Z)
% DIST2LINE - Computes distance between point and line, and closest point
%
% [D,X1,Y1] = DIST2ILNE(M,B,Z)
%
%  Computes the distance D from a point Z = [ X0 Y0] to a line
%  defined by Y = M * X + B.  The point [X1 Y1] is the closest
%  point on line Y to point Z = [X0 Y0].  If M is Inf then B is assumed
%  to be X location of the line.

if m==0, d = abs(Z(2)-b);  y1 = b; x1 = Z(1);
elseif m==Inf,
	d = Z(1)-b;
	x1 = b;
	y1 = Z(2);
else,
	b1 = Z(2)+Z(1)/m;
	x1 = (b1-b)/(m+1/m);
	y1 = -x1/m+b1;
	d = sqrt( (Z(1)-x1).^2 + (Z(2)-y1).^2);
end;
