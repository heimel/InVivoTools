function newra = newcontextmenu(ra)

%  NEWRA = NEWCONTEXTMENU(RA)
%
%  Creates a new contextmenu for the RASTER object RA.
%
%  See also:  ANALYSIS_GENERIC/NEWCONTEXTMENU

cb = 'agcontextmenucallback(analysis_generic([],[],[]))';

p = getparameters(ra);

cmenu = contextmenu(ra);
ra.analysis_generic = newcontextmenu(ra.analysis_generic);
if contextmenu(ra)~=cmenu,  % a_g made a new menu, so add our stuff
   cmenu = contextmenu(ra);
     normpsth=uimenu(cmenu,'label','normalize');
       yes=uimenu(normpsth,'label','yes','callback',cb);
       no =uimenu(normpsth,'label','no' ,'callback',cb);
       if p.normpsth==1,set(yes,'checked','on');set(no,'checked','off');end;
       if p.normpsth==0,set(yes,'checked','off');set(no,'checked','on');end;
     axessameheight=uimenu(cmenu,'label','axes same height');
       yes=uimenu(axessameheight,'label','yes','callback',cb);
       no=uimenu(axessameheight,'label','no','callback',cb);
     showvar=uimenu(cmenu,'label','show variance');
       yes=uimenu(showvar,'label','yes','callback',cb);
       no =uimenu(showvar,'label','no' ,'callback',cb);
       if p.showvar==1,set(yes,'checked','on');set(no,'checked','off');end;
       if p.showvar==0,set(yes,'checked','off');set(no,'checked','on');end;
     psthmode=uimenu(cmenu,'label','psth mode:');
       bars=uimenu(psthmode,'label','bars','callback',cb);
       lines =uimenu(psthmode,'label','lines' ,'callback',cb);
       if p.psthmode==0,set(bars,'checked','on');set(lines,'checked','off');end;
       if p.psthmode==1,set(bars,'checked','off');set(lines,'checked','on');end;
     psthocc=uimenu(cmenu,'label','psth occupies ...');
       t1=uimenu(psthocc,'label','0%','callback',cb);
       t1=uimenu(psthocc,'label','25%','callback',cb);
       t1=uimenu(psthocc,'label','50%','callback',cb);
       t1=uimenu(psthocc,'label','75%','callback',cb);
       t1=uimenu(psthocc,'label','100%','callback',cb);
      configuremenu(ra);
end;

newra = ra;
