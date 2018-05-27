function b = isboolean(x)
%  B = ISBOOLEAN(X)
%
%  Returns 1 iff X is a matrix of 0's and 1's.
%
%  See also ISLOGICAL
% 
% 200X, Steve Van Hooser

b = 0;
if isnumeric(x)
    b = all((x==0)|(x==1));
end
