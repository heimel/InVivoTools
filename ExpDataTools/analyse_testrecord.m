function record = analyse_testrecord( record, verbose )
%ANALYSE_TESTRECORD wraps around specific testrecord analyses
%
%  RECORD = ANALYSE_TESTRECORD( RECORD,VERBOSE=true )
%
% 2015, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = true;
end

switch record.datatype
    case {'oi','fp'} % intrinsic signal or flavoprotein
        record=analyse_oitestrecord( record );
    case 'ec'
        record=analyse_ectestrecord( record, verbose );
    case 'lfp'
        record=analyse_lfptestrecord( record, verbose );
    case {'tp','fret'}
        record=analyse_tptestrecord( record, verbose );
    case 'ls' % linescans
        record=analyse_lstestrecord( record );
    case 'wc'
        record=analyse_wctestrecord( record, verbose );
    otherwise
        errormsg(['Unknown datatype ' record.datatype ]);
        return
end

