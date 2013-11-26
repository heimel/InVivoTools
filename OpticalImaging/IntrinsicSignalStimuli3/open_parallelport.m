function lpt=open_parallelport(port)
%OPEN_PARALLELPORT
%
%  LPT = OPEN_PARALLELPORT
%       DEPRECATED. SHOULD BE SUPERSEDED BY USING ARDUINO
%
% 200X - 2013, Alexander Heimel
%
%

if nargin<1
    port = '';
end

try
    lpt = serial_arduino(port);
catch
    import parport.ParallelPort;
    lpt=ParallelPort( hex2dec('378') );
    disp('OPEN_PARALLELPORT: Opening parallel port. May need administrator/superuser access');
end
