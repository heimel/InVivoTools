function calibrate_mic
%CALIBRATE_MIC function to analyse settings used in load_micriphone
%   This function does read-in the set parameters found in daq_parameters
%   nor in load_microphone -> these values should be added manually.
%
%   -> add functionallity to read-in used parameters.
%
%    
%   2016, Simon Lansbergen.
%   



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   Calibration Settings   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set Sample Rate (Hz). max 96 kHz, min 5 kHz.
SampleRate = 96000;

% Set Bit Rate per Sample, max 32 bits.
BitRate = 32;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% End Calibration Settings %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



logmsg('Calibration Tool for Dodotronic Microphone started');disp(' ');
logmsg('Edit both calibration script and load_microphone parameters to set parameters');
logmsg('See also help load_microphone.')


if (~isempty(daqfind)) % finds and stops active data acquisistion-
    stop(daqfind)      % objects and terminates them
end

% get en show hardware info
DAQ_Info = daqhwinfo;
Info_DAQ_present = daqhwinfo('winsound');   % For microphone input using windows interface

% create Analog Input and add channel
AI = analoginput('winsound','0');           % Create AnalogInput object
addchannel(AI,1,'Measuring microphone');                           % Add channel to AI object

% get Analog Input info
DAQInfoAI = daqhwinfo(AI);
PropAI = propinfo(AI);
disp(DAQInfoAI);
disp(PropAI.SampleRate);               
disp(PropAI.BitsPerSample);        

% set Analog Input properties. Does normally not need change in calibration process.
set(AI, 'SampleRate', SampleRate);
set(AI, 'Bits', BitRate);
set(AI, 'TriggerType', 'immediate');
set(AI, 'SamplesPerTrigger', inf);
set(AI, 'TriggerRepeat', 0);
set(AI, 'TimerPeriod', 0.1);
set(AI, 'TimerFcn', @daqtimerplot);
set(AI, {'StartFcn', 'StopFcn', 'TriggerFcn'}, {'', '', ''});  % sets all three parameters to be empty

% The analog input object is started. 
start(AI)

% Stop acquire data, hit enter to terminate calibration script
donotuse = input('Hit Enter to stop');

% stop and delete analog object ***
stop(AI);
close all;
delete(AI);

disp('*** program terminated ***');

end