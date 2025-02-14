function delete(ag)

%  DELETE(ANALYSIS_GENERIC_OBJ)
%
%  Deletes the analysis_generic object and removes all associated graphics.
%  Removes the object from the figure userdata list as well.
%
%  See also:  ANALYSIS_GENERIC

if ~isempty(ag.where),  % has a figure associated
	ag = repairhandles(ag,ag.where.figure);
	ud = get(ag.where.figure,'userdata');
	if strcmp(class(ud),'cell'),
		for i=1:length(ud),
			if ud{i}==ag, break; end;
		end;
		if ud{i}==ag, %i, ud,
			ud = cat(2,{ud{1:i-1}},{ud{i+1:end}});
			set(ag.where.figure,'userdata',ud);
		end;
	end;
        z=findobj(ag.where.figure,'type','axes','uicontextmenu',ag.contextmenu);
	if ishandle(z), delete(z); end;
	if ishandle (contextmenu(ag)), delete(contextmenu(ag)); end;
else, if ishandle(contextmenu(ag)), delete(contextmenu(ag)); end;	
end;
