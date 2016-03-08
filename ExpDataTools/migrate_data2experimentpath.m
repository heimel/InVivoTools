function migrate_data2experimentpath( experiments, datatypes, cmode, apply )
%MIGRATE_DATA2EXPERIMENTPATH restructures InVivo data
%
% 2015, Alexander Heimel

logmsg('NEED TO UPDATE ALL EXPERIMENTS FROM 2015t to 2015, and also from ToTransfer');

%srcver = '2015t';%'2004';
srcver = '2004';
trgver = '2015';

if nargin<1 || isempty(experiments)
    experiments = {experiment};
end

if nargin<2 || isempty(datatypes)
    switch host
        case {'wall-e','olympus'}
            datatypes = {'tp','ls'};
        case {'jander','andrew'}
            datatypes = {'oi','fp'};
        case {'daneel'}
            datatypes = {'ec','oi','fp'};
        case {'nin380','nori001'}
            datatypes = {'ec'};
        otherwise
            datatypes = {'oi','tp','ec','wc','ls'};
    end
end

if nargin<3 || isempty(cmode)
    cmode = 'update'; % alternative mode
end

if nargin<4 || isempty(apply)
    apply = false;
end

if ~iscell(datatypes)
    datatypes = {datatypes};
end

if ~iscell(experiments)
    experiments = {experiments};
end
if strcmpi(experiments{1},'all')
    folders = dir(expdatabasepath);
    folders = folders([folders.isdir]); % select folders only
    folders = folders(3:end); % don't take local and parent
    experiments = {};
    for i=1:length(folders)
        switch folders(i).name
            case {'Holtmaat','Examples','Friederike','Crumbs'}
                    experiments{end+1} = folders(i).name;
            otherwise
                if length(folders(i).name)>4 && folders(i).name(3)=='.' 
                    experiments{end+1} = folders(i).name;
                end
        end
    end
elseif any(experiments{1}=='*')
    folders = dir(fullfile(expdatabasepath,experiments{1}));
    folders = folders([folders.isdir]); % select folders only
    experiments = {};
    for i=1:length(folders)
        switch folders(i).name
            case {'Holtmaat','Examples','Friederike','Crumbs'}
                    experiments{end+1} = folders(i).name;
            otherwise
                if length(folders(i).name)>4 && folders(i).name(3)=='.' 
                    experiments{end+1} = folders(i).name;
                end
        end
    end
end

logmsg(['Migrating ' num2str(length(experiments)) ' experiments in mode ' cmode]);
if apply
%     logmsg('Press key to continue or Ctrl-C to abort.');
%     pause
end

if isunix
    copycommand = 'cp ';
    copypreargs = ' -au ';
    copypostargs = '';
else
    copycommand = 'xcopy ';
    copypreargs = '';
    copypostargs = ' /d /s /y ';
end 



for d = 1:length(experiments)
    exp = experiment(experiments{d},false);
    mentioned = false;
    for t = 1:length(datatypes)
        cmd = {};
        trga = {};
        srca = {};
        datatype = datatypes{t};
        [db,filename] = load_testdb(datatype,host,false,false,false);
        if iscell(filename) && length(filename)~=1
            continue
        end
        if isempty(strfind( filename,host))
            continue
        end
        if isempty(db)
            continue
        end
        if ~mentioned
            logmsg(['Migrating experiment ' experiments{d}]);
            mentioned = true;
        end
        for i=1:length(db)
            switch datatype
                case {'ec','lfp'}
                    include_test = true;
                otherwise
                    include_test = false;
            end
            
            src = fullfile(experimentpath(db(i),include_test,false,srcver,true));

            if isempty(src)
                continue
            end
            srcd = dir(src);
            if length(srcd)<3 % i.e. no files
                continue
            end
            src = ['"' fullfile(experimentpath(db(i),include_test,false,srcver,true)) '"' filesep '*'];

            trg =  experimentpath(db(i),include_test,apply,trgver,true) ;
            if apply && ~exist(trg,'dir')
                errormsg(['Could not create ' trg]);
                return
            end
            trg = ['"' experimentpath(db(i),include_test,apply,trgver,true) '"'];
            switch cmode
                case 'update'
                    cmd{end+1} = [ '[status,result]=system('''  ...
                        copycommand ' ' copypreargs ' ' src ' ' trg ' ' copypostargs ''');'];
                case 'move' 
                    errormsg('Move option disabled',true);
                    if ~isempty(strfind(src,'mnt'))
                       % logmsg('Should not move from MVP');           
                       continue
                        %cmd{end+1} = [ '[status,result]=system(''cp -au ''' src ''' ''' trg  ''');'];
                    else
                        cmd{end+1} = [ '[status,result]=system(''mv ' src ' ' trg  ''');'];
                    end
                otherwise
                    logmsg(['Unknown mode ' cmode]);
                    return
            end
            trga{end+1} = trg;
            srca{end+1} = src;
        end
        [cmd,ind] = unique(cmd);
        cmd = cmd(end:-1:1); % to ensure doing subfolders first
        srca = srca(ind(end:-1:1));
        trga = trga(ind(end:-1:1));
        
        logmsg([ num2str(length(db)) ' records. ' num2str(length(cmd)) ' operations.']);
        for c = 1:length(cmd)
            logmsg(cmd{c});
            try
                if apply
                    eval(cmd{c});
                    if status
                        if strcmpi(cmode,'move')
                            errormsg('Move option disabled',true);
                            if ~isempty(strfind(result,'Directory not empty'))
                                cmd{c} = ['cp -au ' srca{c} ' ' trga{c} ];
                                [status,result]=system(cmd{c} );
                                if ~status
                                    cmd{c} = ['rm -r ' srca{c}  ];
                                    [status,result]=system(cmd{c} );
                                end
                            end
                        end
                        if status %
                            error('MIGRATE:MIGRATE_ERROR',['Problem with ' cmd{c}]);
                        end
                    end
                end
            catch me
                switch me.identifier
                    case {'MATLAB:MOVEFILE:OSError','MIGRATE:MIGRATE_ERROR'}
                        logmsg(me.message);
                        if exist('result','var')
                            logmsg(result);
                        end
                    otherwise
                        rethrow(me);
                end
            end
        end
    end
    
end

logmsg(['Finished migrating ' num2str(length(experiments)) ' experiments in mode ' cmode]);
