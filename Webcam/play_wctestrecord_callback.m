function newud=play_wctestrecord_callback( ud)
%PLAY_WCTESTRECORD_CALLBACK
%
%   NEWUD=PLAY_WCTESTRECORD_CALLBACK( UD)
%
% 2015, Alexander Heimel

newud=ud;

par = wcprocessparams;

if par.use_legacy_play_wctestrecord 
    play_wctestrecord_legacy(ud.db(ud.current_record));
else
    play_wctestrecord(ud.db(ud.current_record));
end    