function pathn = fixpath(pathstr)

%   Part of the NewStim package
%
%   PATHN = FIXPATH (PATHSTR)
%
%   Checks the string PATHSTR to see if it ends in FILESEP ('/' on the Unix
%   platform, ':' on the Macintosh).  PATHN is simply PATHSTR with a FILESEP 
%   attached at the end if necessary.
%
%   See also: FILESEP

pathn = pathstr;
if ~isempty(pathn)
	if pathn(end)~=filesep, 
		pathn=[pathn filesep]; 
	end;
end
