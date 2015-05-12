function ud=results_testrecord_callback( ud )
%RESULTS_TESTRECORD_CALLBACK
%
%  UD = RESULTS_TESTRECORD_CALLBACK( UD )
%
%  2015, Alexander Heimel
%

results_testrecord(  ud.db(ud.current_record));
