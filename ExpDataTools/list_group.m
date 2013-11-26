function newud=list_group( ud )
%LIST_GROUP lists all mice in a group
%
%  NEWUD=LIST_GROUP( UD )
%
% 2009, Alexander Heimel
%

newud=ud;
record=ud.db(ud.current_record);

% parse filters
groupfilter=group2filter(record,ud.db);

disp(groupfilter)

mousedb=load_mousedb;
ind=find_record(mousedb,groupfilter);
disp(['Found ' num2str(ind) ' mice ']);

dump_db(mousedb(ind));

