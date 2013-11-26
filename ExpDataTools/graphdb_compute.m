function newud=graphdb_compute( ud)
%GRAPHDB_COMPUTE
%
%   NEWUD=GRAPHDB_COMPUTE( UD)
%
% 2007-2013, Alexander Heimel

newud = ud;

if get(ud.h.filter,'value') % i.e. filter on
    answer = questdlg('Compute entire selection?','Compute selection','Yes','No','No');
else
    answer = 'No';
end

switch answer
    case 'Yes'
        ind = ud.ind;
    case 'No'
        ind = ud.current_record;
end

for i = 1:length(ind)
    record=ud.db(ind(i));
    
    hgraph = [];
    [r,p,filename,hgraph] = call_groupgraph(record,ud.db,hgraph);
    
    [path,filename,ext]=fileparts(filename);
    record.filename=[filename ext];
    
    record.modified=datestr(now);
    if isempty(record.created)
        record.created=record.modified;
    end
    
    % insert analysed record into database
    ud.changed=1;
    ud.db(ind(i))=record;
    set(ud.h.fig,'Userdata',ud);
end
% read analysed record from database into recordform
if ~isfield(ud,'no_callback')
    control_db_callback(ud.h.current_record);
    control_db_callback(ud.h.current_record);
end

newud=ud;
newud.changed=1;




function [r,p,filename,hgraph] = call_groupgraph(record,db,hgraph)

if ~isempty(record.add2graph)
    if strcmp(record.add2graph,record.name)
        msg = 'Record name and add2graph are identical. This would lead to endless loop';
        disp(['GRAPHDB_COMPUTE: ' msg]);
        errordlg(msg,'Compute graph');
    else
        
        ind_add2 = find_record(db,record.add2graph);
        if ~isempty(ind_add2)
            if length(ind_add2)>1
                disp('GRAPH_COMPUTE: Multiple records fit add2graph name. Taking first');
                ind_add2 = ind_add2(1);
            end
            
            [~,~,~,h] = call_groupgraph(db(ind_add2),db,hgraph);
            if ~isempty(h)
                hgraph = h.fig;
            end
        end
    end
end

[r,p,filename,hgraph] = groupgraph(record.groups,record.measures,...
    'style',record.style,'test',record.test,'showpoints',record.showpoints,...
    'color',record.color,'prefax',record.prefax,'spaced',record.spaced,...
    'signif_y',record.signif_y,'grouplabels',record.grouplabels,...
    'measurelabels',record.measurelabels,'extra_options',record.extra_options,...
    'extra_code',record.extra_code,'filename',record.filename,...
    'name',record.name,...
    'path',record.path,'value_per',record.value_per,'ylab',record.ylab,...
    'add2graph_handle',hgraph,'limit',record.limit);
