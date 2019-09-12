function add_missing_mice( type, hostname  )
%ADD_MISSING_MICE
%
% script to get mice from testdb and add to mousedb
%
%add_missing_mice(type,hostname)
% 2012-2013, Alexander Heimel

db = []; % to mask signal/db

if nargin<1
    type = [];
end

if isempty(type)
    type='ec';
end

if nargin<2
    hostname = host;
    if ~isempty(hostname)
        logmsg(['Working on host ' hostname ]);
    end
end

% load database
db = load_testdb( type, hostname );

if isempty(db)
    logmsg('Empty or no database');
    return
end

mice = uniq(sort({db.mouse}));

[mousedb,filename] = load_expdatabase('mousedb',[],[],[],false);
[db,filename,perm,lockfile]=open_db( filename);
if strcmp(perm,'rw')==0
    logmsg('Could not get lock for mouse_db. Quitting.');
    return
end

for i = 1:length(mice)
    ind = find_record(db,['mouse=' mice{i}]);
    if isempty(ind)
        logmsg(['Mouse ' mice{i} ' is not already in mouse_db.']);
        db(end+1) = empty_record(db);
        
        db(end).mouse = mice{i};
        db(end).alive = 0;
    else
        logmsg(['Mouse ' mice{i} ' is already in mouse_db.']);
    end
end

[filename,lockfile]=save_db(db, filename , '',lockfile);
rmlock(filename);


