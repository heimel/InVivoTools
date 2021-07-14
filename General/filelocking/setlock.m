function [res,lockfile,button]=setlock( filename )
%SETLOCK sets a filelock by creating filename.lock text file
%
%  [RES,LOCKFILE] = SETLOCK( FILENAME )
%    RES = 1 if succeeded, 0 if failed
%    LOCKFILE is struct with lockfile contents
%    SETLOCK fails if CHECKLOCK returns the presence of a lock
%    BUTTON returns button pressed when a lock was already set
%          'Open read-only','Cancel','Replace lock'
%
% 2007-2013, Alexander Heimel
%

res=0;
lockfile=[];
button = '';

[stat,oldlockfile]=checklock(filename);

if stat==1
  question=[filename ' is locked' ];
  try 
    question=[question ' by user ' oldlockfile.user];
  end
  try 
    question=[question ' on ' oldlockfile.host];
  end
  try 
    question=[question ' at ' oldlockfile.time];
  end
  
 button=questdlg(question, 'File locked','Open read-only','Replace lock','Cancel','Open read-only');
 switch button
   case { 'Open read-only','Cancel'}
     return
   case 'Replace lock'
     % continue
 end
end

lockfilename=getlockfilename( filename);
fid=fopen(lockfilename,'w');
if fid==-1
    try
        delete(lockfilename)
        fid=fopen(lockfilename,'w');
    end
end


if fid==-1 
  errormsg(['failed to open lockfile ' lockfilename ]);
  return;
end

[y,m,d,h,mi,s] = datevec(now); % can be done more direct in newer releases but not in 5.3


time=sprintf('%04d-%02d-%02d %02d:%02d:%02d',y,m,d,h,mi,fix(s));

fprintf(fid,'user=%s\n' ,user );
fprintf(fid,'host=%s\n', host );
fprintf(fid,'time=%s\n', time );

stat=fclose(fid);

if stat==0
  [res,lockfile]=checklock( filename );
end


  
