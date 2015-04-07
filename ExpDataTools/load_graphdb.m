function [db,filename]=load_graphdb( create )
%LOAD_GRAPHDB loads graph_db
%
%  [DB,FILENAME] = LOAD_GRAPHDB( CREATE )
%     if CREATE is true, create new database if it doesn't exist
%
% 2007-2014, Alexander Heimel
%

if nargin<1
    create = false;
end

[db,filename]=load_expdatabase('graphdb',[],create);

% % temporarily add add2graph field % 2013-03-22
% if ~isfield(db,'add2graph')
%     for i=1:length(db)
%         db(i).add2graph = '';
%     end
%     stat = checklock(filename);
%     if stat~=1
%         filename = save_db(db,filename,'');
%         rmlock(filename);
%     end
% end
% 
% % temporarily add limit field % 2013-04-23
% if ~isfield(db,'limit')
%     for i=1:length(db)
%         db(i).limit = '';
%     end
%     stat = checklock(filename);
%     if stat~=1
%         filename = save_db(db,filename,'');
%         rmlock(filename);
%     end
% end
if isempty(db)
    return
end

db_empty = load(fullfile(fileparts(which('graph_db')), 'graphdb_empty'));
db_empty = db_empty.db;
[db,changed] = structconvert(db,db_empty);
if changed
    save(filename,'db');
end
