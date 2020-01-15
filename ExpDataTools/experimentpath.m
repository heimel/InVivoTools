function datapath = experimentpath( record, include_test, create, vers, recurse, verbose )
%EXPERIMENTPATH returns datapath for an experimental record
%
%  DATAPATH = EXPERIMENTPATH(RECORD, INCLUDE_TEST=true, CREATE=false, VERS='2004', VERBOSE=false )
%
%    if CREATE is true, then the path will be created if it doesn't exist
%
%
% 2014-2019, Alexander Heimel
%

if nargin<6 || isempty(verbose)
    verbose = false;
end
if nargin<5 || isempty(recurse)
    recurse = false;
end
if nargin<4 || isempty(vers) 
    vers = '2004';
    if isfield(record,'setup')
        switch lower(record.setup)
            case 'jander'
                vers = '2015';
            case 'daneel'
                if isfield(record,'experiment') && strcmpi(record.experiment,'examples')
                    vers = '2015';
                end
            case {'gaia','helero2p','g2p','intan'}
                vers = '2015';
            case 'lif'
                vers = '2015';
        end
    end
end
if nargin<3 || isempty(create)
    create = false;
end
if nargin<2 || isempty(include_test)
    include_test = true;
end
if nargin<1 || isempty(record)
    record.datatype = 'ec';
    record.setup = host;
    record.date = datestr(now,'yyyy-mm-dd');
    record.test = 't00001';
    record.mouse = 'test';
    record.experiment = 'test';
end

switch vers
    case '2004'
        if isfield(record,'datatype')
            switch record.datatype
                case {'tp','fret','ls'}
                    datapath = tpdatapath(record,include_test,verbose);
                case {'ec','lfp','pupil'}
                    datapath = ecdatapath(record);
                    if include_test
                        if isfield(record,'test')
                            datapath = fullfile(datapath,record.test);
                        elseif isfield(record,'epoch')
                            datapath = fullfile(datapath,record.epoch);
                        else
                            errormsg('Asked to include test field, but none present');
                        end
                    end
                case {'oi','fp'}
                    datapath = oidatapath(record);
                case 'wc'
                    datapath = wcdatapath(record,create,verbose);
                otherwise
                    errormsg(['Unknown datatype ' record.datatype ' for ' recordfilter(record)]);
                    datapath = '';
            end
            
            if ~recurse && ~create
                newpath = experimentpath( record,include_test, create, '2015',true );
                if exist(newpath,'dir')
                    datapath=newpath;
                end
                
            end
            
            
            return
        else
            errormsg('Unknown record format');
            datapath = '';
            return
        end
    case {'2015','2015t'} % 2015t is temporary format, should be removed later
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
            % oi database or ec database
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
        
        switch record.datatype
            case {'oi','fp'}
                datatype = 'Imaging';
            case {'ec','lfp'}
                datatype = 'Electrophys';
            case {'tp','ls','fret'}
                datatype = 'Microscopy';
                switch setup
                    case 'Olympus-0603301' 
                        setup = 'Wall-e';
                end
            case {'wc'}
                datatype = 'Webcam';
            case {'pupil'}
                datatype = 'Electrophys';
            otherwise
                errormsg(['Unknown datatype ' record.datatype ' for ' recordfilter(record)],true);
        end
        
        switch vers
            case '2015t'
                datapath = fullfile(localpathbase,...
                    'Experiments',...
                    experiment,...
                    record.mouse,...
                    record.date,...
                    setup,...
                    test);
            otherwise
                f = filesep; % faster than fullfile
                lpb = localpathbase;
                if isempty(strfind(lpb,'InVivo'))
                    lpb = [lpb f 'InVivo'];
                end
                datapath = [lpb f ...
                    datatype f ...
                    setup f ...
                    experiment f ...
                    record.mouse f ...
                    record.date f ...
                    test];
        end
        if ~exist(datapath,'dir')
            if verbose
                logmsg([datapath ' does not exist']);
            end
            if create
                mkdir(datapath);
            elseif  ~recurse
                oldpath = experimentpath( record,include_test, create, '2004' ,true);
                if exist(oldpath,'dir')
                    datapath=oldpath;
                end
            end
        end
        
        
    otherwise
        errormsg(['Unknown datapath format ' ver]);
        return
end


