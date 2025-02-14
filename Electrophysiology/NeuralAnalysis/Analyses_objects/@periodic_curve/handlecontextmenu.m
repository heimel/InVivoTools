function [newpc,b] = handlecontextmenu(pc, obj, fig)

%  Part of the NeuralAnalysis package
%
%  [NEWPC,B] = HANDLECONTEXTMENU(PERIODIC_CURVEOBJ, MENUOBJ, FIG)
%
%  Handles a contextmenu selection for this object.  B is 1 if the routine
%  handled the action, or 0 otherwise.  MENUOBJ is the menu graphics object
%  corresponding to the menu selection that was made, and FIG is the figure
%  where the ag resides.  NEWPC returns the new PERIODIC_CURVE object.
%
%  See also:  PERIODIC_CURVE ANALYSIS_GENERIC/HANDLECONTEXTMENU

glab={'graph 1','graph 2','graph 3','graph 4'};


upd=0;
disp(get(obj,'label'));
[pc, b]=handlecontextmenuag(pc,obj,fig);
if ~b,
  par = get(obj,'parent'); p = getparameters(pc);
  switch(get(par,'label')),
        case 'Display prefs',
                if strcmp(get(obj,'label'),'title...'),
                   answer = -1;
                   while answer == -1,
                      defstr = p.title;
                      answer=inputdlg({'New title:'},...
                         'Input new title',1,{defstr});
                      if ~isempty(answer),
                              try, eval(['v = ' answer{1} ';']);
                                 p.title=v;
                                 pc = setparameters(pc,p);
                                 answer = 1; upd = 0;
                              catch, answer = -1; end;
                      else, answer = 1;
                      end;
                   end;
                   disp('this is title');
                end;
        case 'what to plot',
            ppar = get(par,'parent');
            [dummy,loc]=intersect(glab,get(ppar,'label'));
            if ~isempty(loc),
               g=get(obj,'userdata');
               if g>=100&g<200,
                 p.graphParams(loc),
                 p.graphParams(loc).whattoplot=g-100; upd=1;
				 if p.graphParams(loc).whattoplot==1,
					if isempty(p.graphParams(loc).whichdata),
						p.graphParams(loc).whichdata = 1;
					end;
				 end;
               end;
            end;
        case 'how to draw',
            ppar = get(par,'parent');
            [dummy,loc]=intersect(glab,get(ppar,'label'));
            if ~isempty(loc),
               g=get(obj,'userdata');
               if g>=0&g<100,
                 p.graphParams(loc).howdraw=g; upd=1;
               end;
            end;
        case glab,
            [dummy,loc]=intersect(glab,get(par,'label'));
            if ~isempty(loc),
               switch get(obj,'label'),
                 case 'show standard error',
                    p.graphParams(loc).showstderr=1-p.graphParams(loc).showstderr; upd=1;
                 case 'show standard deviation',
                    p.graphParams(loc).showstddev=1-p.graphParams(loc).showstddev; upd=1;
                 case 'show spontaneous activity',
                    p.graphParams(loc).showspont=1-p.graphParams(loc).showspont; upd=1;
                 case 'draw',
                    p.graphParams(loc).draw=1-p.graphParams(loc).draw; upd=1;
                    p.graphParams(loc).draw,loc,
               end;
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
                                 pc = setparameters(pc,p);
                                 answer = 1; upd = 0;
                              catch, answer = -1; end;
                      else, answer = 1;
                      end;
                   end;
                   disp('this is time res');
                elseif strcmp(get(obj,'label'),'lag...'),
                   answer = -1;
                   while answer == -1,
                      defstr = mat2str([p.lag]);
                      answer=inputdlg({'New lag time:'},...
                         'Input new time lag',1,{defstr});
                      if ~isempty(answer),
                              try, eval(['v = ' answer{1} ';']);
                                 p.lag=v(1);
                                 pc = setparameters(pc,p);
                                 answer = 1; upd = 0;
                              catch, answer = -1; end;
                      else, answer = 1;
                      end;
                   end;
                   disp('this is lag');
                end;
        otherwise, b = 0;
  end;
else, disp('handled by analysis_generic.');
end;

if upd, pc = setparameters(pc,p); end;

newpc = pc;

