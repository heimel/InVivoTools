function newpc = newcontextmenu(pc)

%  NEWPC = NEWCONTEXTMENU(PC)
%
%  Creates a new contextmenu for the PERIODIC_CURVE object PC.
%
%  See also:  ANALYSIS_GENERIC/NEWCONTEXTMENU

cb = 'agcontextmenucallback(analysis_generic([],[],[]))';

p = getparameters(pc);

cmenu = contextmenu(pc);
pc.analysis_generic = newcontextmenu(pc.analysis_generic);
if contextmenu(pc)~=cmenu,  % a_g made a new menu, so add our stuff
   cmenu = contextmenu(pc);
     drawprefs=uimenu(cmenu,'label','Display prefs');
     analparms=uimenu(cmenu,'label','Analysis parameters');
     configuremenu(pc);
end;

newpc = pc;

