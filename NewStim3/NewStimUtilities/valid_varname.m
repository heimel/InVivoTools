function b = validvarname(varname)

%  Part of the NewStim package
%
%  B = VALIDVARNAME(VARNAME)
%
%  Returns 1 if VARNAME is a valid variable name in Matlab, or returns 0
%  otherwise.
%
%  Questions to vanhoosr@brandeis.edu

b=1;
try, eval([varname '=5;']); catch, b=0; end;
