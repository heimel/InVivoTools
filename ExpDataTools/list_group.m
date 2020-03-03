function newud=list_group( ud )
%LIST_GROUP lists all mice in a group
%
%  NEWUD=LIST_GROUP( UD )
%
% 2009-2020, Alexander Heimel
%

global global_mice

evalin('base','global global_mice');

newud=ud;
record=ud.db(ud.current_record);

% parse filters
groupfilter=group2filter(record,ud.db);

disp(groupfilter)

mousedb=load_mousedb;
ind=find_record(mousedb,groupfilter);
disp(['Found ' num2str(ind) ' mice ']);

global_mice = mousedb(ind);
logmsg('Mice available in global_mice.');

dump_db(mousedb(ind));

