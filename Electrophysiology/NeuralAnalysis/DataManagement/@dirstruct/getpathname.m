function p = getpathname(cksds)

%  P = GETPATHNAME(THEDIRSTRUCT)
%
%  Returns the pathname associated with THEDIRSTRUCT.

p = fixpath(fixtilde(cksds.pathname));
