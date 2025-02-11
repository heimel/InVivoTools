function newud=results_ectestrecord_callback( ud )
%RESULTS_ECTESTRECORD
%
%  RESULTS_ECTESTRECORD( UD )
%
%  2007, Alexander Heimel
%

newud = ud;
record = ud.db(ud.current_record);

% call results_ectestrecord to show results of analysis
switch record.datatype
  case 'ec'
    results_ectestrecord(  record);
  case 'lfp'
    results_lfptestrecord( record);
  otherwise
    warning(['Unknown datatype ' record.datatype ]);
    return
end