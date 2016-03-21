function [ ai_mic ] = load_microphone(settings)
%LOAD_MICROPHONE
%   
%   Changes to the microphone Analog Input object can be made here.
%   Configuration dedicated to Dodotronic Ultramic 250kHz
%   
%
%   Last edited 7-3-2016. SL
%
%   *** REVISION:
%           -> Extended sample rate needs to be checked (calibrated).
%
%
%   (c) 2016, Simon Lansbergen.
%   


% overwrite current settings
settings_mic.daq_hw_id = '0';
settings_mic.daq_type = 'winsound';
settings_mic.hwchannels = 1;
settings_mic.hwnames = 'UltraSonic Mic';
settings_mic.trigger_type = 'Manual';

% *** Extended range to 250kHZ ***
% Set sample rate (Hz), max = 250kHz, min = 5 kHz.
settings_mic.sample_rate = 250000;
% settings_mic.sample_rate = 96000;

% copy relevant information from daq_parameters
settings_mic.duration = settings.duration;
settings_mic.samples_per_trigger = settings.samples_per_trigger;

settings_mic.trigger_cond = settings.trigger_cond;
settings_mic.trigger_repeat = settings.trigger_repeat;


% For each channel the InputRange, SensorRange, UnitsRange and Units can be
% changed. If there is more than one channel, each channel has to be
% configured (and added if not present) separately.
settings_mic.input_range_channel(1) = 1;    % Input Range is restricted to 1 and -1
settings_mic.sensor_range_channel(1) = 1;   % Input sensor is restricted to 1 and -1
settings_mic.units_range_channel(1) = 1;    % Unit Range is restricted to 1 and -1

% call create_analog_object
[ai_mic,~] = create_analog_input(settings_mic);

% set specific call back function for microphone recordings
set(ai_mic, 'TriggerFcn', {@run_trigger_mic,settings});

% Set bit rate, max 32.
set(ai_mic, 'Bits', 32);
% set(ai_mic, 'SampleRate', 96000);
set(ai_mic, 'SampleRate', 250000);

end

