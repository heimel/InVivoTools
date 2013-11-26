function configuremenu(pc)

%  Part of the NeuralAnalysis package
%
%  CONFIGUREMENU(PC)
%
%  Configures the menu options (such as setting checks and enabling/disabling
%  menu options) based on the current parameters and inputs.
%
%  See also:  PERIODIC_CURVE, SETPARAMETERS

cb = 'agcontextmenucallback(analysis_generic([],[],[]))';

cm = contextmenu(pc);
if ishandle(cm),
  try,
        p = getparameters(pc);
        dispprefs=findobj(cm,'label','Display prefs');
          deleteallchildren(dispprefs);
          uimenu(dispprefs,'label','title...','callback',cb);
          glab={'graph 1','graph 2','graph 3','graph 4'};
          for i=1:4,   
             g=uimenu(dispprefs,'label',glab{i});
               uimenu(g,'label','draw','checked',onoff(p.graphParams(i).draw),'callback',cb);
               htd=uimenu(g,'label','how to draw');
                 uimenu(htd,'label','linear-linear','checked',onoff(p.graphParams(i).howdraw==0),'userdata',0,'callback',cb);
                 uimenu(htd,'label','log-linear','checked',onoff(p.graphParams(i).howdraw==1),'userdata',1,'callback',cb);
                 uimenu(htd,'label','linear-log','checked',onoff(p.graphParams(i).howdraw==2),'userdata',2,'callback',cb);
                 uimenu(htd,'label','log-log','checked',onoff(p.graphParams(i).howdraw==3),'userdata',3,'callback',cb);
               uimenu(g,'label','show standard error','checked',onoff(p.graphParams(i).showstderr),'userdata',10,'callback',cb);
               uimenu(g,'label','show standard deviation','checked',onoff(p.graphParams(i).showstddev),'userdata',11,'callback',cb);
               uimenu(g,'label','show spontaneous activity','checked',onoff(p.graphParams(i).showspont),'userdata',12,'callback',cb);
               wtp=uimenu(g,'label','what to plot');
                 uimenu(wtp,'label','raster showing whole trial plots','checked',onoff(p.graphParams(i).whattoplot==0),'userdata',100,'callback',cb);
                 uimenu(wtp,'label','raster showing cycle-by-cycle whole trial plots',...
                                      'checked',onoff(p.graphParams(i).whattoplot==1),'userdata',101,'callback',cb);
                 uimenu(wtp,'label','raster showing cycle-by-cycle individual stimulus plots',...
                                      'checked',onoff(p.graphParams(i).whattoplot==2),'userdata',102,'callback',cb);
                 uimenu(wtp,'label','total response (f0)','checked',onoff(p.graphParams(i).whattoplot==3),'userdata',103,'callback',cb);
                 uimenu(wtp,'label','total response (f1)','checked',onoff(p.graphParams(i).whattoplot==4),'userdata',104,'callback',cb);
                 uimenu(wtp,'label','total response (f2)','checked',onoff(p.graphParams(i).whattoplot==5),'userdata',105,'callback',cb);
                 uimenu(wtp,'label','total response (f1/f0)','checked',onoff(p.graphParams(i).whattoplot==6),'userdata',106,'callback',cb);
                 uimenu(wtp,'label','total response (f2/f0)','checked',onoff(p.graphParams(i).whattoplot==7),'userdata',107,'callback',cb);
                 uimenu(wtp,'label','total response cycle-by-cycle (f0)','checked',onoff(p.graphParams(i).whattoplot==8),'userdata',108,'callback',cb);
                 uimenu(wtp,'label','total response cycle-by-cycle (f1)','checked',onoff(p.graphParams(i).whattoplot==9),'userdata',109,'callback',cb);
                 uimenu(wtp,'label','total response cycle-by-cycle (f2)','checked',onoff(p.graphParams(i).whattoplot==10),'userdata',110,'callback',cb);
                 uimenu(wtp,'label','total response cycle-by-cycle (f1/f0)','checked',onoff(p.graphParams(i).whattoplot==11),'userdata',111,'callback',cb);
                 uimenu(wtp,'label','total response cycle-by-cycle (f2/f1)','checked',onoff(p.graphParams(i).whattoplot==12),'userdata',112,'callback',cb);
                 uimenu(wtp,'label','ind. stim. response cycle-by-cycle (f0)','checked',onoff(p.graphParams(i).whattoplot==13),'userdata',113,'callback',cb);
                 uimenu(wtp,'label','ind. stim. response cycle-by-cycle (f1)','checked',onoff(p.graphParams(i).whattoplot==14),'userdata',114,'callback',cb);
                 uimenu(wtp,'label','ind. stim. response cycle-by-cycle (f2)','checked',onoff(p.graphParams(i).whattoplot==15),'userdata',115,'callback',cb);
                 uimenu(wtp,'label','ind. stim. response cycle-by-cycle (f1/f0)','checked',onoff(p.graphParams(i).whattoplot==16),'userdata',116,'callback',cb);
                 uimenu(wtp,'label','ind. stim. response cycle-by-cycle (f2/f1)','checked',onoff(p.graphParams(i).whattoplot==17),'userdata',117,'callback',cb);
               whd=uimenu(g,'label','which data...','userdata',200,'callback',cb);
          end;
        analparams=findobj(cm,'label','Analysis parameters');
             deleteallchildren(analparams);
             uimenu(analparams,'label','time res for rasters...','callback',cb);
             uimenu(analparams,'label','lag...','callback',cb);
             uimenu(analparams,'label','paramnames...','callback',cb);
             uimenu(analparams,'label','paramvalues...','callback',cb);
  end;
end;
