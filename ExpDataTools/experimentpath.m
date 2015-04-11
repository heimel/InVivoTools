function datapath = experimentpath( record, include_test, create, vers )
%EXPERIMENTPATH returns datapath for an experimental record
%
%  DATAPATH = EXPERIMENTPATH(RECORD, INCLUDE_TEST=true, CREATE=false, VERS='2004' )
%
%    if CREATE is true, then the path will be created if it doesn't exist
%
%
% 2014-2015, Alexander Heimel
%

if nargin<4 || isempty(vers)
    vers = '2004';
end
if nargin<3 || isempty(create)
    create = false;
end
if nargin<2 || isempty(include_test)
    include_test = true;
end

switch vers
    case '2004'
        if isfield(record,'datatype')
            switch record.datatype
                case {'tp','fret','ls'}
                    datapath = tpdatapath(record);
                    if ~include_test
                        errormsg('tpdatapath always includes test');
                    end
                case {'ec','lfp'}
                    datapath = ecdatapath(record);
                    if include_test
                        datapath = fullfile(datapath,record.test);
                    end
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
        if isfield(record,'epoch') % tp database
            test = record.epoch;
        elseif isfield(record,'blocks') % oi database
            test = '';
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
        if ~include_test
            test = '';
        end
        
        datapath = fullfile(localpathbase(vers),'Experiments',experiment,record.mouse,record.date,setup,test);
        
        if ~exist(datapath,'dir') 
            if create
                mkdir(datapath);
            else
                oldpath = experimentpath( record,include_test, create, '2004' );
                if exist(oldpath,'dir')
                    datapath=oldpath;
                end
            end
        end
        
        
    otherwise
        errormsg(['Unknown datapath format ' ver]);
        return
end


