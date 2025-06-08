function [db,changed] = import_folder_into_db(pathname,db,current_record_ind,import_duplicates,verbose)
%import_folder_into_db. Imports json files in folder and subfolders into db
%
%    [DB,CHANGED] = import_folder_into_db(PATHNAME,DB,[CURRENT_RECORD_IND],[IMPORT_DUPLICATES],VERBOSE=false)
%
%    CURRENT_RECORD_IND is index of record after which new records are
%    inserted. If empty, the new records will be added to the end of DB.
%
%    CHANGED is true, if records are inserted. Otherwise it will be false.
%
% 2025, Alexander Heimel

if nargin<5 || isempty(verbose)
    verbose = false;
end
if nargin<4 || isempty(import_duplicates)
    import_duplicates = [];
end
if nargin<3 || isempty(current_record_ind)
    current_record_ind = length(db);
end

imported_db = collect_session_json_files(pathname,'',verbose);

if ~isempty(db)
    imported_db = structconvert(imported_db,db,true);
end

changed = false;
for i=1:length(imported_db)
    [db,inserted,import_duplicates] = import_record_into_db(imported_db(i),db,current_record_ind,import_duplicates);
    if inserted 
        current_record_ind = current_record_ind+1;
        changed = true;
    end
end
