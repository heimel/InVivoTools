function res=rmlock(filename)
%RMLOCK removes file lock
%
%  RES = RMLOCK( FILENAME )
%    RES = 1 if succeeded, 0 if failed
%
% 2007, Alexander Heimel
%

res=0;

stat=checklock( filename );
if stat==0
  res=1;
  return;
end

lockfilename=getlockfilename( filename);

delete(lockfilename);

stat=checklock( filename );
if stat==1
  res=0;
  warning(['failed to remove lock on ' filename ]);
else
  res =1;
end
