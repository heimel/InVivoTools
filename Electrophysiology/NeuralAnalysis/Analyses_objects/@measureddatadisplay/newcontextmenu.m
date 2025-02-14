function newmdd = newcontextmenu(mdd)

%  NEWMDD = NEWCONTEXTMENU(MDD)
%
%  Creates a new contextmenu for the MEASUREDDATADISPLAY object MDD.
%
%  See also:  ANALYSIS_GENERIC/NEWCONTEXTMENU

cb = 'agcontextmenucallback(analysis_generic([],[],[]))';

p = getparameters(mdd);

cmenu = contextmenu(mdd);
mdd.analysis_generic = newcontextmenu(mdd.analysis_generic);
if contextmenu(mdd)~=cmenu,  % a_g made a new menu, so add our stuff
   cmenu = contextmenu(mdd);
     thumb=uimenu(cmenu,'label','move viewpoint');
       for_end=uimenu(thumb,'label','beginning','callback',cb);
       for_end=uimenu(thumb,'label','end','callback',cb);
       for_half=uimenu(thumb,'label','half frame forward','callback',cb);
       for_full=uimenu(thumb,'label','full frame forward','callback',cb);
       back_half=uimenu(thumb,'label','half frame backward','callback',cb);
       back_full=uimenu(thumb,'label','full frame backward','callback',cb);
       tracemenu=uimenu(thumb,'label','move viewpoint by trace');
         begoftrace=uimenu(tracemenu,'label','beginning of trace');
         endoftrace=uimenu(tracemenu,'label','end of trace');
         begtraceint=uimenu(tracemenu,'label','beginning of trace interval');
         endtraceint=uimenu(tracemenu,'label','end of trace interval');
         begnextint=uimenu(tracemenu,'label',...
                          'beginning of next trace interval');
         endprevint=uimenu(tracemenu,'label','end of prev trace interval');
         begprevint=uimenu(tracemenu,'label',...
                          'beginning of prev trace interval');
     axismenu=uimenu(cmenu,'label','axes viewing');
       xaxismenu=uimenu(axismenu,'label','x axis','callback',cb);
         xaxisauto=uimenu(xaxismenu,'label','auto','callback',cb);
         xaxisexplict=uimenu(xaxismenu,'label','set to ...','callback',cb);
         axisautosetting=uimenu(xaxismenu,'label','xaxis auto setting',...
                                        'callback',cb);
       yaxismenu=uimenu(axismenu,'label','y axis');
         yaxisauto=uimenu(yaxismenu,'label','auto','callback',cb);
         yaxisexplicit=uimenu(yaxismenu,'label','set to ...','callback',cb);
     memwarn=uimenu(cmenu,'label','Memory warning at ...','callback',cb);
     offset=uimenu(cmenu,'label','set offset between traces ...','callback',cb);
     dp=uimenu(cmenu,'label','display params');
     configuremenu(mdd);
end;

newmdd = mdd;

