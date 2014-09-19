function blinkList = getgridorder(blinkstim)

%  BLINKSTIM/GETGRIDORDER - Get grid order for a BLINKINGSTIM
%
%  BLINKLIST = GETGRIDORDER(MYBLINKINGSTIM)
%  Returns the grid order for blinkingstim MYBLINKINGSTIM.
%
%  See also: BLINKINGSTIM, GETGRID, GETGRIDVALUES

width  = blinkstim.rect(3) - blinkstim.rect(1);
height = blinkstim.rect(4) - blinkstim.rect(2);

% set up grid
if (blinkstim.pixSize(1)>=1),
	X = blinkstim.pixSize(1);
else, X = (width*blinkstim.pixSize(1));
end;

if (blinkstim.pixSize(2)>=1),
	Y = blinkstim.pixSize(2);
else, Y = (height*blinkstim.pixSize(2));
end;

corner = zeros(Y,X); corner(1) = 1;
Ys=repmat(corner,height/Y,width/X).*repmat((1:height)',1,width);
Ys = Ys(find(Ys));
Xs=repmat(corner,height/Y,width/X).*repmat((1:width),height,1);
Xs = Xs(find(Xs));
rects =  [ Xs Ys Xs+X Ys+Y ]-1;

blinkList = repmat(1:size(rects,1),1,blinkstim.repeat);
if (blinkstim.random),
	rand('state',blinkstim.randState);
	inds = randperm(length(blinkList));
	blinkList = blinkList(inds);
end;
