function output = workspace2struct;

% WORKSPACE2STRUCT - Export the current workspace to a structure
%
%  OUTPUT = WORKSPACE2STRUCT
%
%  Saves the local workspace as a structure for easy export.
%  
%  Each variable is added a field to the structure OUTPUT.
%
%  Example:
%     Imagine your workspace has one variable A, equal to 5.
%     output = workspace2struct
%
%       produces
%
%     output = 
%        a: 5
%

varlist = evalin('caller','who');

for i=1:length(varlist)
	myval = evalin('caller',varlist{i});
	eval(['output.' varlist{i} '=myval;']);
	%output = setfield(output,varlist{i},evalin('caller',varlist{i}));
        % why does the line above not work, you ask?  Because when output is
        % you can write output.a = 5; but you can't write
        % output = setfield(output,'a',5); without getting an error
end;

