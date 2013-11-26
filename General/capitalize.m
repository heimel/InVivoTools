function s = capitalize( s )
%CAPITALIZE returns string with only its first character capitalized
%
% S = CAPITALIZE( S )
%   e.g. capitalize('aBcd eF') returns 'Abcd ef'
%
% 2010, Alexander Heimel
%

if ~isempty(s)
    s = lower(s);
    s(1) = upper(s(1));
end
