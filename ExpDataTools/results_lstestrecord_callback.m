function newud = results_lstestrecord_callback( ud )
%RESULTS_TPLINESCAN_TESTRECORD_CALLBACK
%
%  NEWUD = RESULTS_TPLINESCAN_TESTRECORD_CALLBACK( UD )
%
%  2007, Alexander Heimel
%

newud = ud;
record = ud.db(ud.current_record);

disp('RESULTS_TPLINESCAN_TESTRECORD_CALLBACK: returning result as global');
global result
result = record.measures;

results_tppatternanalysis(  record.measures, record.process_params);
