function [trigger_vid]=create_trigger(recording_time)
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
%   Last edited 8-3-2016. SL
%
%   *** REVISION:
%           -> 
%
%
%
%   (c) 2016, Simon Lansbergen.
%
%-------------------------------------------------------------------------%



% Pre Settings
trigger_type     = 'HwDigital';
trigger_cond     = 'PositiveEdge';
trigger_repeat   = 0;
sample_rate      = 1000;
required_samples = floor(sample_rate * recording_time);


% Create Analog Input object
trigger_vid = analoginput('nidaq','Dev1');

% Setup AI parameters
set(trigger_vid, 'SampleRate',        sample_rate);
set(trigger_vid, 'TriggerType',       trigger_type);
set(trigger_vid, 'TriggerCondition',  trigger_cond);
set(trigger_vid, 'TriggerRepeat',     trigger_repeat)
set(trigger_vid, 'SamplesPerTrigger', required_samples);

% Add channel to run AI (mandatory)
addchannel(trigger_vid,0);  


end