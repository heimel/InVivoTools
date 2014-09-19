NewStimCalibrate;

if haspsychtbox
    try
			OpenStimSerial
		catch 
			disp('No serial port available.');
    end
    ShowStimScreen
    CloseStimScreen
end

NewStimObjectInit

