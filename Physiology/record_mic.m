%function [time,data]=record_mic()
%RECORD_DAQ.m stand-alone data acquisition with MCC DAQ. open file for
%acquisition settings
%-------------------------------------------------------------------------%
%     
%   This script is written for stand-alone data acquistion with the USB
%   Dodotronic mic. The script contains pre-settings such as acquisition 
%   duration and sample rate, as well as the acquistion it self. All 
%   settings are set within the script and no InVivoTools toolbox functions 
%   are used.
%
%   Use calibrate_mic() to check the channel input and sensor range.
%
%   Used scripts:
%       analoginput()
%       addchannel()
%
%   *** REVISION:
%           -> 
%
%   Last edited 24-3-2016. SL
%
%
%   (c) 2016, Simon Lansbergen.
%
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% Initialisation
clear all       % Clear all variables in workspace
close all       % Close all current windows with figures (plots)
clc             % Clear Command window
%-------------------------------------------------------------------------%


% pre-settings: change these variables 
% for individual acquistion needs.
duration = 10;                   % Acquisition time, in seconds.

% overwrite current settings
daq_hw_id = '0';
daq_type = 'winsound';
hwchannels = 1;
0
hwnames = 'UltraSonic Mic';
trigger_type = 'Immediate';      % Set trigger type -> Triggerd immediate when start is executed


% *** Extended range to 250kHZ ***
% Set sample rate (Hz), max = 250kHz, min = 5 kHz.
sample_rate = 250000;
required_samples = floor(sample_rate * duration);

% use for precision <- only 1V supported
input_range_channel = 1;   % Input range +/- (Volts) <- less sensitive

% use for scaling -> Usually both 10 (and units range = sensor range)
sensor_range_channel = 10;      % Sensor range +/- (Volts)  
units_range_channel = 10;       % Units Range +/- (Volts)
allinfo = true;                 % Display Summary of Analog Input (AI) Object Using 'PCI-DAS6025'



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Acquisition Part - Do not change! %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create Analog Input object.
AI = analoginput(daq_type,daq_hw_id);

% set paremeters
set(AI, 'SamplesPerTrigger', required_samples);
set(AI, 'SampleRate', sample_rate);
set(AI, 'TriggerType', trigger_type);

% create channels
addchannel(AI,hwchannels,hwnames);

% set input and sensor range
AI.Channel.InputRange  = [-input_range_channel, input_range_channel];
AI.Channel.SensorRange = [-sensor_range_channel, sensor_range_channel];
AI.Channel.UnitsRange  = [-units_range_channel, units_range_channel];

% output acquisition settings
str=['Acquisition time (seconds): ' num2str(duration)];
logmsg(str)
str=['Sample rate: ' num2str(sample_rate)];
logmsg(str)
str=['Hardware channel(s) -> [' num2str(hwchannels) ']'];
logmsg(str)
str=['Sensor range (V): ' num2str(sensor_range_channel)];
logmsg(str)
% str=['Units range (V): ' num2str(units_range_channel)];
% logmsg(str)
str=['Input range (V): ' num2str(input_range_channel)];
logmsg(str)
if allinfo
    disp(' ');disp(AI);
end
disp(' ');disp(' ');
logmsg(' *** Hit key to continue to start Acquisition ***')
disp(' ');
pause;

% start acquisition
start(AI)
logmsg(' *** Acquisition Started ***')
disp(' ');

% wait to block Matlab during acquisition time, with an additional 0.5
% seconds for safety.
wait(AI,(duration + 0.5));

% get data from buffer
[data, time] = getdata(AI);

% output acquisition done
logmsg(' *** Acquisition done ***')
logmsg(' *** Data available in in workspace ***')
disp(' ')

% stop and delete analog object
stop(AI);
close all;
delete(AI);

plot(time,data)
ylim([-input_range_channel input_range_channel])


