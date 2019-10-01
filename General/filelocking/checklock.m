function [res,lockfile]=checklock( filename )
%CHECKLOCK checks the existence of a lockfile and returns contents struct
%
%  [RES, LOCKFILE] = CHECKLOCK( FILENAME) 
%     RES = 0 if no lock, 1 if lock
%
% 2007, Alexander Heimel
%

res = 0;
lockfile = [];

lockfilename = getlockfilename( filename);

fid = fopen(lockfilename,'r');
if fid==-1 % no lockfile
  return
end
res = 1;

while ~feof(fid)
  l = strtrim(fgets(fid));
  if l(1)~='#'
    p = find(l=='=');
    if isempty(p)
      lockfile = setfield(lockfile,l,[]);
    else
      lockfile = setfield(lockfile,l(1:p(1)-1),l(p(1)+1:end));
    end
  end
  
end

fclose(fid);
