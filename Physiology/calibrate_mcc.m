function calibrate_mcc(time_frame, channel, info)
%calibrate_mcc uses the daq_parameters_mcc() script to load used parameters
%in the data acquisition
%
%   CALIBRATE_MCC(time_frame, channel, info): 
%
%   'timeframe' sets the temporal resolution in seconds (e.g. 0.001 input 
%   equals 1 msec). Default resolution is .1 sec. When no input is given. 
%   Input example: calibrate_mcc 0.1.
%
%   'channel' sets the channel number (ID), range 0 to 7. When no input is 
%   entered the default channel is set at 0.
%
%   'info' when set at 1, the script will show extended info on the used
%   hardware and configuration.   
%    
%   13-2-2016, Simon Lansbergen.
%   


clc;       % clear screen

switch nargin  % set input varibles 
    case 3
        time_frame = str2double(time_frame);
        channel = str2double(channel);
        logmsg(' *** Got manual input: time frame and channel number ***');disp(' ');
        logmsg(' *** Extended info /on ***');disp(' ');
        if info ~= 1 || info ~= 0
            info = 1;
        end
    case 2
        time_frame = str2double(time_frame);
        channel = str2double(channel);
        logmsg(' *** Got manual input: time frame and channel number ***');disp(' ');
        info = 0;
    case  1
        time_frame = str2double(time_frame);
        channel = 0;
        logmsg(' *** Got manual input: time frame ***');disp(' ');
        logmsg(' *** Channel set to 0 ***');disp(' ');
        info = 0;
    case 0
        time_frame = 0.1;    
        channel = 0;
        logmsg(' *** No manual input ***');disp(' ');
        logmsg(' *** Time frame set to 0.1 sec ***');
        logmsg(' *** Channel set to 0 ***');disp(' ');
        info = 0;
end

% show input settings
time_out = sprintf('Time frame (sec(s))    : %d', time_frame);
chan_out = sprintf('Calibration channel(s) : %d', channel);
logmsg(chan_out);
logmsg(time_out);disp(' ')
logmsg('Wait 5 seconds...');
pause(5);

% get settings from daq_parameters_mcc dedicated to DAQ PCI DAS-6025
% acquisition card.
[~,settings]=daq_parameters_mcc;

clc;    %clear screen again

disp(' '); logmsg('Stand-Alone calibration Tool for the DAQ PCI DAS-6025 acquisition card used in the InVivo-Toolset');
disp(' '); logmsg('*** No Analog Input Objects from daq_parameters_mcc are used ***');

% create Analog Input object for calibration.
AI = analoginput(settings.daq_type,settings.daq_hw_id); 

% add calibration channel to the Analog Input object.
addchannel(AI,channel);

% get info on Analog Input Object
% get info on hardware
DAQInfoAI = daqhwinfo(AI);
PropAI = propinfo(AI);

% show if info is entered
if info == 1    
    disp(DAQInfoAI);               % General information about the Analog Input Object
    disp(PropAI.SampleRate);       % Check for range sample rate
end

% configure Analog Input Object for continues measurement
set(AI, 'SampleRate', settings.sample_rate);        
set(AI, 'TriggerType', 'immediate');
set(AI, 'SamplesPerTrigger', inf);
set(AI, 'TriggerRepeat', 0);
set(AI, 'TimerPeriod', time_frame);
set(AI, 'TimerFcn', @daqtimerplot);
set(AI, {'StartFcn', 'StopFcn', 'TriggerFcn'}, {'', '', ''});

% The Analog Input object is started.
start(AI)

% Stop acquire data 
donotuse = input('Hit Enter to stop - or control-c (contr-break) to break');

% stop and delete analog object
stop(AI);
close all;
delete(AI);

disp('*** program terminated ***');

end