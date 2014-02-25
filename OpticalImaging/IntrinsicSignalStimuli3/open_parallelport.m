function lpt=open_parallelport(port)
%OPEN_PARALLELPORT
%
%  LPT = OPEN_PARALLELPORT
%       DEPRECATED. SHOULD BE SUPERSEDED BY USING ARDUINO
%
%  After finishing with parallel port, call CLOSE_PARALLELPORT(LPT)
%
% 200X - 2013, Alexander Heimel
%
%


if nargin<1
    port = '';
end

try
    lpt = serial_arduino(port);
catch me
    logmsg(me.message);
    try
        import parport.ParallelPort;
    catch me
        logmsg(['SERIAL_ARDUINO: ' me.message]);
        lpt = [];
        return
    end
    lpt=ParallelPort( hex2dec('378') );
    disp('OPEN_PARALLELPORT: Opening parallel port. May need administrator/superuser access');
end
