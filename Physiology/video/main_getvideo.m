function main_getvideo()
%MAIN_GETVIDEO.m runs video acquisition loop stand alone or is called from
%init_getvideo() script.
%-------------------------------------------------------------------------%
%
%   Main video acquisition script. Designed to be called from
%   init_getvideo() and to run stand alone, both within the InVivoTool-box.
%
%   The script retrieves the acquisition session time and save directory by
%   running load_reference(). The save directory is stripped from the
%   acqReady file and reformed to the propper input syntax for the video
%   acquisition executable. 
%
%   Each trial the acquisition is saved in the retrieved directory and
%   named pupil_mouse.avi.
%
%   A trigger is created with create_trigger() and executed, while the 
%   trigger is executedthe the script is waiting for a TTL trigger on the 
%   NI DAQ to start acquisition. During acquistion the DAQ cannot handle 
%   follow-up TTL pulses.
%   
%   Used scripts:
%       load_reference()
%       remotecommglobals()
%       create_trigger()
%       open_grab()
%
%   Last edited 8-3-2016. SL
%
%   *** REVISION:
%           -> Remove line 49, 50 and 66.
%           -> Uncomment line 58 and 78.
%
%
%
%   (c) 2016, Simon Lansbergen.
%
%-------------------------------------------------------------------------%

% initialize main_getvideo script
clc
disp(' ');
logmsg('Initialize main_getvideo.m script :');
logmsg(' - Video acquisition loop');
logmsg(' - Used in InVivoTool toolbox');
logmsg(' - Frame grabbing at 20 Hz.');
logmsg(' - Compression');
logmsg('    - Microsoft - Video 1(msvidc32.dll) fourCC -> MSVC.');
logmsg('    - compression ratio 75%.'); 
disp(' ');disp(' ');
logmsg(' *** Wait for trigger to be ready ... ***');
disp(' ');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   Load Stim. References  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [ block_number, data_dir] = load_reference;
remotecommglobals;

% *** Beta ***
data_dir     = 'c:\temp';   % <- REMOVE
block_number = 2;           % <- REMOVE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         Set Time         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% recording time is number of blocks (10 sec each) + an additional second
recording_time = (block_number * 10) + 1; % recording time in seconds


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Set Save Path and Name  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set acqReady path
% read_data = fullfile(Remote_Comm_dir,'acqReady'); 
read_data = fullfile(data_dir,'acqReady');      % <- REMOVE when done

% set file output name
file_str = 'pupil_mouse.avi';

% read data from acqReady
tmp = importdata(read_data);
% retrieve data save directory
str  = char(tmp(2));

% strip  data save directory with \ as delimiter
save_path_cell = textscan(str,'%q','Delimiter','\');
save_path_cell = save_path_cell{1};

% get number of directories incl drive
[ind, ~] = size(save_path_cell);

% loop to reconstruct save directory with \\ instead of \
% mandatory for running the grabavi executable
for i = 1:ind

    save_path = char(save_path_cell(i));
    sep = '\\';
    
    if i == 1 && i <= ind
    save_to = strcat(save_path,sep);
    elseif i >= 1 &&  i <= ind
    save_to = strcat(save_to,save_path,sep);
    elseif i == ind
    save_to = strcat(save_to,save_path);
    end
    
end

% add the output name to the save directory
output_reference = [save_to file_str];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Set and Initiate Trigger  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% creates Analog Object called trigger_vid (pre-set for NI DAQ 6008 USB)
trigger_vid = create_trigger(recording_time);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Setup Video Acquisition Loop %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% executes start command for Analog Input Object, and waits for a trigger
start(trigger_vid);

logmsg(' *** Waiting for trigger ***');disp(' ');

% main while loop -> optimized for video acquisition via open_grab()
counter = 1;
while true  
 
    % *** when acquisition is triggered ***
    if (trigger_vid.TriggersExecuted == 1 && counter == 1);
        
        logmsg(' *** Acquisition Started ***')
        counter = counter + 1;
        
        % Start Video executable run script.
        open_grab(recording_time,output_reference);
                               
    end
    
    % *** when acquisition time ends ***
    % breaks from loop if daq is inactive (i.e. waiting for start command)
    if strcmp(trigger_vid.Running,'Off')
        logmsg(' *** Acquisition ended, returning to init_getvideo() ***');
        break
    end
    
end


% Destroy trigger (Analog Input object) to prevent faulty results when
% runned in a script
stop(trigger_vid);       % Stops (all active processes on) analog input object
delete(trigger_vid);     % Deletes analog input object
clear trigger            % Removes analog input object from workspace


end