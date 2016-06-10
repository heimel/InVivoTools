function [time,data]=record_daq()
%RECORD_DAQ.m stand-alone data acquisition with MCC DAQ. open file for
%acquisition settings
%-------------------------------------------------------------------------%
%     
%   This script is written for stand-alone data acquistion with the MCC
%   DAQ. The script contains pre-settings such as acquisition duration and
%   sample rate, as well as the acquistion it self. All settings are set 
%   within the script and no InVivoTools toolbox functions are used.
%
%   Use calibrate_daq() to check the channel input and sensor range.
%
%   Used scripts:
%       analoginput()
%       addchannel()
%
%   *** REVISION:
%           -> Needs input from function (in line).
%
%   Last edited 10-24-2016. SL
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Acquisition Settings MCC Hardware %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% pre-settings: change these variables 
% for individual acquistion needs.
duration = 60;                   % Acquisition time, in seconds.
sample_rate = 5000;              % Set sample rate (Hz), max = 200000Hz, min = 1Hz.
hwchannels = [1];                % DAQ differential analog inputs channel(s) <- array input [1 2 3]

% use for precision
% input_range_channel = 10;   % Input range +/- (Volts) <- less sensitive
% input_range_channel = 5;    % Input range +/- (Volts)
input_range_channel = 0.5;  % Input range +/- (Volts)
% input_range_channel = 0.05; % Input range +/- (Volts) <- more sensitive

% can only be as large as input_range_channel
sensor_range_channel = 0.5;      % Sensor range +/- (Volts)  

% use for scaling -> units range = sensor range
units_range_channel = sensor_range_channel;  % Units Range +/- (Volts)
allinfo = true;                 % Display Summary of Analog Input (AI) Object Using 'PCI-DAS6025'

% fixed variables (hardware etc.)
daq_type = 'mcc';                % Set adapter type
daq_hw_id = '1';                 % Hardware ID
trigger_type = 'Immediate';      % Set trigger type -> Triggerd immediate when start is executed
required_samples = floor(sample_rate * duration);

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
addchannel(AI,hwchannels);

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
grid on

end