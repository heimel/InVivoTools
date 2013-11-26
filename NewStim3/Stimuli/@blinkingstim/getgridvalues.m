function [V] = getgridvalues(BLstim)
%  blinkingstim/getgridvalues
%
%  [V] = GETGRIDVALUES(BLSTIM)
%
%  Returns the value of each grid point at each frame in an (X*Y)xT matrix,
%  where X and Y are the dimensions of the grid (see GETGRID) and T is the
%  number of frames.

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

  corner = zeros(Y,X); corner(1) = 1;
  Ys=repmat(corner,height/Y,width/X).*repmat((1:height)',1,width);
  Ys = Ys(find(Ys));
  Xs=repmat(corner,height/Y,width/X).*repmat((1:width),height,1);
  Xs = Xs(find(Xs));
  rects =  [ Xs Ys Xs+X Ys+Y ]-1;

  %if (BLstim.random),
  %      rand('state',BLstim.randState);
  %  blinkList = [];
%		for jj=1:length(BLstim.repeat),
%			nbl = 1:size(rects,1);
%			inds = randperm(size(rects,1));
%			blinkList = [blinkList nbl(inds)];
%		end;
%  else, blinkList = repmat(1:size(rects,1),1,BLstim.repeat);
 % end;
  blinkList = repmat(1:size(rects,1),1,BLstim.repeat);
  if (BLstim.random), %this is the old blinkingstim, to be retired
	  					% 2005-10-25 -- can't remember why this was to be retired
	  rand('state',BLstim.randState);
      inds = randperm(length(blinkList));
      blinkList = blinkList(inds);
  end;
  
  N = size(rects,1)*BLstim.repeat;
  V = blinkList;
  V=ones(size(rects,1),N); % make blanks
  V((blinkList)+(0:N-1)*size(rects,1)) = 2;
