function [newag,b] = handlecontextmenu(ag, obj, fig)

%  [NEWAG,B] = HANDLECONTEXTMENU(ANALYSIS_GENERIC, MENUOBJ, FIG)
%
%  Handles a contextmenu selection for this object.  B is 1 if the routine
%  handled the action, or 0 otherwise.  MENUOBJ is the menu graphics object
%  corresponding to the menu selection that was made, and FIG is the figure
%  where the ag resides.  NEWAG returns the new ANALYSIS_GENERIC object.
%
%  See also:  ANALYSIS_GENERIC

[newag,b] = handlecontextmenuag(ag,obj,fig);

