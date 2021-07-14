function results_testrecord( record) 
%RESULTS_TESTRECORD wrapper around specific results testrecords
%
% 2015, Alexander Heimel


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
    otherwise
        errormsg(['Unknown datatype ' record.datatype ]);
        return
end