function [Xo,Yo,rect,inds] = getgrid(BLstim)
%  blinkingstim/getgrid
%
%  [X,Y,RECT,INDS] = GETGRID(BLSTIM)
%
%  Returns the dimensions of the grid associated with BLINKINGSTIM
%  BLSTIM in X and Y, and also the rectangle on the screen where the
%  BLSTIM is to be drawn.  It also returns a matrix INDS which contains
%  in each column i the indicies of grid point i in a matrix image of size
%  RECT.  The grid points are numbered from 1 to X*Y going down each
%  column and then over each row.

  width  = BLstim.rect(3) - BLstim.rect(1);
  height = BLstim.rect(4) - BLstim.rect(2);
  % set up grid
  if (BLstim.pixSize(1)>=1),
         X = BLstim.pixSize(1);
  else, X = (width*BLstim.pixSize(1));
  end;
  if (BLstim.pixSize(2)>=1),
         Y = BLstim.pixSize(2);
  else, Y = (height*BLstim.pixSize(2));
  end;

  i = 1:width;
  x = fix((i-1)/X)+1;
  i = 1:height;
  y = fix((i-1)/Y)+1;
  XY = x(end)*y(end);

  Xo = x(end); Yo = y(end);
  rect = BLstim.rect;

if nargout==4,
  grid = ([(x-1)*y(end)]'*ones(1,length(y))+ones(1,length(x))'*y)';
  g = reshape(1:width*height,height,width);
  corner = zeros(Y,X); corner(1) = 1;
  cc=reshape(repmat(corner,height/Y,width/X).*g,width*height,1);
  corners = cc(find(cc))';
  footprint = reshape(g(1:Y,1:X),X*Y,1)-1;
  inds=ones(1,X*Y)'*corners+footprint*ones(1,XY);
end;

