function [db, succeeded] = rename_field( db, old_field, new_field )
%rename_field removes a field from a structure (array). Can be interactive.
%
% [DB, SUCCEEDED] = rename_field( DB, [OLD_FIELD],[NEW_FIELD] )
%    if OLD_FIELD and NEW_FIELD are not supplied, then user will be
%    prompted for these.
%
% 2012-2023, Alexander Heimel
%

succeeded = false;

if nargin>1 % no interaction
    % to retain the field order, get field nummbers
    flds = fields(db);
    ind = find(strcmp(flds,old_field));
    if isempty(ind)
        disp(['rename_field: field ' old_field ' is not a field of given structure.'])
        return
    end
    [db.(new_field)] = db.(old_field);
    db = rmfield(db,old_field);
    db = orderfields(db,[1:ind-1 length(flds) ind:(length(flds)-1)]);

    succeeded = true;
    return
end

old_field = inputdlg('Name of field to rename:','Rename field');
if isempty(old_field)
    return
end
old_field = old_field{1};
if isempty(old_field)
    return
end
if ~isfield(db,old_field)
    disp(['rename_field: ' old_field ' is not an existing field.']);
    return;
end

new_field = inputdlg('New field name:','Rename field');
if isempty(new_field)
    return
end
new_field = new_field{1};
new_field = subst_specialchars( new_field );
if isempty(new_field)
    return
end
if new_field(1)<='9'
    disp('rename_field: First character of field should be a letter.');
    return
end
if isfield(db,new_field)
    disp(['rename_field: Field name ' new_field ' already exists.']);
    return
end

[db, succeeded] = rename_field( db, old_field, new_field );
