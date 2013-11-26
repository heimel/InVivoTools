function objectdb = get_objectmeasurements(measurementdb,objectdb,measures)
%GET_OBJECTMEASUREMENTS parses measurementdb and creates object structures
%
%   OBJECTDB = GET_OBJECTMEASUREMENTS( MEASUREMENTDB, OBJECTDB, MEASURES)
%       MEASUREMENTDB can be either: 
%         - a struct array with measurements (of type EMPTY_MEASUREMENT)
%         - a cell list of strings with measurementdbnames (see
%            MEASUREMENTDBNAME)
%       OBJECTDB may be [], or should be a previously created OBJECTDB 
%         consistent with currently passed MEASUREMENTDB. 
%       MEASURES is a single string with measure name, or a cell list of 
%         measure names. If measures is empty, or left away, all measures are
%         returned
%
%
%   Returns OBJECTDB, a struct array with a record for each object
%   present in MEASUREMENTDB.
%       objectdb(i).object           % string
%       objectdb(i).measure_values   % numeric
%       objectdb(i).measure_mean     % numeric
%       objectdb(i).measure_std      % numeric
%       objectdb(i).measure_n        % numeric
%
%
%  See EMPTY_MEASUREMENT for measurement structure
%
% 2012, Alexander Heimel
%

persistent prev_objects;  % need to be checked whether consistent with current measurementdb

if nargin<3
    measures = [];
end
if nargin<2
    objectdb = [];
end

if isempty(measurementdb)
    prev_objects = {};
    return
end

if ischar(measurementdb)
    measurementdb = {measurementdb};
end

if iscell(measurementdb) % i.e. list of experiments
    db = [];
    for i=1:length(measurementdb)
        dbname = fullfile(expdatabasepath,measurementdbname( measurementdb{i} ));
        if ~exist(dbname,'file')
            error('GET_OBJECTMEASUREMENTS:DBNAME_NOT_FOUND',['GET_OBJECTMEASUREMENTS: Could not find ' dbname ]);
        end
        contents = load(dbname);
        db = [db contents.db];
    end
    measurementdb = db;
end

    

% just sort for safety, measurementdb should be maintained as sorted
measurementdb = sort_db(measurementdb,[],false);

if ~isempty(prev_objects)
    objects = prev_objects;
else
    % get all uniq objects in measurementdb
    objects = uniq( {measurementdb.object} ); %O(N)
end

if isempty(measures) % then take all measures
   measures = uniq(sort({measurementdb.measure}));
end

if ~iscell(measures)
    measures = {measures};
end

for m = 1:length(measures)
    measure = measures{m};
    
    % find records in measurementdb for measure
    tmeasurementdb = measurementdb( find_record( measurementdb,['measure=' measure]));  % O(N)
    
    ind_object_start = 1;
    % for each uniq object_id get the measurements and add a record to objectdb
    for i = 1:length(objects)
        if i<length(objects)
            ind_nextobject = find_record( tmeasurementdb,['object=' objects{i+1}] );  % adapt find_record such that the extra arg works
            ind_object_end = min(ind_nextobject) - 1;  % adapt find_record such that the extra arg works
        else
            ind_object_end = length(tmeasurementdb);
        end
        objectdb(i).object = objects{i};
        
        ind = (ind_object_start:ind_object_end);
        
        objectdb(i).([ measure '_values']) = [tmeasurementdb(ind).value];
        objectdb(i).([ measure '_mean']) =  mean( [tmeasurementdb(ind).value] );
        objectdb(i).([ measure '_std']) = ...
            sqrt( nansum( ([tmeasurementdb(ind).n].*[tmeasurementdb(ind).std]).^2 )) ...
            + std( [tmeasurementdb(ind).value] );
        objectdb(i).([ measure '_n']) = sum( [tmeasurementdb(ind).n] );
        
        ind_object_start = ind_object_end + 1;
    end % object i
end % measure m




