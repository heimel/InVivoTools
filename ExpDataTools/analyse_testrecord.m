function record = analyse_testrecord( record, verbose, allowchanges, db )
%ANALYSE_TESTRECORD wraps around specific testrecord analyses
%
%  RECORD = ANALYSE_TESTRECORD( RECORD,VERBOSE=true, ALLOWCHANGES=true, DB = [] )
%
% 2015-2024, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = true;
end
if nargin<3 || isempty(allowchanges)
    allowchanges = true;
else
    logmsg('ALLOWCHANGES is only implemented for ANALYSE_ECTESTRECORD.');
end
if nargin<4 || isempty(db)
    db = [];
end

if isfield(record,'analysisfunction') && ~isempty(record.analysisfunction)
    record = feval(record.analysisfunction,record,db,verbose);
else 
    switch record.datatype
        case 'fp' % flavoprotein
            record = analyse_oitestrecord( record );
        case 'ec' % unit electrophysiology
            record = analyse_ectestrecord( record, verbose, allowchanges );
        case 'fret' % microscopy
            record = analyse_tptestrecord( record, verbose );
        case 'wheel' % running wheel record
            record = analyse_wheelrecord( record, verbose );
        otherwise
            analysisfunction = ['analyse_' record.datatype 'testrecord'];
            if exist(analysisfunction,'file')
                record = feval(analysisfunction,record,verbose);
            else
                errormsg(['Unknown datatype ' record.datatype ]);
            end
    end
end
end
