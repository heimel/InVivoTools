StimSerialGlobals

if StimSerialSerialPort
    if ~isa(StimSerialScript,'serial') && ~isa(StimSerialScript,'octave_serial')
        try
            StimSerialScript=StimSerial('Open',StimSerialScriptIn,StimSerialScriptOut,9600);
        catch me
            switch me.identifier
                case 'MATLAB:serial:fopen:opfailed'
                    errormsg(['Could not open serial ports ' ...
                        StimSerialScriptIn ' and/or ' StimSerialScriptOut ...
                        '. Check if names are correct. On linux they should be like /dev/ttySX and can be identified by ''sudo setsetial -bg /dev/ttyS*'' ' ...
                        'and on Windows COMX. The correct names should be entered in NewStimConfiguration. ' ...
                        'Disabling serial port use.']);
                otherwise
                    errormsg(me.message)
            end
            StimSerialSerialPort = 0;
            return
        end
    end
    
    if ~isa(StimSerialStim,'serial') && ~isa(StimSerialStim,'octave_serial') 
        if strcmp(StimSerialScriptIn,StimSerialStimIn) && ...
                strcmp(StimSerialScriptOut,StimSerialStimOut)
            StimSerialStim = StimSerialScript;
        else
            try
                StimSerialStim=StimSerial('Open',StimSerialStimIn,StimSerialStimOut,9600);
            catch me
                switch me.identifier
                    case 'MATLAB:serial:fopen:opfailed'
                        errormsg(['Could not open serial ports ' ...
                            StimSerialStimIn ' and/or ' StimSerialStimOut ...
                            '. Check if names are correct. On linux they should be like /dev/ttySX and can be identified by ''sudo setsetial -bg /dev/ttyS*'' ' ...
                            'and on Windows COMX. The correct names should be entered in NewStimConfiguration. ' ...
                            'Disabling serial port use.']);
                    otherwise
                        errormsg(me.message)
                end
                StimSerialSerialPort = 0;
                return
            end
        end
    end
end
