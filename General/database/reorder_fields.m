function [db, succeeded] = reorder_fields( db,order )
%REORDER_FIELDS reorders the fields of a structure (array) 
%
% [DB, SUCCEEDED] = REORDER_FIELDS( DB,[ORDER] )
%
% 2012-2013, Alexander Heimel
%
succeeded = false;

if nargin<2 % interactively
    order = inputdlg(['New order, e.g. [3 1 2] or (' ...
        num2str(length(fieldnames(db))) ':-1:1) :' ],'Reorder fields');
    if isempty(order)
        return
    end
    order = order{1};
    if isempty(order)
        return
    end
end

if ischar(order)
    order = str2num(order); %#ok<ST2NM>
end
if isempty(order) || ~isnumeric(order) 
    disp('Order should be numeric.');
    return;
end
f = fieldnames(db);
if min(order)<1 || max(order)>length(f)
    disp('Order elements is constraint to the number of fields, starting at 1.');
    return;
end
order = [order setdiff((1:length(f)),order)];

for i =1:length(db)
    for ord = order
        new_db(i).(f{ord}) = db(i).(f{ord});
    end
end
db = new_db;
succeeded = true;