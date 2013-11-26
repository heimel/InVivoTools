function dbname = measurementdbname( arg1)
%MEASUREMENTDBNAME constructs measurementdbname from measurement or experimentname 
%
% Will be lab specific
%
% 2012, Alexander Heimel
%

if isstruct(arg1)
    experiment = arg1(1).object(1:min(end,5));
else
    experiment = arg1;
end

dbname = ['measurements_' experiment '.mat'];
