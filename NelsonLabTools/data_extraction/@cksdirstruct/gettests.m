function T = gettests(cksds,name,ref);

%  T = GETTESTS(MYCKSDIRSTRUCT,'NAME',REF)
%
%  Returns the list of test directories associated with the name and reference
%  pair 'NAME' and REF.
%
%  See also:  CKSDIRSTRUCT

g = namerefind(cksds.nameref_str,name,ref);

if g>0,
	T = cksds.nameref_str(g).listofdirs;
else,
	T = [];
end;
