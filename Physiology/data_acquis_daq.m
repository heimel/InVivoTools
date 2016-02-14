function data_acquis_daq(parameter_file_name)
%data_acquis_daq(parameter_file_name) needs the parameter file name from
%the init_phys.. script to run.
%
%   Loops the acquisition, although the actual acquisition is done in the
%   call back functions. This script starts the Analog Input objects and
%   outputs the progress.
%
%   (c) 2016, Simon Lansbergen.
% 


%-------------------------------------------------------------------------%
% Simulate acquisition outside InVivoTools? true/false
input_arg.simulate = false;
%-------------------------------------------------------------------------%


% checks whether running in simulation mode
if input_arg.simulate == true
     [input_arg.save_dir_temp] = daq_simulation();
end

% finds and stops active data acquisistion-objects and terminates them
if (~isempty(daqfind)) 
    stop(daqfind)      
end 

% put in checks for pc system pcwin, unix, mac-os
% to generalize code and improve compatibility
if ispc == 1;
    disp('This system is a Windows based computer');
    % follow-up statement
    
elseif isunix == 1;
    disp('This system is a Linux based computer');
    % follow-up statement
    
elseif ismac == 1;
    disp('This system is a Mac based computer');
    % follow-up statement
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load Parameter Settings %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Use daq_parameters() vendor specific function (e.g. MCC DAQ PCI  
% DAS-6025 -> daq_parameters_mcc() ). Look into the help file of
% daq_parameters to check if input_arg are mandatory.

load_parameters = str2func(parameter_file_name);

% load specific parameters and analog input object readily configured, if
% not specified the default settings (daq_parameters) will be used.
[ai, ~] = load_parameters( input_arg );    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% On-Screen Session Information %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% session_number = (ai.TriggerRepeat + 1);
% session_info_string = ' -> Total session(s) this run : %d';
% session_info_str = sprintf(session_info_string, session_number);
% disp(' ');
% disp(session_info_str);
disp(' ');
logmsg(' *** Acquisition waiting for trigger(s) ***');
disp(' ');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Data Aqcuisition Loop %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The main while loop runs as long as the Analog Input Objects is active,
% either waiting for an external trigger or acquiring session data. When 
% there are  no triggers left and no active acquisition, the loop breaks.
% The aqcuisition and saving this data is done in the run_trigger trigger
% call back function

% activate Analog Input Object -> either waits for trigger or starts immediatly
start (ai);                               

% main while loop -> now fixed for mic and mcc input *** NEED REVISION ***
counter = 1;
while true  
   
    if (ai(1).TriggersExecuted == 1 && counter == 1);
        logmsg(' *** Acquisition Started ***')
        trigger(ai(2));
        counter = counter + 1;
    end
    
    % breaks from loop if daq is inactive (i.e. waiting for start command)
    if strcmp(ai.Running,'Off')
        disp(' *** Acquisition ended, wait for processing and saving ***');
        break
    end
    
    % what to do in this loop, and how to show progres?
end

end

