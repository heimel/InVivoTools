function measurement = empty_measurement
%EMPTY_MEASUREMENT can be used to get measurement structure
%
%  MEASUREMENT is a structure with fields
%     object,   string, e.g. '10.38.1.20:011'
%     test,     string, e.g. 'ec:2012-01-01:t00002'
%     measure,  string, e.g. 'osi'
%     value,    numeric, e.g. 0.1
%     std,      numeric, e.g. 0.01
%     n,        numeric, e.g. 12
%
% if necessary use ORDERFIELDS( MEASUREMENT, EMPTY_MEASUREMENT) to use order
%
% 2012, Alexander Heimel
%

measurement.object = '';
measurement.test = '';
measurement.measure = '';
measurement.value = [];
measurement.std = [];
measurement.n = [];