function y=subst_ctlchars(x)
%SUBST_CTLCHARS substitutes graph control characters by harmless characters
%
% Y=SUBST_CTLCHARS(X)
%  Y will have same length as X
%
% 2007, Alexander Heimel
%
% See also GENVARNAME
%

y=x;
y(find(y=='_'))='-';
