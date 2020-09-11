function y = bootstrp(n,f,x)
%BOOTSTRP applies a function to a n times redrawn set
%
% Y = BOOTSTRP(N,F,X)
%
%  X should be vector
%
%  TEMPORARILY PROGRAMMED TO USE FOR MISSING BOOTSTRP IN OCTAVE_HOME
%  CHECK FULL FUNCTIONALITY OF ORIGINAL MATLAB BOOTSTRP FUNCTION
%
% 2019-2020, Alexander Heimel

if ~isvector(x)
    logmsg('X should be vector');
    y = [];
end

y = f(x(randi(length(x),length(x),n)));

warning('BOOTSTRP:CUSTOM','using custommade bootstrp');
warning('OFF','BOOTSTRP:CUSTOM');
