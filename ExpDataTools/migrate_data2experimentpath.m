function migrate_data2experimentpath

apply = true;

folders = dir(expdatabasepath);
folders = folders([folders.isdir]); % select folders only
folders = folders(3:end); % don't take local and parent

host('giskard');

datatypes = {'oi','tp','ec','wc','ls'};

for d = 1:2 %1:length(folders)
    logmsg(['Migrating experiment ' folders(d).name]);
    exp = experiment(folders(d).name,false);
    for t = 1:length(datatypes)
        cmd = {};
        datatype = datatypes{t};
        [db,filename] = load_testdb(datatype,[],false,false,false);
        if isempty(db)
            continue
        end
        for i=1:length(db)
            src = fullfile(experimentpath(db(i),false,false,'2004'), '*');
            srcd = dir(src);
            if length(srcd)<3 % i.e. no files
                continue
            end
            trg = experimentpath(db(i),false,true,'2015');
            if ~exist(trg,'dir')
                errormsg(['Could not create ' trg]);
                return
            end
            cmd{end+1} = [ 'movefile(''' src ...
                ''',''' trg  ''',''f'')'];
        end
        cmd = unique(cmd);
        logmsg([ num2str(length(db)) ' records. ' num2str(length(cmd)) ' operations.']);
        if apply
            for c = 1:length(cmd)
                logmsg(cmd{c});
%                 try
                    eval(cmd{c});
%                 catch me
%                     switch me.identifier
%                         case 'MATLAB:MOVEFILE:OSError'
%                             
%                     end
%                 end
            end
        end
    end
    
end