function newud=tptestdb_selectname( ud )
%TPTESTDB_SELECTNAME selects all records with mouse and name shown
%
%  NEWUD=TPTESTDB_SELECTNAME( UD )
%
% 2009, Alexander Heimel
%

newud=ud;

record=ud.db(ud.current_record);

set(newud.h.crit,'String',['mouse=' record.mouse]);

set(newud.h.filter,'Value',1 );
set(newud.h.fig,'UserData',newud);

cbo=ud.h.filter;

control_db_callback( cbo )

newud=get(newud.h.fig,'UserData');

