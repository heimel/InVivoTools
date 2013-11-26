function b = eqtot(x,y)

% EQTOT
%
%   B = EQTOT(X,Y)
%
%  Returns EQEMP(X,Y), except that if the result is an array of boolean values,
%  the logical AND of all the results is returned.
%
%  Example:  EQTOT([4 4 4],[4 4 4]) = 1, EQTOT([1],[1 1]) = 1
%
%  See also:  EQEMP, EQ

b=eqemp(x,y); b=prod(double(reshape(b,1,prod( double(size(b)) ))));
