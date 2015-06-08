function newag = newcontextmenu(ag)

%  NEWAG = NEWCONTEXTMENU(AG)
%
%  Creates a new contextmenu for the ANALYSIS_GENERIC object AG.
%  If the current contextmenu is valid, then no change is made.

if isempty(contextmenu(ag))||~ishandle(contextmenu(ag)),

 cb = 'agcontextmenucallback(analysis_generic([],[],[]))';

 cmenu=uicontextmenu('userdata',location(ag),'tag','analysis_generic');
  copymenu = uimenu(cmenu,'label','Copy to ...');
    thisfigure = uimenu(copymenu,'label','this figure','callback',cb);
    otherfigure= uimenu(copymenu,'label','another figure','callback',cb);
    newfigure  = uimenu(copymenu,'label','new figure','callback',cb);
  movemenu = uimenu(cmenu,'label','Move to ...');
    thisfigure = uimenu(movemenu,'label','this figure','callback',cb);
    otherfigure= uimenu(movemenu,'label','another figure','callback',cb);
    newfigure  = uimenu(movemenu,'label','new figure','callback',cb);
  posmenu = uimenu(cmenu,'label','Position');
    fixedonwind = uimenu(posmenu,'label','is fixed','callback',cb);
    changes     = uimenu(posmenu,'label','resizes','callback',cb);
  deleteopt = uimenu(cmenu,'label','Delete','callback',cb);

 ag.contextmenu = cmenu;
end;

newag = ag;
