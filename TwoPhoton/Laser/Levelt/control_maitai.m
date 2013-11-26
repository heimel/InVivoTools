function out = control_maitai(command,parameter)
%CONTROL_MAITAI controls mai tai laser
%
%  OUT = CONTROL_MAITAI( COMMAND )
%  OUT = CONTROL_MAITAI( COMMAND, PARAMETER )
%
%
% 2012, Alexander Heimel
%

disp(['CONTROL_MAITAI: Command = ' command ]);

port = '/dev/ttyS0';  % dependent on setup

s = serial(port);
s.BaudRate = 9600;
s.DataBits = 8;
s.StopBits = 1;
s.Parity = 'none';
s.FlowControl = 'software';
s.Terminator = 'LF';

out = [];

try
    fopen(s);
catch me
    switch    me.identifier
        case 'MATLAB:serial:fopen:opfailed'
            disp(['CONTROL_MAITAI: cannot open communications to port ' port]);
            return
        otherwise
            rethrow(me);
    end
end

try
switch command
    case 'READ:PCTWARMEDUP?' 
        fprintf(s,'READ:PCTWARMEDUP?');
        out = trim(fscanf(s));
        if out(end)~='%'
            disp(['CONTROL_MAITAI: Unexpected response from laser to warmup status enquiry: ' out]);
            out = '?';
            fclose(s);
            return
        end
    case 'ON'
        fprintf(s,'READ:PCTWARMEDUP?');
        out = trim(fscanf(s));
        if strcmp(out,'0.00%')
            disp('CONTROL_MAITAI: Stabilizing diode temperature. Takes approx. 2 minutes.');
            fprintf(s,'ON');
            fclose(s);
            return
        end
        
        if ~strcmp(out,'100.00%')
            disp(['CONTROL_MAITAI: Laser not yet warmed up. Only at ' out ]);
            out = -1;
            fclose(s);
            return
        end
        fprintf(s,'ON');
    case 'OFF'
        fprintf(s,'OFF');
    case 'SHUTTER?'
        fprintf(s,'SHUTTER?');
        out = str2double(trim(fscanf(s)));
    case 'SHUTTER'
        if isnumeric(parameter)
            parameter = num2str(parameter);
        end
        parameter = trim(parameter);
        if strcmp(parameter,'0')==0 && strcmp(parameter,'1')==0
            disp('CONTROL_MAITAI: Invalid shutter command');
            fclose(s);
            return;
        end
        fprintf(s,['SHUTTER ' parameter]);
    case 'WAVELENGTH'
        if ischar(parameter)
            parameter = str2double(parameter);
        end
        if isnan(parameter) || parameter>920 || parameter <780
            disp('CONTROL_MAITAI: Invalid wavelength');
            fclose(s);
            return;
        end
        parameter = round(parameter);
        disp(['CONTROL_MAITAI: Command = WAVELENGTH ' num2str(parameter)]);
        fprintf(s,['WAVELENGTH ' num2str(parameter)]);
    case 'WAVELENGTH?' % last requested wavelength 
        fprintf(s,'WAVELENGTH?');
        out = fscanf(s);
    case 'READ:WAVELENGTH?' 
        fprintf(s,'READ:WAVELENGTH?');
        pause(0.1);
        out = trim(fscanf(s));
        out = out(1:end-2);
        out = str2double(out);
    case 'READ:POWER?'
        fprintf(s,'READ:POWER?');
        out = trim(fscanf(s));
        out = out(1:end-1); % to remove 'W'
        out = str2double(out);
    case '*STB?'
        fprintf(s,'*STB?');
        out = str2double(trim(fscanf(s)));
    otherwise
        disp(['CONTROL_MAITAI: Unknown/unimplemented command ' command]); 
end

if isnumeric(out)
    disp(['CONTROL_MAITAI: Out = ' num2str(out)]);
else
    disp(['CONTROL_MAITAI: Out = ' out]);
end

catch me
    fclose(s);
    rethrow(me);
end

fclose(s);



