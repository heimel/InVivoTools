function y=subst_ctlchars(x)
%SUBST_CTLCHARS substitutes graph control characters by harmless characters
%
% Y=SUBST_CTLCHARS(X)
%  Y will have same length as X
%
% 2007-2025, Alexander Heimel
%
% See also GENVARNAME
%

y=x;
if ischar(y)
    y(find(y=='_'))='-';
elseif isstring(y)
    y = char(y);
    y(find(y=='_'))='-';
    y = string(y);
end

