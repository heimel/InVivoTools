function [newrc,b] = handlecontextmenu(rc, obj, fig)

%  Part of the NeuralAnalysis package
%
%  [NEWRC,B] = HANDLECONTEXTMENU(REVERSE_CORROBJ, MENUOBJ, FIG)
%
%  Handles a contextmenu selection for this object.  B is 1 if the routine
%  handled the action, or 0 otherwise.  MENUOBJ is the menu graphics object
%  corresponding to the menu selection that was made, and FIG is the figure
%  where the ag resides.  NEWRC returns the new REVERSE_CORR object.
%
%  See also:  REVERSE_CORR ANALYSIS_GENERIC/HANDLECONTEXTMENU
upd=0;
disp(get(obj,'label'));
[rc, b]=handlecontextmenuag(rc,obj,fig);
if ~b,
  par = get(obj,'parent'); p = getparameters(rc); cm = contextmenu(rc);
  offsets = p.interval(1):p.timeres:p.interval(2);
  if length(offsets)==1, offsets = [p.interval(1) p.interval(2)]; end;

  if cm==par,
     if strcmp(get(obj,'label'),'Intervals...'),
        answer = -1;
        while answer == -1,
          defstr = mat2str([p.interval(1) p.interval(2) p.timeres]);
          answer=inputdlg({'New interval [start stop tres]:'},...
                  'Input new intervals',1,{defstr});
          if ~isempty(answer),
              try, eval(['v = ' answer{1} ';']);
                   p.interval(1)=v(1); p.interval(2)=v(2); p.timeres=v(3);
                   rc = setparameters(rc,p);
                   answer = 1; upd = 0;
              catch, answer = -1; end;
          else, answer = 1;
          end;
        end;
     end;
  else,
    switch(get(par,'label')),
        case 'slice',
                dtv = get(obj,'userdata');
                if dtv~=p.datatoview(2),
                   p.datatoview(2) =  dtv; upd = 1;
                end;
        case 'cell',
                dtv = get(obj,'userdata');
                if dtv~=p.datatoview(1),
                   p.datatoview(1) = dtv; upd = 1;
                end;
        case 'Data to view...',
                if strcmp(get(obj,'label'),'psuedoscreen'),
                   answer = -1;
                   while answer == -1,
                     defstr = mat2str([p.pseudoscreen]);
                     answer=inputdlg({'Pseudoscreen [xstart ystart xstop ystop]:'},...
                         'Pseudoscreen',1,{defstr});
                     if ~isempty(answer),
                         try, eval(['v = ' answer{1} ';']);
                         p.pseudoscreen=v;
                         rc = setparameters(rc,p);
                         answer = 1; upd = 0;
                         catch, answer = -1; end;
                     else, answer = 1;
                     end;
                   end;
                    %disp('this is pseudoscreen.');
                elseif strcmp(get(obj,'label'),'image gain'),
                   answer = -1;
                   while answer == -1,
                     defstr = mat2str([p.gain]);
                     answer=inputdlg({'Image gain:'},...
                         'gain',1,{defstr});
                     if ~isempty(answer),
                         try, eval(['v = ' answer{1} ';']);
                         p.gain=v;
                         rc = setparameters(rc,p);
                         answer = 1; upd = 0;
                         catch, answer = -1; end;
                     else, answer = 1;
                     end;
                   end;
                    %disp('this is image gain.');
                elseif strcmp(get(obj,'label'),'image mean'),
                   answer = -1;
                   while answer == -1,
                     defstr = mat2str([p.immean]);
                     answer=inputdlg({'Image mean:'},...
                         'image mean',1,{defstr});
                     if ~isempty(answer),
                         try, eval(['v = ' answer{1} ';']);
                         p.immean=v;
                         rc = setparameters(rc,p);
                         answer = 1; upd = 0;
                         catch, answer = -1; end;
                     else, answer = 1;
                     end;
                   end;
                    %disp('this is image mean.');
                elseif strcmp(get(obj,'label'),'feature mean'),
                   answer = -1;
                   while answer == -1,
                     defstr = mat2str([p.feamean]);
                     answer=inputdlg({'Feature mean:'},...
                         'feature mean',1,{defstr});
                     if ~isempty(answer),
                         try, eval(['v = ' answer{1} ';']);
                         p.feamean=v;
                         rc = setparameters(rc,p);
                         answer = 1; upd = 0;
                         catch, answer = -1; end;
                     else, answer = 1;
                     end;
                   end;
                    %disp('this is image mean.');
                end;
        case 'Background color',
           g = get(obj,'userdata');
           if p.bgcolor~=g, p.bgcolor = g; upd = 1; end;  
           disp('this is background color.');
        case 'Correlation feature',
             switch (get(obj,'label')),
               case 'absolute brightness',
                  if p.feature~=0, p.feature = 0; upd = 1; end;
               case 'temporal brightness difference',
                  if p.feature~=3, p.feature = 3; upd = 1; end;
               case 'abs value temporal brightness difference',
                  if p.feature~=4, p.feature = 4; upd = 1; end;
             end;
        case 'Clicking...',
              switch (get(obj,'label')),
                case 'zooms',
                  if p.clickbehav~=0, p.clickbehav=0; upd = 1; end;
                case 'selects',
                  if p.clickbehav~=1, p.clickbehav=1; upd = 1; end;
              end;
        otherwise, b = 0;
    end;
  end;
else, disp('handled by analysis_generic.');
end;

if upd, rc = setparameters(rc,p); end;

newrc = rc;

