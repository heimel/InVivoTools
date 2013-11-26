function newstr=trim( str )
%TRIM removes blanks from both sides of string
%
%  DEPRECATED: USE MATLAB FUNCTION STRTRIM INSTEAD
%
%   NEWSTR=TRIM( STR )
%
%  See also STRPAD
%
%   2005-2011, Alexander Heimel
%
  
  newstr = deblank( str); % remove trailing spaces
  newstr = fliplr( deblank( fliplr(newstr) ) );  
