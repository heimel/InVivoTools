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

logmsg( 'DEPRECATED: Use Matlab function STRTRIM instead.');

stack = dbstack(1);
if ~isempty(stack)
    logmsg(['Called by ' stack(1).name]);
end
newstr = deblank( str); % remove trailing spaces
newstr = fliplr( deblank( fliplr(newstr) ) );
