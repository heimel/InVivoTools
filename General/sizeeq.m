function b = sizeeq(x,y)

% SIZEEQ  Determines if size of two variables is same
%   
%   B = SIZEEQ(X,Y)
%
%  Returns 1 if the size of X and Y are equal.  Otherwise, returns 0.

sz1 = size(x); sz2 = size(y);
if length(sz1)==length(sz2),
   f=eqemp(sz1,sz2); sz=size(f); b=prod( double(reshape(f,1,prod( double(sz) ))));
else, b=0;
end;
