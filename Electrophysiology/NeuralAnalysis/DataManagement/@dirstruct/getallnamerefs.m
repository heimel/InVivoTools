function NR = getallnamerefs(cksds)

%  NR = GETALLNAMEREFS(MYDIRSTRUCT)
%
%  Returns a structure with all of the name/ref pairs contained in the 
%  directories associated with the dirstruct MYDIRSTRUCT.
%
%  See also:  DIRSTRUCT

NR = cksds.nameref_list;
