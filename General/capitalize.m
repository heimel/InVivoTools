function s = capitalize( s )
%CAPITALIZE returns string with only its first character capitalized
%
% S = CAPITALIZE( S )
%   e.g. capitalize('aBcd eF') returns 'Abcd ef'
%
% 2010-2023, Alexander Heimel
%

if ~isempty(s)
    if ischar(s)

        s = lower(s);
        s(1) = upper(s(1));
    elseif isstring(s)
        for i=1:length(s)
            s{i} = capitalize(s{i});
        end
    end
end
