function migrate_data2experimentpath( experiments, datatypes, apply )



if nargin<1 || isempty(experiments)
    experiments = {experiment};
else
    if strcmpi('experiments','all')
        folders = dir(expdatabasepath);
        folders = folders([folders.isdir]); % select folders only
        folders = folders(3:end); % don't take local and parent
        experiments = {};
        for i=1:length(folders)
            experiments{i} = folders(i).name;
        end
    end
    
    
    if ~iscell(experiments)
        experiments = {experiments};
    end
end

if nargin<2 || isempty(apply)
    apply = false;
end

if nargin<3 || isempty(datatypes)
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

for d = 1:length(experiments)
    exp = experiment(experiments{d},false);
    mentioned = false;
    for t = 1:length(datatypes)
        
        cmd = {};
        datatype = datatypes{t};
        [db,filename] = load_testdb(datatype,[],false,false,false);
        if isempty(db)
            continue
        end
        if ~mentioned
            logmsg(['Migrating experiment ' experiments{d}]);
            mentioned = true;
        end
        for i=1:length(db)
            src = fullfile(experimentpath(db(i),false,false,'2004',true), '*');
            if isempty(src)
                continue
            end
            srcd = dir(src);
            if length(srcd)<3 % i.e. no files
                continue
            end
            trg = experimentpath(db(i),false,apply,'2015',true);
            if ~exist(trg,'dir')
                errormsg(['Could not create ' trg]);
                return
            end
            cmd{end+1} = [ 'movefile(''' src ...
                ''',''' trg  ''',''f'')'];
        end
        cmd = unique(cmd);
        cmd = cmd(end:-1:1); % to ensure doing subfolders first
        logmsg([ num2str(length(db)) ' records. ' num2str(length(cmd)) ' operations.']);
        %logmsg(cmd);
        for c = 1:length(cmd)
            logmsg(cmd{c});
            try
                if apply
                    eval(cmd{c});
                end
            catch me
                switch me.identifier
                    case 'MATLAB:MOVEFILE:OSError'
                        logmsg(['Problem with '  cmd{c}]);
                        keyboard
                    otherwise
                        rethrow(me);
                end
            end
        end
    end
    
end