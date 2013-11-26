function newpath = winpath2mac(pathname)

%  WINPATH2MAC
%    Converts a Windows pathname to a Macintosh pathname.
%  
%  NEWPATH = WINPATH2MAC(PATHNAME)
%
%  Replaces all '\' characters with ':' characters.

h = find(pathname=='\');
newpath = pathname; newpath(h) = ':';
