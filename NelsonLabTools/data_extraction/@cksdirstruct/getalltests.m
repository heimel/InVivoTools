function t = getalltests(cksds)

%  T = GETALLTESTS(MYCKSDIRSTRUCT)
%
%  Returns a list of all of the test directories associated with the 
%  cksdirstruct MYCKSDIRSTRUCT.  Note that this routine does not update the
%  directory structure.
%
%  See also:  CKSDIRSTRUCT

t = cksds.dir_list;
