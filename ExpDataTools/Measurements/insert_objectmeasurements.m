function measurementdb = insert_objectmeasurements(measurementdb,measurements)
%INSERT_OBJECTMEASUREMENT inserts measurements into measurementdb
%
%   MEASUREMENTDB = INSERT_OBJECTMEASUREMENT( MEASUREMENTDB, MEASUREMENTS)
%
%       MEASUREMENTDB is a struct array with the fields:
%            object (string)
%            test (string)
%            measure (string)
%            value (numeric)
%            std (numeric)
%            n (numeric)
%      and is assumed to be ordered by object field
%
%      MEASUREMENTS should have the same field, but all have
%         an identical object entry
%
%
% 2012, Alexander Heimel
%

% test if measurement could be a valid entry
if isempty(measurements)
    return
end

% check for duplicate entries
m = measurements;
m = rmfield(m,{'value','std','n'});
if length(uniq(m))~=length(m)
    error('INSERT_OBJECTMEASUREMENTS:IDENTICAL','INSERT_OBJECTMEASUREMENTS: Multiple entries have identical object, test and measure fields.');
end

measurements = orderfields(measurements, empty_measurement);
allmeasurements = sort_db(measurements,[],false); % sort by object (first field)
objects = uniq( {allmeasurements.object} ); % get unique objects

ind = 1;
for obj = 1:length(objects)
    object = objects{obj};
    measurements =  allmeasurements(find_record( allmeasurements, ['object=' object]));

    % from here we can assume that measurements are from single object
        
    % find if entries exist
    oind = find_record( measurementdb, ['object=' object] );
    if ~isempty(oind)
        % first find old identical measurements and remove them
        mind = [];
        for i=1:length(measurements)
            mind = [mind oind(find_record( measurementdb(oind), ...
                ['test=' measurements(i).test ...
                ',measure=' measurements(i).measure]))];
        end
        measurementdb = measurementdb( setdiff(1:length(measurementdb),mind) );
        ind = max(oind)+1 - length(uniq(sort(mind))); % before next object, adjustes for removal
    else
        
        ind = ind -1 + find_record( measurementdb(ind:end), ['object>' object] );
        if ~isempty(ind)
            % first record larger than object
            ind = ind(1);
        else
            ind = length(measurementdb)+1;
        end
    end
    
    measurementdb = insert_record(measurementdb,measurements,ind);
end % obj