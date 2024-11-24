function results_testrecord( record) 
%RESULTS_TESTRECORD wrapper around specific results testrecords
%
% 2015-2024, Alexander Heimel

if isfield(record,'resultsfunction') && ~isempty(record.resultsfunction)
    feval(record.resultsfunction,record);
else
    switch record.datatype
        case 'fp'
            results_oitestrecord( record );
        case 'lfp'
            if ~isempty(record.measures) && ~strcmp(record.analysis,'wspectrum') % Mehran temporarily
                results_lfptestrecord( record );
            end
        case 'wheel'
            results_wheelrecord( record );
        otherwise
            resultsfunction = ['results_' record.datatype 'testrecord'];
            if exist(resultsfunction,'file')
                feval(resultsfunction,record);
            else
                errormsg(['Unknown datatype ' record.datatype ]);
            end
    end
    return
end