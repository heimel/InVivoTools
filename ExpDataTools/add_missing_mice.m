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
    if isempty(hostname)
        % disp(['EXPERIMENT_DB: No hostname set' ]);
    else        
        disp(['EXPERIMENT_DB: Working on host ' hostname ]);
    end
end

% get which database
[testdb, experimental_pc] = expdatabases( type, hostname );

% load database
[db,filename]=load_testdb(testdb);

mice = uniq(sort({db.mouse}));

filename = fullfile(expdatabasepath, 'mousedb.mat');
[db,filename,perm,lockfile]=open_db( filename);
if strcmp(perm,'rw')==0
    disp('ADD_MISSING_MICE: Could not get lock for mouse_db. Quitting.');
    return
end

for i = 1:length(mice)
    ind = find_record(db,['mouse=' mice{i}]);
    if isempty(ind)
        disp(['Mouse ' mice{i} ' is not in mouse_db.']);
        db(end+1) = empty_record(db);
        
        db(end).mouse = mice{i};
        db(end).alive = 0;
    else
        disp(['Mouse ' mice{i} ' is already in mouse_db.']);
    end
end

[filename,lockfile]=save_db(db, filename , '',lockfile);
rmlock(filename);


