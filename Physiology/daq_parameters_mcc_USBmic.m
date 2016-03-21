function [ ai_vec, settings ] = daq_parameters_mcc( input_arg )
%daq_parameters_mcc(input_arg) gives acquisition pre-set parameters to main 
%script.
%   
%   Can be used either with 'input_arg' as an input argument or without.
%
%   In this function all relevant parameters can be set for the physiology
%   data acquisition main script. The function is specifically written for
%   the DAQ PCI DAS-6025 acquisition card.
%
%   MCC DAQ PCI DAS-6025 has a fixed 12 bits per sample and 8 analog 
%   differential inputs.
%
%   Returns the vector ai_vec which contains multiple Analog Input objects.
%
%   -> to be completed: add more about functionallity in header
%                       add check code to check if mic is connected to usb
%    
%   (c) 2016, Simon Lansbergen.
%   


% set simulation off when input_arg is not defined.
if nargin<1 
    input_arg.simulate = true;
    input_arg.save_dir_temp = 'c:\temp';
end

% add check code for mic here (if connected or not)?

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Hardware Settings %%%
%%%%%%%%%%%%%%%%%%%%%%%%%

% daq_type sets the hardware fixed to the installed MCC DAQ PCI DAS-6025.
% the setting daq_hw_id sets the id of the installed hardware on the
% specific machine. This settings is likely to be changed on another system
% or setup.

settings.daq_type = 'mcc';                % Set adapter type
settings.daq_hw_id = '1';                 % Hardware ID

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Acquisition Settings MCC Hardware %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Change settings.samples_per_trigger to a value other than 0 if a manual
% input is needed for this parameter, otherwise the necessary samples per
% trigger is calculated automatically
%
% see also propinfo(ai) and help propinfo for detailed information on 
% parameter settings.

settings.sample_rate = 10000;             % Set sample rate (Hz), max = 200000Hz, min = 1Hz.
settings.trigger_type = 'Immediate';      % Set trigger type -> Triggerd immediate when start is executed
settings.trigger_type = 'HwDigital';      % Set trigger type -> Triggerd from hardware (digital channel) TTL
settings.trigger_cond = 'TrigPosEdge';    % Set trigger condition -> Triggered when a positive edge is detected
% settings.trigger_cond = 'TrigNegEdge';    % Set trigger condition -> Triggered when a negative edge is detected -> TTL convention used by stimulus-PC.
settings.samples_per_trigger = 0;         % Sets samples per trigger manually if not equal to 0.
settings.trigger_repeat = 0;              % the amount of triggered samples to be taken if false than default
                                          % when counted 0 is 1, but cannot be used eg. 10 -> 11 triggers
                                 
                             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Data Aqcuisition Timing %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Timing is obtained by reading a timer file, or by extracting the total
% number of blocks/timeslots of each measuring session. The latter is
% multiplied by 10 sec and an additional 10 seconds are added to the total
% acquisition time per session. 
%    
% Timing between sessions is less critical in terms of speed. This will not
% exceed the time it takes to load the parameters and Analog Input Object
% and should be at least more than a minute.                                        

%%% Retrieve trigger information and save directory reference from Stimulus-PC %%%
if input_arg.simulate == true
settings.duration = 10;                  % Duration of sample (seconds)
settings.data_dir = input_arg.save_dir_temp;
else
[settings.block_number, settings.data_dir] = load_reference;
% Duration is number of blocks times 10 sec + an additional extra second. 
% FIXED TIMING PARAMETER! -> DO NOT CHANGE
settings.duration = (settings.block_number * 10) + 1;                 
end


%%%%%%%%%%%%%%%%%%%%%%%%
%%% Channel Settings %%%
%%%%%%%%%%%%%%%%%%%%%%%%

% Define input channels for aqcuisition. The DAQ has 8 analog differential
% inputs labeled 0 to 7. The number of diff channels can be added in the []
% array. eg. [0 1 2 6]. Note that the first channel for MCC is 0 while this
% is not always the case with other hardware.
% With the use of {'name_channel_1','name_channel_2'} in the [] array,
% multiple names can be added to analog data object ai

settings.hwchannels = [0];                 % DAQ channel input Sinks
settings.hwnames = [{'Heart_Rate'}];           % Give name to channels

% settings.hwchannels = [0 1];                 % DAQ channel input Sinks
% settings.hwnames = [{'EMG','EKG'}];          % Give name to channels


% For each channel the InputRange, SensorRange, UnitsRange and Units can be
% changed. If there is more than one channel, each channel has to be
% configured (and added if not present) separately.

% Input Range can be set at either -5 and 5 -> enter 5, or -10 and 10 
% (default) -> enter 10. 
settings.input_range_channel(1) = 5;
settings.input_range_channel(2) = 10;
% settings.input_range_channel(3) = 5;

% Input sensor can have any value, although it is not possible (within this
% script) to set both values to different values (e.g. -1 and 1.5). Any
% value can be entered (e.g. for the range -1.5 to 1.5 enter 1.5).  
settings.sensor_range_channel(1) = 2.5;
settings.sensor_range_channel(2) = 5;
% settings.sensor_range_channel(3) = 10;

% Unit Range can be any value, although it is not possible (within this
% script) to set both values to different values (e.g. -1 and 1.5). Any
% value can be entered(e.g. for the range -1.5 to 1.5 enter 1.5).
settings.units_range_channel(1) = 2.5;
settings.units_range_channel(2) = 5;
% settings.units_range_channel(3) = 10;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Create Analog Input Object %%%      <- Load this before load_microphone
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get analog input with settings struct as an input.
% Calls function to receive readily configured analog input object.
% Trigger callback function set in create_input() function.
[ai, ai_channel_setting] = create_analog_input(settings);     


%%%%%%%%%%%%%%%%%%%%%%%
%%% Load Microphone %%%     <- Need to be loaded after ai MCC
%%%%%%%%%%%%%%%%%%%%%%%

% load fixed microphone settings with load_microphone(). This will acquire
% an Analog Object object which is fully configured for Dodotronic Ultramic
% 250kHz Ultrasonic USB microphone.

% first check if the microphone is connected

temp = daqhwinfo('winsound');
[~, winsound_count] = size(temp.InstalledBoardIds);
if winsound_count > 2
    [ai_mic]=load_microphone(settings);
else
    logmsg('Dodotronic UltraMic not detected. No sound recording from USB');
    ai_mic = 0;
end

%%%%%%%%%%%%%%%%%%%%%%
%%% Finalize Setup %%%
%%%%%%%%%%%%%%%%%%%%%%

% put both Analog Input ojects (i.e. microphone and data acquisistion card
% in one vector to start both at the same instant.
ai_vec=[ai ai_mic];

% Add miscellaneous and info to settings struct for debug analysis
settings.ai_channel_setting = ai_channel_setting;
settings.ai_propinfo        = propinfo(ai);
settings.simulate           = input_arg.simulate;

% info on configuration
disp(' ');
logmsg('*** MCC PCI DAS-6025 pre-configured Analog Input ***');
logmsg('*** Dodotronic UltraMic 250kHz pre-configured Analog Input ***');
disp(' ');
logmsg('Look into parameter function file to set specific');
logmsg('configuration settings displayed below and found in');
logmsg('settings. -> help daq_parameters_mcc()');
disp(' ');
disp(' ');

% show summarized information Analog Input objects
disp(ai_mic);
disp(ai);

end

