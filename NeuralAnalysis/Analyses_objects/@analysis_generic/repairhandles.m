function newag = repairhandles(ag, fig)

%  Part of the NeuralAnalysis package
%
%  NEWAG = REPAIRHANDLES(AG, FIGURE)
%
%  Returns a new ANALYSIS_GENERIC object after attempting to repair the link
%  between the handles of the ANALYSIS_GENERIC object AG in the figure
%  FIGURE.  A disconnection can occur when a figure is saved and then restored.
%  Most of the time, this function is called automatically when the objects
%  detect that there is a problem.  This function is not harmful and will not
%  introduce a disconnection if none exists.

h = findobj(fig,'type','uicontextmenu','tag','analysis');

for i=1:length(h),
   w = get(h(i),'userdata');  % uicontextmenus have where in userdata
   [good,err]=verifywhere(w);
   if good,
      if strcmp(ag.where.units,w.units)&...
                                prod(ag.where.rect==w.rect)&...
                                ag.where.figure==w.figure, % we have match
         ag.contextmenu = h(i);
         if ag.where.figure~=fig, ag.where.figure = fig; end;
      end;
   end;
end;
newag = ag;

%if ishandle(figure),
%	ud = get(figure,'userdata');
%	if strcmp(get(figure,'tag'),'analysis')&strcmp(class(ud),'cell'),
%	   for i=1:length(ud),
%		
%	end;
%end;

