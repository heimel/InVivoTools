function g = uigetvarname(p, d)

% Part of the NewStim package
% NAME = UIGETVARNAME(PROMPT, DEFAULT)
%
%  Prompts the user for a variable name until they cancel the window or enter
%  a valid variable name.  PROMPT should be a string prompting the user, and
%  DEFAULT is the default variable name (or use '' for blank).  If the user
%  clicks cancel, then the empty string is returned.

namenotfound=1;
prompt={p}; def = {d};
dlgTitle = 'New script name...';lineNo=1;
while (namenotfound>0),
	answ=inputdlg(prompt,dlgTitle,lineNo,def);
	an = char(answ);
	if isempty(answ), namenotfound = -1; %cancelled
       	elseif isempty(an),
		uiwait(errordlg('Syntax error in name'));
	elseif ~isvarname(an), % syntax err
		uiwait(errordlg('Syntax error in name'));
	else, % okay
	namenotfound = 0;
	end;
end;

if namenotfound==0, g = an; else g = []; end;
