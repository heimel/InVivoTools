function newud=sort_testrecords( ud )
%SORT_TESTRECORD
%
%    NEWUD=SORT_TESTRECORD( UD )
%
% 2006-2015, Alexander Heimel
%

newud = ud;

[newud.db,dummy,changed] = sort_db(ud.db);
newud.changed = ud.changed || changed;

 control_db_callback(newud.h.current_record);
