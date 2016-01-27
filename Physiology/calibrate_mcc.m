function calibrate_mcc(time_frame)
%calibrate_mcc uses the daq_parameters_mcc() script to load used parameters
%in the data acquisition
%   CALIBRATE_MCC(time_frame), timeframe set the temporal resolution in
%   seconds (e.g. 0.001 input equals 1 msec). Default resolution is .1 sec
%   when no input is given. Input example: calibrate_mcc 0.1
%    
%   2016, Simon Lansbergen.
%   

% sets resolution to default when time_frame is not defined.
if nargin==1
    time_frame = str2double(time_frame);
elseif nargin<1 
    time_frame = 0.1;    
end


% get settings from daq_parameters_mcc dedicated to DAQ PCI DAS-6025
% acquisition card.
[~,settings]=daq_parameters_mcc;
clc;    %clear screen
disp(' '); logmsg('Calibration Tool for the DAQ PCI DAS-6025 acquisition card used in the InVivo-Toolset');
disp(' '); logmsg('*** No Analog Input Objects from daq_parameters_mcc are used ***');

% get info on hardware
DAQ_Info = daqhwinfo;
Info_DAQ_present = daqhwinfo(settings.daq_type);

% create Analog Input object and add channel(s).
AI = analoginput(settings.daq_type,settings.daq_hw_id); 
addchannel(AI,settings.hwchannels,settings.hwnames);

% get info on Analog Input Object
DAQInfoAI = daqhwinfo(AI);
PropAI = propinfo(AI);
disp(DAQInfoAI);
disp(PropAI.SampleRate);              % Check for range sample rate


% configure Analog Input Object
set(AI, 'SampleRate', settings.sample_rate);        
set(AI, 'TriggerType', 'immediate');
set(AI, 'SamplesPerTrigger', inf);
set(AI, 'TriggerRepeat', 0);
set(AI, 'TimerPeriod', time_frame);
set(AI, 'TimerFcn', @daqtimerplot);
set(AI, {'StartFcn', 'StopFcn', 'TriggerFcn'}, {'', '', ''});

% The analog input object is started.
start(AI)


% Stop acquire data 

donotuse = input('Hit Enter to stop - or control-c (contr-break) to break');

% stop and delete analog object
stop(AI);
close all;
delete(AI);

disp('*** program terminated ***');

end