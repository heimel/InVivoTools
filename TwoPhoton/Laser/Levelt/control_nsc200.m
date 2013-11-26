function position = control_nsc200(position,timeout)
%CONTROL_NSC200 sets or reads NSC200 position 
%
%  CONTROL_NSC200( POSITION ) sets position
%  CONTROL_NSC200( POSITION, TIMEOUT ) sets position
%     POSITION in microsteps
%     TIMEOUT in seconds
%
%  POSITION = CONTROL_NSC200 returns current position in microsteps
%
% 2012, Alexander Heimel
%

port = '/dev/ttyUSB0';  % dependent on setup

if nargin < 2
    timeout = 10; % s
end
if nargin < 1
    position = [];
end

s = serial(port);
s.BaudRate = 19200;
s.DataBits = 8;
s.StopBits = 1;
s.Parity = 'none';
s.FlowControl = 'software';
s.Terminator = 'LF/CR';


try
    fopen(s);
catch me
    switch    me.identifier
        case 'MATLAB:serial:fopen:opfailed'
            disp(['CONTROL_NSC200: cannot open communications to port ' port]);
            position = [];
            return
        otherwise
            rethrow(me);
    end
end


if isempty(position) % i.e. read position
    fprintf(s,'1TP?');
    position = parse_output(fscanf(s));
    fclose(s);
    return
end

% else set position

fprintf(s,'1TS?');
val = parse_output(fscanf(s));  % 81, Motor on, motion not in progress; 80 Motor on, motion in progress; 64 Motor off
if val == 64
    disp('CONTROL_NSC200: Motor off. Check!');
    fclose(s);
    return
end

tic
fprintf(s,['1PA' num2str(position)]);
moving = true;
while moving && toc()< timeout 
    pause(0.2);
    fprintf(s,'1TS?');
    val = parse_output(fscanf(s)); 
    % 81, Motor on, motion not in progress; 80 Motor on, motion in progress; 64 Motor off
    if val == 81
        moving = false;
    end
end

fprintf(s,'1TP?');
new_position = parse_output(fscanf(s));
if new_position ~= position
    fprintf(s,'1TE?');
    disp(['CONTROL_NSC200: ' fscanf(s)]);
    position = new_position;
end
fclose(s);

function [val,str] = parse_output( out )
str = out;
val = [];
p = find(out == '?');
if length(p)~=1
    return
end
str = out(1:p);
val=str2double(out(p+1:end));



