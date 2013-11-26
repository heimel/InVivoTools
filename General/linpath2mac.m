function newpath = linpath2mac(pathname)

%  LINPATH2MAC
%    Converts a Linux pathname to a Macintosh pathname.
%  
%  NEWPATH = LINPATH2MAC(PATHNAME)
%
%  Replaces all '/' characters with ':' characters.

h = find(pathname=='/');
newpath = pathname; newpath(h) = ':';
