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
        if isfield(record,'epoch')
            test = record.epoch;
        else
            test = record.test;
        end
        if isfield(record,'experiment') 
            experiment = record.experiment;
        else
            % oi database
            p = find(record.mouse=='.',2);
            if length(p)==2
                experiment = record.mouse(1:p(2)-1);
            else
                experiment = 'Other';
            end
        end
        setup = capitalize(record.setup);
        datapath = fullfile(localpathbase,'Experiments',experiment,record.mouse,record.date,setup,test);
    otherwise
        errormsg(['Unknown datapath format ' ver]);
        return
end


