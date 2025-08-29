function results_testrecord( record) 
%RESULTS_TESTRECORD wrapper around specific results testrecords
%
% 2015-2024, Alexander Heimel

if isfield(record,'resultsfunction') && ~isempty(record.resultsfunction)
    feval(record.resultsfunction,record);
else
    switch record.datatype
        case 'lfp'
            if ~isempty(record.measures) && ~strcmp(record.analysis,'wspectrum') % Mehran temporarily
                results_lfptestrecord( record );
            end
        case 'wheel'
            results_wheelrecord( record );
        case '' 
            logmsg(['No datatype for ' recordfilter(record)])
            % do nothing
        otherwise
            resultsfunction = ['results_' record.datatype 'testrecord'];
            if exist(resultsfunction,'file')
                feval(resultsfunction,record);
            else
                errormsg(['Unknown datatype ' record.datatype '. Check if present in path.']);
            end
    end
    return
end