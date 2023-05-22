function record = analyse_testrecord( record, verbose, allowchanges, db )
%ANALYSE_TESTRECORD wraps around specific testrecord analyses
%
%  RECORD = ANALYSE_TESTRECORD( RECORD,VERBOSE=true, ALLOWCHANGES=true, DB = [] )
%
% 2015-2023, Alexander Heimel

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

switch record.datatype
    case {'oi','fp'} % intrinsic signal or flavoprotein
        record = analyse_oitestrecord( record );
    case 'ec' % unit electrophysiology
        record = analyse_ectestrecord( record, verbose, allowchanges );
    case 'lfp'
        record = analyse_lfptestrecord( record, verbose );
    case {'tp','fret'} % microscopy
        record = analyse_tptestrecord( record, verbose );
    case 'ls' % linescans
        record = analyse_lstestrecord( record );
    case 'wc' % webcam
        record = analyse_wctestrecord( record, verbose );
    case 'pupil' % pupil camera head fixed
        record = analyse_pupiltestrecord( record, verbose );
    case 'hc' % head camera freely moving
        record = analyse_hctestrecord( record, verbose );
    case 'wheel' % running wheel record
        record = analyse_wheelrecord( record, verbose );
    case 'nt' % running wheel record
        record = analyse_nttestrecord( record, verbose );
    otherwise
        if isfield(record,'analysisfunction') && ~isempty(record.analysisfunction)
            record = feval(record.analysisfunction,record,db,verbose);
        else
            errormsg(['Unknown datatype ' record.datatype ]);
        end
        return
end

