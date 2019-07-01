%function create_jsons_from_all_experimentdb
%CREATE_JSONS_FROM_ALL_EXPERIMENTDB
%
% 2019, Alexander Heimel

databasepath = expdatabasepath;

% first test databases in topfolder
d = dir(fullfile(databasepath,'*test*.mat'));

for i=1:length(d)
    db = [];
    logmsg(['Working on ' d(i).name]);
    load(fullfile(databasepath,d(i).name));
    create_json_from_experimentdb(db,false,false);
end %i
