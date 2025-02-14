function [newtc,b] = handlecontextmenu(tc, obj, fig)

%  Part of the NeuralAnalysis package
%
%  [NEWTC,B] = HANDLECONTEXTMENU(TUNING_CURVEOBJ, MENUOBJ, FIG)
%
%  Handles a contextmenu selection for this object.  B is 1 if the routine
%  handled the action, or 0 otherwise.  MENUOBJ is the menu graphics object
%  corresponding to the menu selection that was made, and FIG is the figure
%  where the ag resides.  NEWTC returns the new TUNING_CURVE object.
%
%  See also:  TUNING_CURVE ANALYSIS_GENERIC/HANDLECONTEXTMENU
upd=0;
disp(get(obj,'label'));
[tc, b]=handlecontextmenuag(tc,obj,fig);
if ~b,
  par = get(obj,'parent'); p = getparameters(tc);
  switch(get(par,'label')),
        case 'Drawing prefs',
                if strcmp(get(obj,'label'),'Show rasters'),
                   p.showrast = 1-p.showrast; upd=1;
                elseif strcmp(get(obj,'label'),'Draw spontaneous activity'),
                   p.drawspont = 1-p.drawspont;  upd=1; 
                end;
        case 'Analysis parameters',
                if strcmp(get(obj,'label'),'time res for rasters...'),
                   answer = -1;
                   while answer == -1,
                      defstr = mat2str([p.res]);
                      answer=inputdlg({'New time res:'},...
                         'Input new time res',1,{defstr});
                      if ~isempty(answer),
                              try, eval(['v = ' answer{1} ';']);
                                 p.res=v(1);
                                 tc = setparameters(tc,p);
                                 answer = 1; upd = 0;
                              catch, answer = -1; end;
                      else, answer = 1;
                      end;
                   end;
                   disp('this is time res');
                elseif strcmp(get(obj,'label'),'interpolation...'),
                   answer = -1;
                   while answer == -1,
                      defstr = mat2str([p.interp ]);
                      answer=inputdlg({'New interpolation factor:'},...
                         'Input new interpolation factor',1,{defstr});
                      if ~isempty(answer),
                              try, eval(['v = ' answer{1} ';']);
                                 p.interp(1)=v(1);
                                 tc = setparameters(tc,p);
                                 answer = 1; upd = 0;
                              catch, answer = -1; end;
                      else, answer = 1;
                      end;
                   end;
                   disp('this is interpolation');
                elseif strcmp(get(obj,'label'),'interval [start stop]...'),
                   answer = -1;
                   while answer == -1,
                      defstr = mat2str([p.interval(1) p.interval(2)]);
                      answer=inputdlg({'New interval [start stop ]:'},...
                         'Input new interval',1,{defstr});
                      if ~isempty(answer),
                              %try,
                                 eval(['v = ' answer{1} ';']);
                                 p.interval(1)=v(1); p.interval(2)=v(2);
                                 tc = setparameters(tc,p);
                                 answer = 1; upd = 0;
                              %catch, answer = -1; end;
                      else, answer = 1;
                      end;
                   end;
                   disp('this is interval');
                end;
        case 'interval method',
                if strcmp(get(obj,'label'),'[stim_start+start stim_stop-stop]'),
                   p.int_meth = 0; upd = 1;
                elseif strcmp(get(obj,'label'),'[stim_start+start stim_start+stop]'),
                   p.int_meth = 1; upd = 1;
                end;
        otherwise, b = 0;
  end;
else, disp('handled by analysis_generic.');
end;

if upd, tc = setparameters(tc,p); end;

newtc = tc;

