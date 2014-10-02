function datapath = experimentpath( record )
%EXPERIMENTPATH returns datapath for an experimental record
%
% 2014, Alexander Heimel
%

if isfield(record,'datatype')
    switch record.datatype
        case {'tp','fret'}
            datapath = tpdatapath(record);
        case {'ec','lfp'}
            datapath = ecdatapath(record);
        case {'oi','fp'} 
            
    end
    return
else 
    errormsg('Unknown record format');
end
