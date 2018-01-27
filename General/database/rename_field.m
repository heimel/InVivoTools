function [db, succeeded] = rename_field( db )
%RENAME_FIELD removes a field from a structure (array) interactively
%
% [DB, SUCCEEDED] = RENAME_FIELD( DB )
%
% 2012, Alexander Heimel
%
succeeded = false;

field = inputdlg('Name of field to rename:','Rename field');
if isempty(field)
    return
end
field = field{1};
if isempty(field)
    return
end
if ~isfield(db,field)
    disp(['RENAME_FIELD: ' field ' is not an existing field.']);
    return;
end



newfield = inputdlg('New field name:','Rename field');
if isempty(newfield)
    return
end
newfield = newfield{1};
newfield = subst_specialchars( newfield );
if isempty(newfield)
    return
end
if newfield(1)<='9'
    disp('RENAME_FIELD: First character of field should be a letter.');
    return
end

if isfield(db,newfield)
    disp(['RENAME_FIELD: Field name ' newfield ' already exists.']);
    return
end


% to keep order, get field nummber
flds = fieldnames(db);
ind = strmatch(field,flds,'exact');

[db.(newfield)] = db.(field);
db = rmfield(db,field);

db = orderfields(db,[1:ind-1 length(flds) ind:(length(flds)-1)]);



succeeded = true;