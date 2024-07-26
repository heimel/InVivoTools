function NR = getallnamerefs(cksds)

%  NR = GETALLNAMEREFS(MYCKSDIRSTRUCT)
%
%  Returns a structure with all of the name/ref pairs contained in the 
%  directories associated with the cksdirstruct MYCKSDIRSTRUCT.
%
%  See also:  CKSDIRSTRUCT

NR = cksds.nameref_list;
