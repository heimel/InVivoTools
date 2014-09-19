function s = setparameters(S,p)

%  SETPARAMETERS - Set the parameters for a stimulus
%
%  NEWS = SETPARAMETERS(S,P)
%
%  Sets the parameters of S to P.  The loaded status is preserved.
%  S is unloaded because it is assumed it will be discarded.
%
%  See also:  GETPARAMETERS

cl = class(S);
l = isloaded(S);

S = unloadstim(S);
eval(['s = ' cl '(p);']);
if l, s = loadstim(s); end;
