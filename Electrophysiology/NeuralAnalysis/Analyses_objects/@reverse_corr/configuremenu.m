function configuremenu(rc)

%  Part of the NeuralAnalysis package
%
%  CONFIGUREMENU(RC)
%
%  Configures the menu options (such as setting checks and enabling/disabling
%  menu options) based on the current parameters and inputs.
%
%  See also:  REVERSE_CORR, SETPARAMETERS

cb = 'agcontextmenucallback(analysis_generic([],[],[]))';

cm = contextmenu(rc);
if ishandle(cm),
  try,
        p = getparameters(rc); I = getinputs(rc);
		if isfield(p,'value')&~isfield(p,'values'), p.values = p.value; end;
        ps = getparameters(I.stimtime(1).stim);
        C = getoutput(rc);
        datatoview = findobj(cm,'label','Data to view...');
           cell = findobj(datatoview,'label','cell');
           slice = findobj(datatoview,'label','slice');
           deleteallchildren(cell); deleteallchildren(slice);
           for i=1:length(I.spikes),
                m=uimenu(cell,'label',int2str(i),'userdata',i,'callback',cb);
                if p.datatoview(1)==i, set(m,'checked','on'); end;
           end;
           offsets = p.interval(1):p.timeres:p.interval(2);
           if length(offsets)==1, offsets = [p.interval(1) p.interval(2)]; end;
           for i=1:length(offsets)-1,
%             disp('here'),
%             sum(C.reverse_corr.bins{1}{p.datatoview(1)}(i,:));
             m=uimenu(slice,'label',...
             [ int2str(i) ': [' num2str(offsets(i)) ', ' num2str(offsets(i+1)) '], ' int2str(sum(C.reverse_corr.bins{1}{p.datatoview(1)}(i,:))) ' spikes'] ...
                    ,'userdata',i,'callback',cb);
             if p.datatoview(2)==i, set(m,'checked','on'); end;
           end;
        feature = findobj(cm,'label','feature');
           absbright=findobj(feature,'label','absolute brightness');
           tempbd=findobj(feature,'label','temporal brightness difference');
           tempbdabs=...
              findobj(feature,'label','abs value temporal brightness difference');
           set(absbright,'checked','off'); set(tempbd,'checked','off');
           set(tempbdabs,'checked','off');
           if p.feature==0, set(absbright,'checked','on');
           elseif p.feature==3, set(absbright,'checked','on');
           elseif p.feature==4, set(absbright,'checked','on'); end;
        bg = findobj(cm,'label','Background color');
        deleteallchildren(bg);
        if isa(I.stimtime(1).stim,'blinkingstim'), set(bg,'enable','off'); end;
        if isa(I.stimtime(1).stim,'stochasticgridstim'),
          for i=1:size(ps.values,1),
             m=uimenu(bg,'label',[int2str(i) ':' mat2str(ps.values(i,:)) ],'callback',cb,'userdata',i);
             if p.bgcolor==i, set(m,'checked','on'); end;
          end;
        end;
        clickbehav = findobj(cm,'label','Clicking...');
           zooms = findobj(clickbehav,'label','zooms');
           selects = findobj(clickbehav,'label','selects');
           set(zooms,'checked','off');set(selects,'checked','off');
           if p.clickbehav==0,set(zooms,'checked','on');
           elseif p.clickbehav==1, set(selects,'checked','on'); end;
  end;
end;
