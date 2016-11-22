function newud=graphdb_compute( ud)
%GRAPHDB_COMPUTE
%
%   NEWUD = GRAPHDB_COMPUTE( UD)
%
% 2007-2015, Alexander Heimel

newud = ud;

if get(ud.h.filter,'value') && length(ud.ind)>1 % i.e. filter on and more than 1 record
    answer = questdlg('Compute entire selection?','Compute selection','Yes','No','No');
else
    answer = 'No';
end

switch answer
    case 'Yes'
        ind = ud.ind;
    case 'No'
        ind = ud.current_record;
end

for i = 1:length(ind)
    ud.db(ind(i)) = compute_graphrecord(ud.db(ind(i)),ud.db);
    ud.changed = 1;
    set(ud.h.fig,'Userdata',ud);
end
% read analysed record from database into recordform
if ~isfield(ud,'no_callback')
    control_db_callback(ud.h.current_record);
    control_db_callback(ud.h.current_record);
end

newud = ud;
newud.changed = 1;
