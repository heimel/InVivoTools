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

[db,filename] = load_expdatabase('graphdb',[],create);

if isempty(db)
    return
end

db_empty = load(fullfile(fileparts(which('graph_db')), 'graphdb_empty'));
db_empty = db_empty.db;
[db,changed] = structconvert(db,db_empty);
if changed
    save(filename,'db','-V7');
end
