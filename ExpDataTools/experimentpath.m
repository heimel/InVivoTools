function datapath = experimentpath( record, create, vers )
%EXPERIMENTPATH returns datapath for an experimental record
%
%  DATAPATH = EXPERIMENTPATH(RECORD, CREATE=false, VERS='2004' )
%
%    if CREATE is true, then the path will be created if it doesn't exist
%
%
% 2014-2015, Alexander Heimel
%

if nargin<3 || isempty(vers)
    vers = '2004';
end
if nargin<2 || isempty(create)
    create = false;
end

switch vers
    case '2004'
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
            datapath = '';
            return
        end
    case '2015'
        root = '';
        if isfield(record,'epoch')
            test = record.epoch;
        else
            test = record.test;
        end
        
        fullfile(root,record.experiment,record.mouse,record.date,record.setup,test)
        errormsg('New experimentpath not yet implemented');
    otherwise
        errormsg(['Unknown datapath format ' ver]);
        return
end


