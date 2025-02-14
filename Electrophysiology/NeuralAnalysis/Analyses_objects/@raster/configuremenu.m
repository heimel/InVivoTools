function configuremenu(ra)

%  Part of the NeuralAnalysis package
%
%  CONFIGUREMENU(RA)
%
%  Configures the menu options (such as setting checks and enabling/disabling
%  menu options) based on the current parameters and inputs.
%
%  See also:  RASTER, SETPARAMETERS
cm = contextmenu(ra);
if ishandle(cm),
  try,
	p = getparameters(ra);
        c = findobj(cm,'label','normalize');
	y = findobj(c,'label','yes');
	n = findobj(c,'label','no');
	if p.normpsth==1, set(y,'checked','on'); set(n,'checked','off');
	else, set(n,'checked','on'); set(y,'checked','off'); end;
        c = findobj(cm,'label','axes same height');
        y = findobj(c,'label','yes');
        n = findobj(c,'label','no');
        if p.axessameheight==1, set(y,'checked','on'); set(n,'checked','off');
        else, set(n,'checked','on'); set(y,'checked','off'); end;
        c = findobj(cm,'label','show variance');
	y = findobj(c,'label','yes');
	n = findobj(c,'label','no');
	if p.showvar==1, set(y,'checked','on'); set(n,'checked','off');
	else, set(n,'checked','on'); set(y,'checked','off'); end;
        c = findobj(cm,'label','psth mode:');
	b = findobj(c,'label','bars');
	l = findobj(c,'label','lines');
	if p.psthmode==1, set(l,'checked','on'); set(b,'checked','off');
	else, set(b,'checked','on'); set(l,'checked','off'); end;
        c = findobj(cm,'label','psth occupies ...');
	m = findobj(c,'label','0%');
	if p.fracpsth==0,set(m,'checked','on');else,set(m,'checked','off');end;
	m = findobj(c,'label','25%');
	if p.fracpsth==.25,set(m,'checked','on');else,set(m,'checked','off');end;
	m = findobj(c,'label','50%');
	if p.fracpsth==.50,set(m,'checked','on');else,set(m,'checked','off');end;
	m = findobj(c,'label','75%');
	if p.fracpsth==.75,set(m,'checked','on');else,set(m,'checked','off');end;
	m = findobj(c,'label','100%');
	if p.fracpsth==1,set(m,'checked','on');else,set(m,'checked','off');end;
  end;	
end;
