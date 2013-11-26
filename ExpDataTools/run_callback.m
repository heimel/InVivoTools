function newud=run_callback( ud )
%RUN_CALLBACK is called from ECTESTDB to start RUNEXPERIMENT
%
%  2009, Alexander Heimel
%

newud=ud;

record = ud.db(ud.current_record);
switch record.datatype
    case {'oi','fp'}
		datapath = oidatapath( record );
    case {'ec','lfp'}
		datapath = ecdatapath(record);
    case 'tp'
        record.epoch = '';
        datapath = tpdatapath( record );
    otherwise
        disp('RUN_CALLBACK: Fill in datatype in testrecord to get proper path.');
        datapath = getdesktopfolder;
end

runexperiment([],datapath);
