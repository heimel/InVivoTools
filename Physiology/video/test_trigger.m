recording_time = 10;

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



% Add channel to run AI (is this needed?)  <- Yes!
addchannel(trigger_vid,0);  % <- check HW channel!


start(trigger_vid);

logmsg(' *** Waiting for trigger ***')

counter = 1;
while true  
 
    % *** when acquisition is triggered ***
    if (trigger_vid(1).TriggersExecuted == 1 && counter == 1);
        clc
        logmsg(' *** Acquisition Started ***')
        counter = counter + 1;
        
        % Start Video executable run script.
        %open_grab(recording_time,output_reference);
                               
    end
    
    % *** when acquisition time ends ***
    % breaks from loop if daq is inactive (i.e. waiting for start command)
    if strcmp(trigger_vid.Running,'Off')
        logmsg(' *** Acquisition ended, returning to init_getvideo() ***');
        break
    end
    
end