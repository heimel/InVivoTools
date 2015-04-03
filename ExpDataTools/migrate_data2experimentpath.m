function migrate_data2experimentpath

folders = dir(expdatabasepath);
folders = folders([folders.isdir]); % select folders only
folders = folders(3:end); % don't take local and parent

host('giskard');

datatypes = {'oi','tp','ec','wc','ls'};

for d = 1:3 %1:length(folders)
    logmsg(['Migrating experiment ' folders(d).name]);
    exp = experiment(folders(d).name,false);
    for t = 1:length(datatypes)
        datatype = datatypes{t};
        [db,filename] = load_testdb(datatype,[],false,false,false);
        for i=1:length(db)
            
            switch datatype
                case 'oi'
                    src = fullfile(experimentpath(db(i),false,false,'2004'), '*');
                    trg = experimentpath(db(i),false,true,'2015');
                otherwise
            end
            if ~exist(trg,'dir')
                errormsg(['Could not create ' trg]);
                return
            end
            cmd = [ 'copyfile(''' src ...
                ''',''' trg  ''')'];
            disp(cmd);
        end
    end
    
end