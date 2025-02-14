function newag = setlocation(ag, where)

%  Part of the NeuralAnalysis package
%
%  NEWAG = SETLOCATION(ANALYSIS_GENERIC, WHERE)
%
%  Sets the location of an ANALYSIS_GENERIC object to a new location.  WHERE
%  must be a valid set of location parameters (see ANALYSIS_GENERIC) or empty
%  to signify it should not be drawn.
%
%  See also:  ANALYSIS_GENERIC

if ~isempty(where),[good,err] = verifywhere(where);
    if ~good
        error(err);
    end
end

w = ag.where;
if (isempty(w)&&isempty(where))||...
        (~isempty(w)&&~isempty(where)&&...
        w.figure==where.figure&&strcmp(w.units,where.units)&&...
        prod(double(w.rect==where.rect)))
    % exactly the same, so do nothing
    newag = ag;
    return
elseif isempty(w)
    if ~ishandle(contextmenu(ag))
        ag = newcontextmenu(ag);
    end
    figure(where.figure);
    set(contextmenu(ag),'parent',where.figure);
end


if ~isempty(where)&&~ishandle(where.figure)
    figure(where.figure);
end

% check to make sure nothing else is drawn in exactly the same location
match = 0; oldUD = -1;
if ~isempty(where) % check for duplicates, find old UD entry
    ud = get(where.figure,'userdata');
    if iscell(ud)
        for i=1:length(ud)
            try
                w = location(ud{i});
                if w.figure==where.figure&&strcmp(w.units,where.units)&&...
                        prod(w.rect==where.rect)
                    match = 1;
                end
                if w.figure==ag.where.figure&&...
                        strcmp(w.units,ag.where.units)&&...
                        prod(w.rect==ag.where.rect), oldUD = i;
                end
            end
        end
    end
end
if match==1
    error('Error: duplicate analysis_generic.');
end

% fix menus to reflect any new changes
z = contextmenu(ag);
if ~ishandle(z)
    ag = repairhandles(ag,where.figure);
    z = contextmenu(ag);
end
if ishandle(z)
    posmenu = findobj(z,'label','Position');
    fixedonwind = findobj(posmenu,'label','is fixed');
    changes = findobj(posmenu,'label','resizes');
    if strcmp(where.units,'normalized')
        set(changes,'checked','on');
        set(fixedonwind,'checked','off');
    else
        set(changes,'checked','off');
        set(fixedonwind,'checked','on');
    end
end

% if figure has changed, call move and delete old userdata
if ~isempty(ag.where)&&~isempty(where)&&(ag.where.figure~=where.figure)
    if oldUD~=-1, ud = cat(2,{ud{1:oldUD-1}},{ud{oldUD+1:end}});
        set(ag.where.figure,'userdata',ud); oldUD = -1;
    end
    move(ag,ag.where.figure,where.figure);
end

% if setting where to [], delete userdata field and graphics objects
if isempty(where)
    if oldUD~=-1
        ud = cat(2,{ud{1:oldUD-1}},{ud{oldUD+1:end}});
        set(ag.where.figure,'userdata',ud);
        oldUD = -1;
    end
    z = getgraphicshandles(ag);
    for k=1:length(z)
        if ishandle(z(i))
            delete(z(i));
        end
    end
end

ag.where = where;
% since location has changed, update userdata, uicontextmenu and draw
if ishandle(contextmenu(ag))
    set(contextmenu(ag),'userdata',ag.where); 
end
if ~isempty(ag.where)
    if oldUD==-1
        if ~isempty(ud)
            ud=cat(2,ud,{ag});
        else
            ud = {ag};
        end
        set(ag.where.figure,'userdata',ud);
    else
        ud{oldUD} = ag; set(ag.where.figure,'userdata',ud);
    end
    draw(ag);
end

newag = ag;
