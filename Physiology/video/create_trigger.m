function [trigger]=create_trigger(recording_time)
%CREATE_TRIGGER.m creates an analog input object called trigger, which is 
%used to trigger open_grab() via main_getvideo().
%-------------------------------------------------------------------------%
%
%   Dedicated script for NI 6008 USB data acquistion board. Creates an
%   analog object. The AI is used for triggering the video acquistion
%   executable. Matlab 32-bit (incl data acquisition toolbox) mandatory.
%   
%   Sets a recording session at a sample rate of 5000 for the duration of
%   the total acquisition time(throu the provided variable 'recording_time')
%   such that a follow-up TTL pulse will not trigger unwanted behaviour.
%
%   Used scripts:
%       analoginput()
%       addchannel()
%
%   Last edited 7-3-2016. SL
%
%   *** REVISION:
%           -> Check if addchannel() is needed to run AI (line 49)
%
%
%
%   (c) 2016, Simon Lansbergen.
%
%-------------------------------------------------------------------------%



% Pre Settings
trigger_type     = 'HwDigital';
trigger_cond     = 'TrigPosEdge';
trigger_repeat   = 0;
sample_rate      = 5000;
required_samples = floor(sample_rate * recording_time);

% Create Analog Input object
trigger = analoginput('nidaq','0');

% Setup AI parameters
set(trigger, 'TriggerType',       trigger_type);
set(trigger, 'TriggerCondition',  trigger_cond);
set(trigger, 'TriggerRepeat',     trigger_repeat)
set(trigger, 'SamplesPerTrigger', required_samples);

% Add channel to run AI (is this needed?)
addchannel(trigger,1)  % <- check HW channel!


end