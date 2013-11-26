function b = ispos(x)

% B = ISPOS(X)
%
% Returns 1 iff X is a matrix of positive numbers.

b = 0;
if (isnumeric(x)&isreal(x)),b=all(x>0);end;
