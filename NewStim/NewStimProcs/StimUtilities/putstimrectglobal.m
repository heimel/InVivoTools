function S = putstimrectglobal(stim,varargs)

%  Part of the NewStim package
%
%  [] = PUTPARAMINGLOBAL(STIM,{'paramname',PNAME,'globvar',GLOBVAR})
%
%  This function looks at the parameters of STIM, and, if a field called PNAME
%  exists, the value of that field is appended to the global variable GLOBVAR.
  % check args
if ~(strcmp(varargs{1},'paramname')&strcmp(varargs{3},'globvar'));
        error('Input arguments not correct; see help');
end;

eval(['global ' varargs{4}]);

p = getparameters(stim);
if isfield(p,varargs{2}),
	eval([varargs{4} ' = cat(2,' varargs{4} ',{p.' varargs{2} '});']);
end;
S = [];
