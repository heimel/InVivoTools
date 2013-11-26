function y = last( x)
%LAST returns last element
%
%  Y = LAST( X)
%
% 2012, Alexander Heimel
%

if iscell(x)
    y = x{end};
else
    y = x(end);
end