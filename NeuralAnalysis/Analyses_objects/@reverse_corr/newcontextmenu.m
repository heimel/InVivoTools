function newrc = newcontextmenu(rc)

%  NEWRC = NEWCONTEXTMENU(RC)
%
%  Creates a new contextmenu for the REVERSE_CORR object RC.
%
%  See also:  ANALYSIS_GENERIC/NEWCONTEXTMENU

cb = 'agcontextmenucallback(analysis_generic([],[],[]))';

%p = getparameters(rc);

cmenu = contextmenu(rc);
rc.analysis_generic = newcontextmenu(rc.analysis_generic);
if contextmenu(rc)~=cmenu,  % a_g made a new menu, so add our stuff
    cmenu = contextmenu(rc);
    datatoview =uimenu(cmenu,'label','Data to view...');
    cell=uimenu(datatoview,'label','cell');
    slice=uimenu(datatoview,'label','slice');
    gain = uimenu(datatoview,'label','image gain','callback',cb);
    immean = uimenu(datatoview,'label','image mean','callback',cb);
    fmean = uimenu(datatoview,'label','feature mean','callback',cb);
    pseudoscreen = uimenu(datatoview,'label','pseudoscreen','callback',cb);
    intervalops=uimenu(cmenu,'label','Intervals...','callback',cb);
    stimparams =uimenu(cmenu,'label','Stimulus parameters');
    bgcolor =uimenu(stimparams,'label','Background color');
    feature =uimenu(stimparams,'label','Correlation feature','callback',cb);
    absbright = uimenu(feature,'label',...
        'absolute brightness','callback',cb);
    tempbd    = uimenu(feature,'label',...
        'temporal brightness difference','callback',cb);
    tempbdabs = uimenu(feature,'label',...
        'abs value temporal brightness difference','callback',cb);
    clickbehav =uimenu(cmenu,'label','Clicking...');
    zooms   =uimenu(clickbehav,'label','zooms','callback',cb);
    selects =uimenu(clickbehav,'label','selects','callback',cb);
    configuremenu(rc);
end;

newrc = rc;

