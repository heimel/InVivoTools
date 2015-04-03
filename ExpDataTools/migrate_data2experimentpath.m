function migrate_data2experimentpath

folders = dir(expdatabasepath);
folders = folders([folders.isdir]); % select folders only
folders = folders(3:end); % don't take local and parent

host('giskard');

for d = 1; %1:length(folders)
    logmsg(['Migrating experiment ' folders(d).name]);
    experiment(folders(d).name)

    db = load_testdb;
% 
% for i=1:length(db)
%     cmd = [ 'copyfile(''' fullfile(experimentpath(db(i),[],'2004'),[db(i).test '*'])... 
%         ''',''' experimentpath(db(i),[],'2015') ''')'];
%     disp(cmd);
%     
% end

end