function [db,succeeded] = add_field( db, empty_value )
%ADD_FIELD adds a field to a structure interactively
%
% [DB,SUCCEEDED] = ADD_FIELD( DB )
% [DB,SUCCEEDED] = ADD_FIELD( DB, EMPTY_VALUE )
%
%   use EMPTY_VALUE = [] to create numeric field (default)
%   or EMPTY_VALUE = '' to create text field
%
% 2012, Alexander Heimel
%
succeeded = false;

if nargin<2
    empty_value = [];
end

field = inputdlg('New field name:','Add field');
if isempty(field)
    return
end
field = field{1};
field = subst_specialchars( field );
if isempty(field)
    return
end
if field(1)<='9'
    disp('ADD_FIELD: First character of field should be a letter.');
    return
end

if isfield(db,field)
    disp(['ADD_FIELD: Field name ' field ' already exists.']);
    return
end
for i=1:length(db)
    db(i).(field) = empty_value;
end
succeeded = true;
