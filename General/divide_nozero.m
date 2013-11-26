function z = divide_nozero(x,y)

%  DIVIDE_NOZERO - performs division such that 0/0 = 0
%
%  Z = DIVIDE_NOZERO(X,Y)
%
%  Performs an element-by-element divison of X and Y in the usual
%  way except that 0/0 is 0 instead of NaN.  n/0, where n is any
%  number except zero, will still be inf.
%
%  See also:  RDIVIDE, LDIVIDE

c = find(x~=0|y~=0);
z = zeros(size(x)); z(c) = x(c)./y(c);
