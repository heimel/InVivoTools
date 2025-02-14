function newtc = newcontextmenu(tc)

%  NEWTC = NEWCONTEXTMENU(TC)
%
%  Creates a new contextmenu for the TUNING_CURVE object TC.
%
%  See also:  ANALYSIS_GENERIC/NEWCONTEXTMENU

cb = 'agcontextmenucallback(analysis_generic([],[],[]))';

p = getparameters(tc);

cmenu = contextmenu(tc);
tc.analysis_generic = newcontextmenu(tc.analysis_generic);
if contextmenu(tc)~=cmenu,  % a_g made a new menu, so add our stuff
   cmenu = contextmenu(tc);
     drawprefs=uimenu(cmenu,'label','Drawing prefs');
     analparms=uimenu(cmenu,'label','Analysis parameters');
     configuremenu(tc);
end;

newtc = tc;

