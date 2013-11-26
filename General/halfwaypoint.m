function x50=halfwaypoint(x,y,dir,point)
%HALFWAYPOINT gives first or last halfway crossing from piecewise 
%linear interpolation
%
%   X50=HALFWAYPOINT(X,Y,DIR,POINT)
%    dir=0 starts from low x, dir=1 starts from high x
%    point in [0,1] gives relative height, default point=0.5
%
%   note: assumes maximum y is positive
% 
% 2006, Alexander Heimel
%

if nargin<4
  point=[];
end
if nargin<3
  dir=[];
end
if isempty(point)
  point=0.5;
end
if isempty(dir)
  dir=0;
end

switch dir
 case 0,
  [x,ind]=sort(x);
  y=y(ind);  
 case 1,
  [x,ind]=sort(-x);
  x=-x;
  y=y(ind);
end

y50=max(y)*point;

if y(1)>y50 % going down
  i=1;
  while i<=length(x)
    if y(i)<y50
      break
    end
    i=i+1;
  end
  if i>length(y)
    % never went below half
    disp('Y always too large');
    x50=nan;
    return
  end
else % going up
  i=1;
  while i<=length(x)
    if y(i)>y50
      break
    end
    i=i+1;
  end
end  
 


x50=x(i-1)+(x(i)-x(i-1))/(y(i)-y(i-1))*(y50-y(i-1));
