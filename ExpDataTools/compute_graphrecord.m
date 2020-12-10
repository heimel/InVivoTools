function [record,hgraph] = compute_graphrecord(record,db,hgraph)
%COMPUTE_GRAPHRECORD computes figure from graphrecord
%
%   [record,hgraph] = compute_graphrecord(record,db,hgraph)
%
%         DB is optional database with graphrecords to use if add2graph
%            field is given
%
% 2015-2017, Alexander Heimel

if nargin<3 
    hgraph = [];
end
if nargin<2
    db = [];
end

if isempty(record)
	return
end

if ~isempty(record.add2graph)
    if strcmp(record.add2graph,record.name)
        errormsg('Record name and add2graph are identical. This would lead to endless loop');
    elseif isempty(db)
        errormsg('Graph database was not passed as an argument.')
    else
        ind_add2 = find_record(db,record.add2graph);
        if ~isempty(ind_add2)
            if length(ind_add2)>1
                logmsg('Multiple records fit add2graph name. Taking first');
                ind_add2 = ind_add2(1);
            end
            
            [db(ind_add2),h] = compute_graphrecord(db(ind_add2),db,hgraph);
            if ~isempty(h)
                hgraph = h.fig;
            end
        end
    end
end

[gy,gx,p,filename,hgraph] = groupgraph(record.groups,record.measures,...
    'criteria',record.criteria,...
    'style',record.style,'test',record.test,'showpoints',record.showpoints,...
    'color',record.color,'prefax',record.prefax,'spaced',record.spaced,...
    'signif_y',record.signif_y,'grouplabels',record.grouplabels,...
    'measurelabels',record.measurelabels,'extra_options',record.extra_options,...
    'extra_code',record.extra_code,'filename',record.filename,...
    'name',record.name,...
    'path',record.path,'value_per',record.value_per,'ylab',record.ylab,...
    'add2graph_handle',hgraph,'limit',record.limit);

record.values.gy = gy;
record.values.gx = gx;
record.values.p = p;

[path,filename,ext] = fileparts(filename); %#ok<ASGLU>
record.filename = [filename ext];
record.modified = datestr(now);
if isempty(record.created)
    record.created=record.modified;
end
    

logmsg(['Computed ' struct2char(record,'; ')]);

