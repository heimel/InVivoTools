%function convert_ectestdb2measurementdb
%CONVERT_ECTESTDB2MEASUREMENTDB single use convert of ectestdb to measurementdbs
%
%  2012, Alexander Heimel
%


% get which database
testdb = expdatabases('ec' );

% load database
[db,filename]=load_testdb(testdb);


tstart = tic;
h_wait = waitbar(0,'Converting ec test records');

n_records = length(db);

n_records = 100;

measurement = empty_measurement;
measurement = measurement([]);
for i=1:n_records
    test = ['ec:' db(i).date ':' db(i).test];
    measures = db(i).measures;
    if isempty(measures)
        continue
    end
    flds = fieldnames(measures);
    for j=1:length(measures)
        object = [db(i).mouse ':' num2str(j,'%03d')];
        for k=1:length(flds)
            measurement(end+1).object = object;
            measurement(end).test = test;
            measurement(end).measure = flds{k};
            measurement(end).value = measures(j).(flds{k});
        end
    end
    if mod(i,100)==0
measurement
        store_measurements( measurement );
        measurement = measurement([]);
        toc(tstart);
        waitbar(i/length(db));
    end
    i
end
store_measurements( measurement );
close(h_wait);
disp(['CONVERT_ECTESTDB2MEASUREMENTDB: Converted ' num2str(n_records) ...
    ' records to ' num2str(length(measurement)) ' measurements']);
toc(tstart);
