function results_testrecord( record) 
%RESULTS_TESTRECORD wrapper around specific results testrecords
%
% 2015-2023, Alexander Heimel

switch record.datatype
    case {'oi','fp'}
        results_oitestrecord( record );
    case 'ec'
        results_ectestrecord( record);
    case 'lfp'
        if ~isempty(record.measures) && ~strcmp(record.analysis,'wspectrum') % Mehran temporarily
            results_lfptestrecord( record );
        end
    case 'tp'
        results_tptestrecord( record );
    case 'ls'
        %results_lstestrecord( record );
    case 'wc'
        results_wctestrecord( record );
    case 'pupil' % pupil camera headfixed
        results_pupiltestrecord( record );
    case 'hc' % head camera freely moving
        results_hctestrecord( record );
    case 'wheel'
        results_wheelrecord( record );
    case 'nt'
        results_nttestrecord( record );
    case 'ax'
        results_axtestrecord( record );
    otherwise
        if isfield(record,'resultsfunction') && ~isempty(record.resultsfunction)
            feval(record.resultsfunction,record);
        else
            errormsg(['Unknown datatype ' record.datatype ]);
        end
        return
end