function [Xo,Yo,rect,width, height, inds, grid] = getgrid(SGSstim)
%  stochasticgridstim/getgrid
%
%  [X,Y,RECT,WIDTH,HEIGHT,INDS,GRID] = GETGRID(SGSSTIM)
%
%  Returns the dimensions of the grid associated with STOCHASTICGRIDSTIM
%  SGSSTIM in X and Y, and also the rectangle on the screen where the
%  SGSSTIM is to be drawn.  It also returns a matrix INDS which contains
%  in each column i the indicies of grid point i in a matrix image of size
%  RECT.  The grid points are numbered from 1 to X*Y going down each
%  column and then over each row.

SGSparams = SGSstim.SGSparams;

width  = SGSparams.rect(3) - SGSparams.rect(1);
height = SGSparams.rect(4) - SGSparams.rect(2);

% set up grid
if (SGSparams.pixSize(1)>=1),
	X = SGSparams.pixSize(1);
else, X = (width*SGSparams.pixSize(1)); 
end;

if (SGSparams.pixSize(2)>=1),
	Y = SGSparams.pixSize(2);
else, Y = (height*SGSparams.pixSize(2)); 
end;

i = 1:width;
x = fix((i-1)/X)+1;
i = 1:height;
y = fix((i-1)/Y)+1;
XY = x(end)*y(end);

Xo = x(end); Yo = y(end);
rect = SGSparams.rect;

if nargout>=6,
  grid = ([(x-1)*y(end)]'*ones(1,length(y))+ones(1,length(x))'*y)';
  g = reshape(1:width*height,height,width);
  corner = zeros(Y,X); corner(1) = 1;
  cc=reshape(repmat(corner,height/Y,width/X).*g,width*height,1);
  corners = cc(find(cc))';
  footprint = reshape(g(1:Y,1:X),X*Y,1)-1;
  inds=ones(1,X*Y)'*corners+footprint*ones(1,XY);
end;
