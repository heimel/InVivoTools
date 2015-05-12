comPort = '/dev/ttyS0';

% close if it is open already
s=instrfind('type','serial','name',['Serial-' comPort],'status','open');
if ~isempty(s)
    fclose(s);
end

flag = 1;

s = serial(comPort);
set(s, 'DataBits', 8);
set(s, 'StopBits', 1);
set(s, 'BaudRate', 9600);
set(s, 'Parity', 'none');
set(s, 'Timeout',0.5);
fopen(s);
%% whatever for the shutters we need put it here: like left close:1 and
%% right close:2
trig_shutter=[1 2 1 1];
fwrite(s, trig_shutter, 'uint8', 'sync');
fclose(s);