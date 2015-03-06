function newud=run_callback( ud )
%RUN_CALLBACK is called from ECTESTDB to start RUNEXPERIMENT
%
%  2009-2014, Alexander Heimel
%

newud=ud;

record = ud.db(ud.current_record);
switch record.datatype
    case {'tp','wc'}
        record.epoch = '';
end

runexperiment([],record);
