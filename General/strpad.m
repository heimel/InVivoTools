function padstr = strpad( str, len, ch, direction)
%STRPAD pads string with character
%
% PADSTR = STRPAD( STR, LEN, CH, DIRECTION )
%
%   CH is padding character (space by default)
%   DIRECTION can be 'pre' or 'post'
%
% Padding with spaces can also be achieved with sprint('%20x','hallo')
%    or sprint('%-20x','hallo')
%
% 2011, Alexander Heimel
%

if nargin<4
    direction = 'post';
end
if nargin<3
    ch = ' ';
end

switch direction
    case 'post'
        padstr = [str repmat(ch,1,max(0,len-length(str))) ];
    case 'pre'
        padstr = [ repmat(ch,1,max(0,len-length(str))) str ];
    otherwise
        error('STRPAD:UNKNOWN_DIRECTION','Unknown direction');
end
