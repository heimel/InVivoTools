StimSerialGlobals;

if StimSerialSerialPort,
    
    if isempty(StimSerialScript)
        try
            StimSerialScript=StimSerial('Open',StimSerialScriptIn,StimSerialScriptOut,9600);
        catch me
            switch me.identifier
                case 'MATLAB:serial:fopen:opfailed'
                    errordlg(['Could not open serial ports ' ...
                        StimSerialScriptIn ' and/or ' StimSerialScriptOut ...
                        '. Check if names are correct. On linux they should be like /dev/ttySX and can be identified by ''sudo setsetial -bg /dev/ttyS*'' ' ...
                        'and on Windows COMX. The correct names should be entered in NewStimConfiguration. ' ...
                        'Disabling serial port use.'],'OpenStimSerial');
                    disp(['OPENSTIMSERIAL: ' me.message]);
                    disp('OPENSTIMSERIAL: Check serial port settings in NewStimConfiguration. Disabling serial port use.');
                otherwise
                    errordlg(me.message)
            end
            StimSerialSerialPort = 0;
            return
        end
    end
    
    if isempty(StimSerialStim),
        if strcmp(StimSerialScriptIn,StimSerialStimIn)&&...
                strcmp(StimSerialScriptOut,StimSerialStimOut),
            StimSerialStim = StimSerialScript;
        else
            try
                StimSerialStim=StimSerial('Open',StimSerialStimIn,StimSerialStimOut,9600);
            catch me
                switch me.identifier
                    case 'MATLAB:serial:fopen:opfailed'
                        errordlg(['Could not open serial ports ' ...
                            StimSerialStimIn ' and/or ' StimSerialStimOut ...
                            '. Check if names are correct. On linux they should be like /dev/ttySX and can be identified by ''sudo setsetial -bg /dev/ttyS*'' ' ...
                            'and on Windows COMX. The correct names should be entered in NewStimConfiguration. ' ...
                            'Disabling serial port use.'],'OpenStimSerial');
                        disp(['OPENSTIMSERIAL: ' me.message]);
                        disp('OPENSTIMSERIAL: Check serial port settings in NewStimConfiguration. Disabling serial port use.');
                    otherwise
                        errordlg(me.message)
                end
                StimSerialSerialPort = 0;
                return
            end
        end;
    end;
end;
