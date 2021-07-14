function record = analyse_testrecord( record, verbose, allowchanges )
%ANALYSE_TESTRECORD wraps around specific testrecord analyses
%
%  RECORD = ANALYSE_TESTRECORD( RECORD,VERBOSE=true, ALLOWCHANGES=true )
%
% 2015-2017, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = true;
end
if nargin<3 || isempty(allowchanges)
    allowchanges = true;
else
    logmsg('ALLOWCHANGES is only implemented for ANALYSE_ECTESTRECORD.');
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
    otherwise
        errormsg(['Unknown datatype ' record.datatype ]);
        return
end

