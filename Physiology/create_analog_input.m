function [ ai, ai_channel_setting ] = create_analog_input( settings )
%receives settings struct from daq_parameters...m and provides an analog
%input object
%
%   Analog input object created with settings provided by parameter
%   function. The object is configured and ready to implement.
%   ai_channel_settings gives detailed information about analog input
%   configuration. Do not use this to re-configure the analog input object.
%
%   Includes addition of runtrigger callback function, executed/called back
%   when triggered by TTL.
%
%
%   (c) 2016, Simon Lansbergen.
%

% Create Analog Input Object
ai = analoginput(settings.daq_type,settings.daq_hw_id);

% Setup Analog Input Object
required_samples = floor(settings.sample_rate * settings.duration);

if settings.samples_per_trigger == false
    set(ai, 'SamplesPerTrigger', required_samples);
else
    set(ai, 'SamplesPerTrigger', settings.samples_per_trigger);
end

set(ai, 'SampleRate', settings.sample_rate);
set(ai, 'TriggerType', settings.trigger_type);

if strcmp(settings.trigger_type, 'HwDigital')
    set(ai, 'TriggerCondition', settings.trigger_cond);
    if settings.trigger_repeat ~= false
        set(ai, 'TriggerRepeat', settings.trigger_repeat);
    end
end

% Add channels to Analog Input Object
ai_channel_setting = addchannel(ai,settings.hwchannels,settings.hwnames);

% configure channel specifics, set in daq_parameters function. If not
% correctly configured (i.e. missing configuration values) the vendor
% default configuration is set.

[~,size_hwchannels]=size(settings.hwchannels);
[~,size_inputrange]=size(settings.input_range_channel);
[~,size_inputsensor]=size(settings.sensor_range_channel);
[~,size_unitsrange]=size(settings.units_range_channel);

switch settings.daq_type
    case 'mcc'  % for MCC the hw channel index is 0
if size_hwchannels == (size_inputrange && size_inputsensor && size_unitsrange)    % Loop that adds proper channel configuration to channels.
    for i = 1: (max(settings.hwchannels)+1)
        ai.Channel(i).InputRange = [-settings.input_range_channel(i), settings.input_range_channel(i)];
        ai.Channel(i).SensorRange = [-settings.sensor_range_channel(i), settings.sensor_range_channel(i)];
        ai.Channel(i).UnitsRange = [-settings.units_range_channel(i), settings.units_range_channel(i)];
    end 
else
    logmsg('Channels not properly configured, see daq_parameters config-file');
    logmsg(' -> default vendor settings are applied');
end

    otherwise 
if size_hwchannels == (size_inputrange && size_inputsensor && size_unitsrange)    % Loop that adds proper channel configuration to channels.
    for i = 1: max(settings.hwchannels)
        ai.Channel(i).InputRange = [-settings.input_range_channel(i), settings.input_range_channel(i)];
        ai.Channel(i).SensorRange = [-settings.sensor_range_channel(i), settings.sensor_range_channel(i)];
        ai.Channel(i).UnitsRange = [-settings.units_range_channel(i), settings.units_range_channel(i)];
    end 
else
    logmsg('Channels not properly configured, see daq_parameters config-file');
    logmsg(' -> default vendor settings are applied');
end
     
end

% add run_trigger callback function, executed when triggered by TTL pulse
set(ai, 'TriggerFcn', {@run_trigger,settings});


end

