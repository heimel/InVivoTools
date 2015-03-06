function newud=play_wctestrecord_callback( ud)
%PLAY_WCTESTRECORD_CALLBACK
%
%   NEWUD=PLAY_WCTESTRECORD_CALLBACK( UD)
%
% 2015, Alexander Heimel

newud=ud;


play_wctestrecord(ud.db(ud.current_record));