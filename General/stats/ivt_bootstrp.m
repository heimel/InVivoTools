function y = ivt_bootstrp(n,f,x)
%IVT_BOOTSTRP applies a function to a n times redrawn set
%
% Y = IVT_BOOTSTRP(N,F,X)
%
%  X should be vector
%
%  TEMPORARILY PROGRAMMED TO USE FOR MISSING BOOTSTRP IN OCTAVE_HOME
%  CHECK FULL FUNCTIONALITY OF ORIGINAL MATLAB BOOTSTRP FUNCTION
%
%  Deprecated. Use bootstrp instead
%
% 2019-2025, Alexander Heimel

if ~isvector(x)
    logmsg('X should be vector');
    y = [];
end

y = f(x(randi(length(x),length(x),n)));

warning('BOOTSTRP:CUSTOM','using custommade bootstrp');
warning('OFF','BOOTSTRP:CUSTOM');
