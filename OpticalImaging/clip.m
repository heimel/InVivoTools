function y=clip(x,center,bound)
%CLIP clips data
%
%    Y=CLIP(X,CENTER,BOUND)
%         clips symmetrical around center if bound is number 
%         if BOUND is 2x1 clips between BOUND(1)+CENTER and BOUND(2)+CENTER
%         in this case BOUND(1) should usually be negative!
%
%  2004, Alexander Heimel
  
  
  if nargin<3
    bound=nanstd(x(:))*3;  %default 3 std
  end
  if nargin<2
    center=nanmean(x(:));
  end
  
  y=x;
  if length(bound)==1
    top=center+bound;
    y(find(y>top))=top;
    bottom=center-bound;
    y(find(y<bottom))=bottom;
  elseif length(bound)==2
    top=center+bound(1);
    y(find(y>top))=top;
    bottom=center+bound(2);
    y(find(y<bottom))=bottom;
  else
    disp('Error in CLIP. BOUND wrong length')
    y=[];
    return;
  end
  
