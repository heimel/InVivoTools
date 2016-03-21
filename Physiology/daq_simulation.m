function [ save_dir_temp ] = daq_simulation()
%daqsimulation sets directory for session data and operates outside
%InVivoTools
%      
%   The function test if c:\temp exist and if not creates the directory.
%   The directory is also given to the daq_parameter function.
%    
%   2016, Simon Lansbergen.
% 

% set temp save directory for testing purpose
save_dir_temp = fullfile('c:','temp');  

disp(' ');
disp(' *** Running in simulation mode - Outside InVivoTools ***');
disp(' ');
disp(' -> Checking for existance c:\temp, used to store session data.');

% Test whether 'c:\temp' exist, if not create directory for temporarily 
% saving session data in simulation mode.
if exist(save_dir_temp, 'dir') == 0     
    mkdir(save_dir_temp);
    disp(' -> Created c:\temp for temporarily saving session data in simulation mode.');
elseif exist(save_dir_temp, 'dir') == 7
    % statement
    disp(' -> Directory c:\temp already exist and will be used to store session data in simulation mode.');
end

disp(' -> Acquisition duration set manually in daq_parameter function.');
disp(' -> See parameter setting manual......?');
disp(' ');
disp(' ');
disp(' *** Hit key to continue ***');
disp(' ');
pause; clc;


end

