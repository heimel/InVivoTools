function [newmdd,b] = handlecontextmenu(mdd, obj, fig)

%  Part of the NeuralAnalysis package
%
%  [NEWMDD,B] = HANDLECONTEXTMENU(MDD, MENUOBJ, FIG)
%
%  Handles a contextmenu selection for this object.  B is 1 if the routine
%  handled the action, or 0 otherwise.  MENUOBJ is the menu graphics object
%  corresponding to the menu selection that was made, and FIG is the figure
%  where the ag resides.  NEWMDD returns the new MEASUREDDATADISPLAY object.
%
%  See also:  MEASUREDDATADISPLAY, ANALYSIS_GENERIC/HANDLECONTEXTMENU
upd=0;
disp(get(obj,'label'));
[mdd, b]=handlecontextmenuag(mdd,obj,fig);
if ~b,
  par = get(obj,'parent');
  p = getparameters(mdd); I = getinputs(mdd);
  %try, ppar=get(par,'parent'); catch ppar=[]; end;
  %if ~isempty(ppar)&(ppar==contextmenu(mdd)),
     % sub-sub menus
     %case '
  if strcmp(get(par,'type'),'uimenu'),
    switch(get(par,'label')),
        case {'beginning of trace','end of trace',...
              'beginning of trace interval',...
              'end of trace interval', 'beginning of next trace interval',...
               'end of prev trace interval','beginning of prev trace interval'},
                   mdd = setviewplace(mdd,get(par,'label'),get(obj,'userdata'));
        case 'move viewpoint',
                if strcmp(get(obj,'label'),'half frame forward'),
                   mdd = setviewplace(mdd,'half frame forward');
                elseif strcmp(get(obj,'label'),'full frame forward'),
                   mdd = setviewplace(mdd,'full frame forward');
                elseif strcmp(get(obj,'label'),'end'),
                   mdd = setviewplace(mdd,'end');
                elseif strcmp(get(obj,'label'),'half frame backward'),
                   mdd = setviewplace(mdd,'half frame backward');
                elseif strcmp(get(obj,'label'),'full frame backward'),
                   mdd = setviewplace(mdd,'full frame backward');
                elseif strcmp(get(obj,'label'),'beginning'),
                   mdd = setviewplace(mdd,'beginning');
                end;
        case 'separation method',
              upd = 1;
              val=get(obj,'userdata');
              switch get(obj,'label'),
                 case 'fraction of max-min',
                    p.displayParams(val).sepmeth=0;
                 case 'fraction of standard deviation',
                    p.displayParams(val).sepmeth=1;
                 case 'constant offset',
                    p.displayParams(val).sepmeth=2;
              end;
        case 'line',
              upd = 1;
              val = get(obj,'userdata'),
              switch get(obj,'label'),
                 case 'draw line',
                    p.displayParams(val).line= 1-p.displayParams(val).line;
                 case 'set line size',
                  answer=-1;
                  while answer==-1,
                    defstr = mat2str(p.displayParams(val).linesz);
                    answer=inputdlg({'New line size:'},...
                                    'New line size:',1,{defstr});
                    if ~isempty(answer),
                      try, eval(['p.displayParams(val).linesz=' answer{1} ';']);
                           mdd = setparameters(mdd,p);
                           answer = 1; upd=0;
                      catch, answer = -1; end;
                    else, answer = 1;
                    end;
                  end;
              end;
        case 'symbols',
             upd =1;
             val = get(obj,'userdata');
             switch get(obj,'label'),
                case 'set symbol',
                  answer=-1;
                  while answer==-1,
                    defstr = (p.displayParams(val).sym);
                    answer=inputdlg({'New symbol:'},...
                                    'New symbol:',1,{defstr});
                    if ~isempty(answer),
                      try, p.displayParams(val).sym=answer{1};
                           mdd = setparameters(mdd,p);
                           answer = 1; upd=0;
                      catch, answer = -1; end;
                    else, answer = 1;
                    end;
                  end;
                case 'set marker size',
                  answer=-1;
                  while answer==-1,
                    defstr = mat2str(p.displayParams(val).markerSize);
                    answer=inputdlg({'New marker size:'},...
                                    'New marker size:',1,{defstr});
                    if ~isempty(answer),
                      try, eval(['p.displayParams(val).markerSize=' answer{1} ';']);
                           mdd = setparameters(mdd,p);
                           answer = 1; upd=0;
                      catch, answer = -1; end;
                    else, answer = 1;
                    end;
                  end;
             end;
        case 'x axis',
             upd = 1;
             switch get(obj,'label'),
             case 'auto',
                  p.xaxis = 'auto';
             case 'set to ...',
                  answer=-1;
                  while answer==-1,
                    if ischar(p.xaxis)&strcmp(p.xaxis,'auto'),
                       defstr = mat2str(p.xauto);
                    else, defstr = mat2str(p.xaxis); end;
                    answer=inputdlg({'New x axis [xmin xmax]:'},...
                                    'Input new xaxis:', 1,{defstr});
                    if ~isempty(answer),
                      try, eval(['p.xaxis = ' answer{1} ';']);
                           mdd = setparameters(mdd,p);
                           answer = 1; upd=0;
                      catch, answer = -1; end;
                    else, answer = 1;
                    end;
                  end;
             case 'xaxis auto setting',
                  answer=-1;
                  while answer==-1,
                    defstr = mat2str(p.xauto);
                    answer=inputdlg({'New x axis auto [xmin xmax]:'},...
                                    'Input new xauto:', 1,{defstr});
                    if ~isempty(answer),
                      try, eval(['p.xauto = ' answer{1} ';']);
                           mdd = setparameters(mdd,p);
                           answer = 1;
                      catch, answer = -1; end;
                    else, answer = 1;
                    end;
                  end;
             end;
        case 'y axis',
             upd = 1;
             switch get(obj,'label'),
             case 'auto',
                  p.yaxis = 'auto';
             case 'set to ...',
                  answer=-1;
                  while answer==-1,
                    if ischar(p.yaxis)&strcmp(p.yaxis,'auto'),
                       defstr = mat2str([0 1]);
                    else, defstr = mat2str(p.yaxis); end;
                    answer=inputdlg({'New y axis [ymin ymax]:'},...
                                    'Input new yaxis:', 1,{defstr});
                    if ~isempty(answer),
                      try, eval(['p.yaxis = ' answer{1} ';']);
                           mdd = setparameters(mdd,p);
                           answer = 1; upd = 0;
                      catch, answer = -1; end;
                    else, answer = 1;
                    end;
                  end;
             case 'y axis auto', % not an option yet
             end;
        otherwise,
          switch(get(obj,'label')),
            case 'set separation distance',
              upd = 1; val=get(obj,'userdata');
                  answer=-1;
                  while answer==-1,
                    defstr = mat2str(p.displayParams(val).sepdist);
                    answer=inputdlg({'New separation distance:'},...
                           'New separation distance factor:',1,{defstr});
                    if ~isempty(answer),
                      try, eval(['p.displayParams(val).sepdist='answer{1} ';']);
                           mdd = setparameters(mdd,p);
                           answer = 1; upd=0;
                      catch, answer = -1; end;
                    else, answer = 1;
                    end;
                  end;
            case 'set scaling',
              disp ('scaling...');
              upd = 1; val=get(obj,'userdata');
                  answer=-1;
                  while answer==-1,
                    defstr = mat2str(p.displayParams(val).scaling);
                    answer=inputdlg({'New scaling factor:'},...
                                    'New scaling factor:',1,{defstr});
                    if ~isempty(answer),
                      try,eval(['p.displayParams(val).scaling=' answer{1} ';']);
                           mdd = setparameters(mdd,p);
                           answer = 1; upd=0;
                      catch, answer = -1; end;
                    else, answer = 1;
                    end;
                  end;
            case 'set color',
              upd = 1; val=get(obj,'userdata');
                  answer=-1;
                  while answer==-1,
                    defstr = mat2str(p.displayParams(val).color);
                    answer=inputdlg({'New color:'},...
                                    'New color:',1,{defstr});
                    if ~isempty(answer),
                      try, eval(['p.displayParams(val).color=' answer{1} ';']);
                           mdd = setparameters(mdd,p);
                           answer = 1; upd=0;
                      catch, answer = -1; end;
                    else, answer = 1;
                    end;
                  end;
            case 'draw',
              upd = 1; val=get(obj,'userdata');
              p.displayParams(val).draw = 1-p.displayParams(val).draw;
            otherwise, b = 0;
          end;
    end;
  else,
    switch get(obj,'label'),
        case 'Memory warning at ...',
                  answer=-1;
                  while answer==-1,
                    defstr = num2str(p.memwarning);
                    answer=inputdlg({'New memory warning level'},...
                              'Input new memory warning level:',1,{defstr});
                    if ~isempty(answer),
                      try, eval(['p.memwarning = ' answer{1} ';']);
                           mdd = setparameters(mdd,p);
                           answer = 1; upd = 0;
                      catch, answer = -1; end;
                    else, answer = 1;
                    end;
                  end;
        case 'set offset between traces ...',
                  answer=-1;
                  while answer==-1,
                    defstr = num2str(p.offset);
                    answer=inputdlg({'New offset value'},...
                              'Input new offset value:',1,{defstr});
                    if ~isempty(answer),
                      try, eval(['p.offset = ' answer{1} ';']);
                           mdd = setparameters(mdd,p);
                           answer = 1; upd = 0;
                      catch, answer = -1; end;
                    else, answer = 1;
                    end;
                  end;
        otherwise, b = 0;
    end;
  end;
else, disp('handled by analysis_generic.');
end;

if upd, mdd = setparameters(mdd,p); end;

newmdd = mdd;

