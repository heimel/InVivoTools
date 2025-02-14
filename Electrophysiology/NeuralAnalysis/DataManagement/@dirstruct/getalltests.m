function t = getalltests(cksds)

%  T = GETALLTESTS(MYDIRSTRUCT)
%
%  Returns a list of all of the test directories associated with the 
%  cksdirstruct MYDIRSTRUCT.  Note that this routine does not update the
%  directory structure.
%
%  See also:  DIRSTRUCT

t = cksds.dir_list;
