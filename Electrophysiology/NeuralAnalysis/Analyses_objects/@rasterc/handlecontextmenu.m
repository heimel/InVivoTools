function [newra,b] = handlecontextmenu(ra, obj, fig)

%  Part of the NeuralAnalysis package
%  
%  [NEWRA,B] = HANDLECONTEXTMENU(RASTEROBJ, MENUOBJ, FIG)
%
%  Handles a contextmenu selection for this object.  B is 1 if the routine
%  handled the action, or 0 otherwise.  MENUOBJ is the menu graphics object
%  corresponding to the menu selection that was made, and FIG is the figure
%  where the ag resides.  NEWRA returns the new RASTER object.
%
%  See also:  RASTER ANALYSIS_GENERIC/HANDLECONTEXTMENU
upd=0;
disp(get(obj,'label'));
[ra, b]=handlecontextmenuag(ra,obj,fig);
if ~b,
  par = get(obj,'parent'); p = getparameters(ra);
  switch(get(par,'label')),
	case 'normalize',
		if strcmp(get(obj,'label'),'yes'), p.normpsth = 1;
		else, p.normpsth = 0; end; upd=1;
	case 'show variance',
		if strcmp(get(obj,'label'),'yes'), p.showvar = 1;
		else, p.showvar = 0; end;upd=1;
	case 'psth mode:',
		if strcmp(get(obj,'label'),'bars'), p.psthmode= 0;
		else, p.psthmode = 1; end;upd=1;
	case 'psth occupies ...',
		upd=1;
		switch get(obj,'label'),
			case '0%', p.fracpsth = 0;
			case '25%', p.fracpsth = 0.25;
			case '50%', p.fracpsth = 0.50;
			case '75%', p.fracpsth = 0.75;
			case '100%',p.fracpsth = 1;
		end;
	otherwise, b = 0;
  end;
else, disp('handled by analysis_generic.');
end;

if upd, ra = setparameters(ra,p); end;

newra = ra;
