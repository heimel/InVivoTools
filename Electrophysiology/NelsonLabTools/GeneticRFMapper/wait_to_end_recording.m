function wait_to_end_recording(cksds,testname)
%WAIT_TO_END_RECORDING waits until stims.mat is written
%  
%  WAIT_TO_END_RECORDING(CKSDS,TESTNAME)
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel (heimel@brandeis.edu)
%
  finished_recording=0;
  disp('Showing stimulus...' ); 
  while ~finished_recording
    pause(0.2);
    if exist([ getpathname(cksds) testname '/stims.mat'])
      pause(0.2); % to make sure stims.mat is fully written
      finished_recording=1;
    end    
  end
  pause(3); % transfering data takes a while after writing stims.mat
  fprintf('Please extract.\n');

