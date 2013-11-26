function newud=open_tptestrecord_callback( ud)
%OPEN_TPTESTRECORD_CALLBACK
%
%   NEWUD=OPEN_TPTESTRECORD_CALLBACK( UD)
%
% 2013, Alexander Heimel

newud=ud;

open_tptestrecord(ud.db(ud.current_record));




