function [ny,nx,h]=printtext(s,y,x)
%PRINTTEXT prints text in figure and returns ending y and x position
%
%  [NY,NX,H]=PRINTTEXT(S,Y,X)
%
% 2007-2013, Alexander Heimel
%

if nargin<3
    x = [];
end
if isempty(x)
	x=0.05;
end    
if nargin<2
	y = [];
end
if isempty(y)
    y = 1;
end
h=text(x,y,s,'VerticalAlignment','top','FontSize',8);
extent=get(h,'Extent');
ny=y-extent(4);
nx=x+extent(3);
return