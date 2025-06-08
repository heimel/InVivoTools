function [db,changed] = import_file_into_db(filename,db,current_record_ind,import_duplicates)
%import_file_into_db. Imports mat db file or json file into db
%
%    [DB,CHANGED] = import_file_into_db(FILENAME,DB,[CURRENT_RECORD_IND],[IMPORT_DUPLICATES])
%
%    CURRENT_RECORD_IND is index of record after which new records are
%    inserted. If empty, the new records will be added to the end of DB.
%
%    CHANGED is true, if records are inserted. Otherwise it will be false.
%
% 2025, Alexander Heimel

if nargin<4 || isempty(import_duplicates)
    import_duplicates = [];
end
if nargin<3 || isempty(current_record_ind)
    current_record_ind = length(db);
end

changed = false;

if ~exist(filename,'file')
    logmsg(['Could not find file ' filename])
    return
end

if endsWith(filename,'.mat')
    vars = who('-file',filename);
    if ismember('db',vars)
        imported_db = load(filename,'db');
        imported_db = imported_db.db;
    else
        logmsg(['No db in ' filename]);
        return
    end
elseif endsWith(filename,'.json')
    imported_db = jsondecode(fileread(filename));
else
    logmsg(['Unknown extension of file ' filename]);
    return
end

if ~isempty(db)
    imported_db = structconvert(imported_db,db,true);
end

if isempty(imported_db)
    logmsg('No records to import.')
    return
end

for i=1:length(imported_db)
    [db,inserted,import_duplicates] = import_record_into_db(imported_db(i),db,current_record_ind,import_duplicates);
    if inserted 
        current_record_ind = current_record_ind+1;
        changed = true;
    end
end

logmsg(['Imported ' filename ' into database'])
return


