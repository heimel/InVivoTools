function newud = play_wctestrecord_callback( ud)
%PLAY_WCTESTRECORD_CALLBACK
%
%   NEWUD = PLAY_WCTESTRECORD_CALLBACK( UD)
%
% 2015-2018, Alexander Heimel

newud = ud;
par = wcprocessparams(ud.db(ud.current_record));

if par.use_legacy_videoreader 
    play_wctestrecord_legacy(ud.db(ud.current_record));
else
    play_wctestrecord(ud.db(ud.current_record));
end    