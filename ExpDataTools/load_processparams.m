function processparams = load_processparams( record )
%LOAD_PROCESSPARAMS wraps around datatype specific processparams
%
% 2015, Alexander Heimel

processparams = [];

if isempty( record )
    errormsg('No datatype given.');
    return
end

switch record.datatype
    case {'oi','fp'}
        processparams = oiprocessparams( record );
    case {'ec','lfp'}
        processparams = ecprocessparams( record );
    case {'tp','fret','ls'}
        processparams = tpprocessparams( record );
    case 'wc' 
        processparams = wcprocessparams( record );
    otherwise
        errormsg(['Datatype ' record.datatype ' is unknown.']);
end
