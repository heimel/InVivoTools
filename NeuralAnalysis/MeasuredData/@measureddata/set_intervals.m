function newMeasData = set_intervals(measData, newintervals)

% this function only exists so measureddata's children can access the field.
% Matlab does not allow children to write to a parent's field

newMeasData = measData;
newMeasData.intervals = newintervals;

