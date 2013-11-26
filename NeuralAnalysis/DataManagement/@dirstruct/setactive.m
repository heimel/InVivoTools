function ncksds = setactive(cksds,adirlist,append)

%  NEWDIRSTRUCT = SETACTIVE(MYDIRSTRUCT, DIRLIST,APPEND)
%
%  Sets the cell list of directories (or single character directory name)
%  to be active in the DIRSTRUCT MYSDIRSTRUCT, and returns a new
%  DIRSTRUCT.  If a directory does not exist, no error is given but the
%  directory is not made active.  If append is 1, then these directories are
%  appended to the list of active directories.  Otherwise, the list of
%  active directories are set to be exactly DIRLIST and no others.

if ischar(adirlist),thedirlist={adirlist};else,thedirlist=adirlist;end;

active_dir_list = intersect(cksds.dir_list,thedirlist);
if append, cksds.active_dir_list=union(active_dir_list,cksds.active_dir_list);
else, cksds.active_dir_list=active_dir_list;
end;
ncksds = cksds;
