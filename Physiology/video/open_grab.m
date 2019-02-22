function open_grab(recording_time,output)
%OPEN_GRAB.m video acquisition script which runs the video acquistion
%executable from system().
%-------------------------------------------------------------------------%
%
%   This script executes the video acquisition executable via system(). Make
%   sure the executable is in the root directory of the video acquisition
%   software!
%   
%   The recording time and save directory (already in the prefered syntax) 
%   are provided from main_getvideo() script, see help main_getvideo().
%   
%
%   ADD INFO
%
%   Last edited 14-6-2016. SL
%
%   Tested up to acquisistion trigger - no simulation except triggering
%
%   (c) 2016, Simon Lansbergen.
%
%-------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%        Set Paths etc.        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% open_grab() needs to be in the video acquisition directory 
cd('c:\software\invivotools\physiology\video');

% set executable name
run_exe = 'grabpupilsize ';

% set recording time
rec_time = num2str(recording_time);

% set final command to run
run_this = [run_exe rec_time ' ' output.reference_num ' ' output.reference_num_xy ' ' output.reference];
%run_this = run_exe;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%        Video Recording       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% run video executable -> fails when grabavi.exe is not present in root dir
[~,cmdout] = system(run_this);

% output command-line info from executable
disp(cmdout);


end