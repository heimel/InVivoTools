function newstr=trim( str )
%TRIM removes blanks from both sides of string
%
%  DEPRECATED: USE MATLAB FUNCTION STRTRIM INSTEAD
%
%   NEWSTR=TRIM( STR )
%
%  See also STRPAD
%
%   2005-2015, Alexander Heimel
%

logmsg( 'DEPRECATED: USE MATLAB FUNCTION STRTRIM INSTEAD');

newstr = deblank( str); % remove trailing spaces
newstr = fliplr( deblank( fliplr(newstr) ) );
