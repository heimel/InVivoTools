function sync2otherslices(record,index)
%disp('ANALYZETPSTACK: syncing with other open slices');

% get other open stacks
figs = get(0,'Children');
cur_fig = gcf;
for f = setdiff(figs,cur_fig)' % all figs except for current
    figname = get(f,'Name');
    if ~strcmp(figname(1:min(8,end)),'Analyze:')
        continue;
    end
    
    other_ud = get(f,'userdata');
    % check if same stack
    if ~strcmp(other_ud.record.mouse,record.mouse) && ...
            strcmp(other_ud.record.stack,record.stack)
        continue
    end
    other_v = find([other_ud.celllist.index] == index);
    if isempty(other_v)
        continue;
    end
    set(ft(f,'celllist'),'value',other_v);
    
    
    analyzetpstack('remoteCallCelllist',[],f);
    
end %figures f
figure(cur_fig);



function obj = ft(fig, name)
obj = findobj(fig,'Tag',name);
