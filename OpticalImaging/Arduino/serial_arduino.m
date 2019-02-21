function s1 = serial_arduino( port )
%OPEN_ARDUINO opens serial connection to arduino
%
%  S1 = SERIAL_ARDUINO( PORT )
%
%   Stills need to be followed by fopen
%
%    Expects arduino at
%        linux: /dev/ttyS100
%              make link by 'sudo ln -s /dev/ttyAXXX /dev/ttyS100'
%        windows: COM11
%
% 2014, Alexander Heimel
%

global VdaqPort

s1 = [];

if nargin<1
    port = '';
end

if isempty(port) && ~isempty(VdaqPort)
    port = VdaqPort;
end

if isempty(port)
    switch computer
        case {'GLNX86','GLNXA64'}
            port = '/dev/ttyS100';
        case {'PCWIN','PCWIN64'}
            port = 'COM6';
        otherwise
            disp('OPEN_ARDUINO: Do not know to which COM port Arduino is connected.');
            errordlg('Do not know to which COM port Arduino is connected.','Open_arduino');
            return
    end
end

% first check existing open port
s1 = instrfind({'Port','Status'},{port,'open'});
if isempty(s1)
    % check existing port
    s1 = instrfind('Port',port);
else
    fclose(s1);
end
if isempty(s1)
    s1 = serial(port);
    s1.ReadAsyncMode = 'manual';
    s1.BaudRate = 9600;
    set(s1, 'terminator', 'LF');
    set(s1,'InputBufferSize',1)
else
    s1 = s1(1);
end
try
    fopen(s1);
    fclose(s1);
catch me
    switch(me.identifier)
        case 'MATLAB:serial:fopen:opfailed'
    end
    disp(['OPEN_ARDUINO: ' me.message]);
    errordlg(me.message,'Open_arduino');
    s1 = [];
end


