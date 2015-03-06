function datapath = experimentpath( record, create )
%EXPERIMENTPATH returns datapath for an experimental record
%
%  DATAPATH = EXPERIMENTPATH(RECORD, CREATE=false )
%
% 2014-2015, Alexander Heimel
%

if nargin<2
    create = [];
end
if isempty(create)
    create = false;
end

if isfield(record,'datatype')
    switch record.datatype
        case {'tp','fret'}
            datapath = tpdatapath(record);
        case {'ec','lfp'}
            datapath = ecdatapath(record);
        case {'oi','fp'} 
          datapath = oidatapath(record);
        case 'wc' 
          datapath = wcdatapath(record,create);
    end
    return
else 
    errormsg('Unknown record format');
end



