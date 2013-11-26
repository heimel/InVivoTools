function T = gettests(cksds,name,ref);

%  T = GETTESTS(MYDIRSTRUCT,'NAME',REF)
%
%  Returns the list of directories associated with the name and reference
%  pair 'NAME' and REF.
%
%  See also:  DIRSTRUCT

g = namerefind(cksds.nameref_str,name,ref);

if g>0,
	T = cksds.nameref_str(g).listofdirs;
else,
	T = [];
end;
