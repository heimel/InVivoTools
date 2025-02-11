function newud=results_tptestrecord_callback( ud )
%RESULTS_TPTESTRECORD
%
%  RESULTS_TPTESTRECORD( UD )
%
%  2007, Alexander Heimel
%

newud=ud;
results_tptestrecord(ud.db(ud.current_record));

