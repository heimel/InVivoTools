function [db, succeeded] = remove_field( db )
%REMOVE_FIELD removes a field from a structure (array) interactively
%
% [DB, SUCCEEDED] = REMOVE_FIELD( DB )
%
% 2012, Alexander Heimel
%
succeeded = false;

field = inputdlg('Name of field to remove:','Remove field');
if isempty(field)
    return
end
field = field{1};
if isempty(field)
    return
end
if ~isfield(db,field)
    disp(['REMOVE_FIELD: ' field ' is not an existing field.']);
    return;
end

db = rmfield(db,field);
succeeded = true;