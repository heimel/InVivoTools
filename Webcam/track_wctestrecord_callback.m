function newud = track_wctestrecord_callback( ud)
%TRACK_WCTESTRECORD_CALLBACK
%
%   NEWUD=TRACK_WCTESTRECORD_CALLBACK( UD)
%
% 2015, Alexander Heimel

newud = ud;
newud.db(ud.current_record) = track_wctestrecord(ud.db(ud.current_record));