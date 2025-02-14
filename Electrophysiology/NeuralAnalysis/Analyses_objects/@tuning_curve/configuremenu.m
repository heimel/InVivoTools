function configuremenu(tc)

%  Part of the NeuralAnalysis package
%
%  CONFIGUREMENU(TC)
%
%  Configures the menu options (such as setting checks and enabling/disabling
%  menu options) based on the current parameters and inputs.
%
%  See also:  TUNING_CURVE, SETPARAMETERS

cb = 'agcontextmenucallback(analysis_generic([],[],[]))';

cm = contextmenu(tc);
if ishandle(cm),
  try,
        p = getparameters(tc);
        drawprefs=findobj(cm,'label','Drawing prefs');
             deleteallchildren(drawprefs);
             uimenu(drawprefs,'label','Show rasters',...
                  'checked',onoff(p.showrast),'callback',cb);
             uimenu(drawprefs,'label','Draw spontaneous activity',...
                  'checked',onoff(p.drawspont),'callback',cb);
        analparams=findobj(cm,'label','Analysis parameters');
             deleteallchildren(analparams);
             uimenu(analparams,'label','time res for rasters...','callback',cb);
             uimenu(analparams,'label','interpolation...','callback',cb);
             uimenu(analparams,'label','interval [start stop]...',...
                      'callback',cb);
             im=uimenu(analparams,'label','interval method');
               uimenu(im,'label','[stim_start+start stim_stop-stop]',...
                    'checked',onoff(p.int_meth==0),'callback',cb);
               uimenu(im,'label','[stim_start+start stim_start+stop]',...
                    'checked',onoff(p.int_meth==1),'callback',cb);
  end;
end;
