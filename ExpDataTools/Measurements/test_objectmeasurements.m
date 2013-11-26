function test_objectmeasurements
%TEST_OBJECTMEASUREMENTS tests the objectmeasurements functions
%
% 2012, Alexander Heimel

measurement.object = '99.99.1.19:012';
measurement.test = 'ec:2012-01-01:t00002';
measurement.measure = 'osi';
measurement.value = 0.1;
measurement.std = 0.01;
measurement.n = 12;

report = {'FAIL','OK  '};

measurementdb = insert_objectmeasurements( [], measurement );
suc = (measurementdb == measurement);
disp([report{suc+1} ': Inserting valid record into empty measurementdb']);

measurementdb = insert_objectmeasurements( measurementdb, measurement );
suc = (measurementdb == measurement);
disp([report{suc+1} ': Inserting valid existing record into existing measurementdb']);

measurementdb = insert_objectmeasurements( measurementdb, [] );
suc = (measurementdb == measurement);
disp([report{suc+1} ': Inserting empty record into existing measurementdb']);

measurement(2) = measurement(1);
measurement(2).object = '99.99.1.19:013';
measurementdb = insert_objectmeasurements( measurementdb, measurement(2) );
suc = (measurementdb == measurement);
disp([report{suc+1} ': Inserting valid new record into existing measurementdb']);

measurement(3) = measurement(2);
measurement(3).test = 'ec:2012-02-01:t00003';
measurementdb = insert_objectmeasurements( measurementdb, measurement(3) );
suc = (measurementdb == measurement);
disp([report{suc+1} ': Inserting valid new record into existing measurementdb']);

for i = 1:100 
    measurement(end+1) = measurement(end);
    measurement(end).value = i;
end
try
    suc = false;
    measurementdb = insert_objectmeasurements( measurementdb, measurement(end-99:end) );
catch me
    if strcmp(me.identifier,'INSERT_OBJECTMEASUREMENTS:IDENTICAL')
        suc = true;
    end
end
disp([report{suc+1} ': Objecting to inserting 100 duplicate records into existing measurementdb']);

for i = length(measurement)-99:length(measurement) 
    measurement(i).test = num2str(i);
end    
measurementdb = insert_objectmeasurements( measurementdb, measurement(end-99:end) );
suc = (measurementdb == measurement);
disp([report{suc+1} ': Inserting 100 new record into existing measurementdb']);


try
    objectdb = get_objectmeasurements([],[],'osi');
    suc = true;
    disp([report{suc+1} ': Retrieved measurements for osi from empty measurementdb']);
catch me
    suc = false;
    disp([report{suc+1} ': Retrieved measurements for osi from empty measurementdb']);
end


objectdb = get_objectmeasurements(measurementdb,[],'osi');
suc = (objectdb(2).osi_mean == mean([0.1 0.1 1:100]));
disp([report{suc+1} ': Retrieved measurements for osi from measurementdb']);


objectdb = get_objectmeasurements(measurementdb,objectdb,'osi');
suc = (objectdb(2).osi_mean == mean([0.1 0.1 1:100]));
disp([report{suc+1} ': Re-retrieved measurements for osi from measurementdb']);

objectdb = get_objectmeasurements(measurementdb,[],'nonsense');
suc = isnan(objectdb(2).nonsense_mean);
disp([report{suc+1} ': Retrieved measurements for nonsense from measurementdb']);

objectdb = get_objectmeasurements(measurementdb,objectdb,'osi');
suc = isnan(objectdb(2).nonsense_mean);
disp([report{suc+1} ': Also retrieved measurements for osi from measurementdb']);

objectdb = get_objectmeasurements(measurementdb,objectdb,{'osi','nonsense'});
suc = isnan(objectdb(2).nonsense_mean);
disp([report{suc+1} ': Re-retrieved measurements for osi and nosense from measurementdb']);

try
    store_measurements( measurementdb );
    contents = load(fullfile(expdatabasepath,measurementdbname('99.99')));
    suc = (contents.db  == measurementdb);
    disp([report{suc+1} ': Stored measurements in databases']);
catch me
    suc = false;
    disp([report{suc+1} ': Stored measurements in databases']);
    rethrow(me);
end


objectdb = get_objectmeasurements('99.99',[],{'osi','nonsense'});
suc = isnan(objectdb(2).nonsense_mean);
disp([report{suc+1} ': Retrieved measurements for osi and nosense for experiment 99.99']);

try
    objectdb = get_objectmeasurements('99.99');
    suc = (length(objectdb)==2);
    disp([report{suc+1} ': Retrieved all measurements for experiment 99.99']);
catch me
    suc = false;
    disp([report{suc+1} ': Retrieved all measurements for experiment 99.99']);
    disp([me.identifier ' - ' me.message]);
    disp(me.stack);
end

disp('TEST_OBJECTMEASUREMENTS: Finished.');