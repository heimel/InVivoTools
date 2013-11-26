function store_measurements( measurements )
%STORE_MEASUREMENTS opens database for measurements and inserts them
%
%  STORE_MEASUREMENTS( measurements )
%
%  See INSERT_OBJECTMEASUREMENT for help on MEASUREMENTS structure
%
%
% 2012, Alexander Heimel
%

% first sort measurements by object

measurements = orderfields(measurements, empty_measurement);
measurements = sort_db(measurements,[],false); % sort by object (first field)
objects = uniq( {measurements.object} ); % get unique objects


measurements = orderfields(measurements, empty_measurement);
measurements = sort_db(measurements,[],false); % sort by object (first field)
objects = uniq( {measurements.object} ); % get unique objects

cur_dbname = ''; 
measurementtranch = [];
for m = 1:length(measurements)
    measurement = measurements(m);
    dbname = measurementdbname( measurement );
    if strcmp(dbname,cur_dbname) % i.e. this measurement uses the same db as the prev measurement
        measurementtranch = [measurementtranch measurement];
    else
        if m~=1
            % insert and save previous tranch
            insert_and_save( measurementtranch, cur_dbname);
        end
        measurementtranch = measurement;
        cur_dbname = dbname;
    end
end   
if ~isempty(measurementtranch)
    insert_and_save( measurementtranch, cur_dbname);
end


function insert_and_save( measurements, dbname)
if isempty(measurements) || isempty( dbname )
    return
end

% open db
filename = fullfile(expdatabasepath,dbname);
if exist(filename,'file')==2
    [db,filename,~,lockfile] = open_db( filename );
else
    db = [];
    lockfile = '';
end
% insert new entries
db = insert_objectmeasurements(db,measurements);
% save db
save_db(db,filename,[],lockfile);
rmlock(filename);


