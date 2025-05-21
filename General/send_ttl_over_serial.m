function send_ttl_over_serial(s, duration)
%send_ttl_over_serial. Sends a pulse 
%
%     send_ttl_over_serial(S, DURATION=0.001)
%  
%    Changes serial port S from 0 V to 3.3 V for DURATION s.
% 
%  To open serial port:
%    s = serialport("COM5",9600,"Timeout",5);
%  This sets DTR to 0 V (status true).
%
%  To close serial port:
%    delete(s)
%
%  To find likely COM port, use find_serial_for_ttl.
%
% 2025, Alexander Heimel
%
if nargin<2 || isempty(duration)
    duration = 0.001;
end

setDTR(s,true) % 0 V
setDTR(s,false) % 0 V
pause(duration)
setDTR(s,true) % 0 V

 % 
 % 
 % pause(0.1)
 % setDTR(s,true) % 0 V
 % pause(0.1)
 % setDTR(s,false) % 3.3 V
