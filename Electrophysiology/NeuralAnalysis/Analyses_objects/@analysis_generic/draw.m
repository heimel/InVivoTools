function t=draw(ag)

%  Part of the NeuralAnalysis package
%
%  DRAW(MYANALYSIS_GENERICOBJ)
%
%  Draws the output associated with the ANALYSIS_GENERIC object
%  MYANALYSIS_GENERICOBJ.
%
%  See also:  ANALYSIS_GENERIC, SETLOCATION

%disp('drawing ag');

where = ag.where;

%if ~isempty(where),
%   if ishandle(where.figure), z=findobj(where.figure,'tag','analysis_generic');
%      for i=1:length(z),
%         if ishandle(z(i))&(get(z(i),'uicontextmenu')==contextmenu(ag)),
%		delete(z(i));end;
%      end;
%   end;
%   figure(where.figure);
%   set(ag.contextmenu,'parent',where.figure);
%   axes('units',where.units,'position',where.rect,...
%	'uicontextmenu',ag.contextmenu,'tag','analysis_generic');
%   set(ag.contextmenu,'userdata',where);
%end;


   %i = findag(ag,where.figure),
   %if i==-1,  % install in figure
   %   ud = get(where.figure,'userdata');
   %   if isempty(ud), set(where.figure,'userdata',{ag});
   %   elseif strcmp(class(ud),'cell'),
   %     set(where.figure,'userdata',cat(2,ud,{ag}));
   %   end;
   %end;
t = 0;
