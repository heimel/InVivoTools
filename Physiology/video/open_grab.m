function open_grab(recording_time,output_reference,output_reference_num)
%OPEN_GRAB.m video acquisition script which runs the video acquistion
%executable from system().
%-------------------------------------------------------------------------%
%
%   This script executes the video acquisition executable via system(). Make
%   sure grabavi.exe is in the root directory of the video acquisition
%   software!
%   
%   The recording time and save directory (already in the prefered syntax) 
%   are provided from main_getvideo() script, see help main_getvideo().
%   
%   The executable grabavi.exe takes the following syntax, when used in the
%   InVivoTools toolbox: grabavi.exe 'seconds->numeric' 'save directory'.
%   The seconds and save directory are translated to the prefered spacing
%   and are suited with \\ to separate directories (eg. c:\\dir\\dir2\\).
%
%
%
%   ADD INFO
%
%   Last edited 15-4-2016. SL
%
%
%   (c) 2016, Simon Lansbergen.
%
%-------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%        Set Paths etc.        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set executable name
run_exe = 'grabpupilsize ';

% set recording time
rec_time = num2str(recording_time);

% set final command to run
run_this = [run_exe rec_time ' ' output_reference_num ' ' output_reference];
%run_this = run_exe;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%        Video Recording       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% run video executable -> fails when grabavi.exe is not present in root dir
[~,cmdout] = system(run_this);

% output command-line info from executable
disp(cmdout);



end