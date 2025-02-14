function [newag,b] = handlecontextmenuag(ag, obj, fig)

%  [NEWAG,B] = HANDLECONTEXTMENUAG(ANALYSIS_GENERIC, MENUOBJ, FIG)
%
%  Handles a contextmenu selection for this object.  B is 1 if the routine
%  handled the action, or 0 otherwise.  MENUOBJ is the menu graphics object
%  corresponding to the menu selection that was made, and FIG is the figure
%  where the ag resides.  NEWAG returns the new ANALYSIS_GENERIC object.
%
%  See also:  ANALYSIS_GENERIC

b = 1;
disp(get(obj,'label'));
switch(get(obj,'label')),
	case {'another figure','this figure','new figure'},
	   ag=docopymove(ag,get(obj,'label'),get(get(obj,'parent'),'label'));
	case 'is fixed', % switch to fixed
		w = ag.where;
		if ~isempty(w),
			if strcmp(w.units,'normalized'),
			   where.figure=w.figure;where.units='pixels';
			   where.rect = normalized2pixels(w.figure,w.rect);
			   ag = setlocation(ag,where);
			end;
		end;
	case 'resizes', % switch to normalized
		w = ag.where;
		if ~isempty(w),
			if strcmp(w.units,'pixels'),
			   where.figure=w.figure;where.units='normalized';
			   where.rect = pixels2normalized(w.figure,w.rect);
			   ag = setlocation(ag,where);
			end;
		end;
	case 'Delete',
		delete(ag);
	otherwise, b = 0;
end;

newag = ag;

function nag = docopymove(ag, locstr, opstr)
locstr,strcmp('new figure', locstr),
nag = []; finish = 1;
switch(locstr),
	case 'this figure', % do nothing
	case 'another figure', % select other figure
		z = sort(get(0,'children'));
		l=num2cell(int2str(z));
		if ~isempty(l),
			[s,v]=listdlg('PromptString','Select a figure',...
				'SelectionMode','single','ListString',l);
			if ~isempty(s),figure(z(s));drawnow;else, finish=0; end;
		else, figure; drawnow;
		end;
	case 'new figure',
		5,
		figure; drawnow;
end; % switch
if finish,
  where = getloc(ag.where),
  if strcmp(opstr,'Move to ...'),
	nag = setlocation(ag,where);
  else,
	nag = ag;
	c = class(ag);
	eval(['newagobj=' c '(getinputs(ag),getparameters(ag),where);']);
  end;
else, nag = ag;
end;

location(nag),

function where = getloc(oldwhere)
where = oldwhere;
try,
	ax=axes('position',[1 1 1 1],'visible','off');
	[x,y]=ginput(1);
	delete(ax);
	xy1 = get(gcf,'CurrentPoint');
	rct = rbbox;
	xy2 = get(gcf,'CurrentPoint');
	xmin = min([xy1(1) xy2(1)]);
	xmax = max([xy1(1) xy2(1)]);
	ymin = min([xy1(2) xy2(2)]);
	ymax = max([xy1(2) xy2(2)]);
	w = xmax-xmin; h = ymax - ymin;
	posrect = [xmin ymin w h],
	if strcmp(oldwhere.units,'normalized'),
		posrect = pixels2normalized(gcf,posrect);
	end;
	where.figure=gcf;where.units=oldwhere.units;
	where.rect=posrect;
end;
