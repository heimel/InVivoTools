function [db,changed,import_duplicates] = import_record_into_db(record,db,current_record_ind,import_duplicates)
%import_record_into_db. Inserts record into db
% 
%   [db,changed,import_duplicates] = import_record_into_db(record,db,current_record_ind,import_duplicates)
%
%
% if IMPORT_DUPLICATE is false, it will not import a duplicate record
%
% 2025, Alexander Heimel

if nargin<4 || isempty(import_duplicates)
    import_duplicates = [];
end
if nargin<3 || isempty(current_record_ind)
    current_record_ind = length(db);
end

changed = false;
if isempty(import_duplicates) || ~import_duplicates
    filt = recordfilter(record);
    ind = find_record(db,filt);
    if ~isempty(ind)
        if isempty(import_duplicates)
            res = questdlg('Duplicate detected. Import duplicates?','Import duplicates','Yes','No','No');
            switch res
                case 'Yes'
                    import_duplicates = true;
                case 'No'
                    import_duplicates = false;
            end
        end
        if ~import_duplicates
            return
        end
    end
end

db = [db(1:current_record_ind) record db(current_record_ind+1:end)];
changed = true;
return



 