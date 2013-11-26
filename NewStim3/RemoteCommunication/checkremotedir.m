function b= checkremotedir(pathstr);
%
%  B = CHECKREMOTEDIR (PATHSTR)
%
%  Checks to see if the directory PATHSTR exists, and if not, gives an error
%  message appropriate for remote communications.  B is 1 if the directory
%  exists, and 0 otherwise.
%  
%  See also:  REMOTECOMM, EXIST

pathn=fixpath(pathstr);
fname=[pathn 'runit.m'];
b=(exist(pathn)==7);
if b==0,errordlg('Remote directory does not exist.','Error');end;
