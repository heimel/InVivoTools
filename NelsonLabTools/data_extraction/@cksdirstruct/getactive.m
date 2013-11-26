function dirlist = getactive(cksds)

%  DIRLIST = GETACTIVE(MYCKSDIRSTRUCT)
%
%  Returns a cell list of the active directories of the CKSDIRSTRUCT object
%  MYCKSDIRSTRUCT.

dirlist = cksds.active_dir_list;
