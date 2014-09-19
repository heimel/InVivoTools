% 
% LINEARIZATION
%
%  presents background screen of different intensities
%  depending on selected stimulus
%  can be used to linearize stimulus monitor
%
% 2008, Alexander Heimel
%
% 2008-04-25: JFH: newly created
% 2008-04-25: stim 0 -> 0
%             stim 8 -> 255
%             


global whichScreen monitorframerate 

clear stims;
clear screen;

whichScreen=0;

% window
window=Screen(whichScreen,'OpenWindow');
monitorframerate=FrameRate(window);


maxstim=8;
color_high=WhiteIndex(window);
color_low=BlackIndex(window);


gamma_corrected_clut(window);

% waiting for stimulus signal on parallelport
lpt=open_parallelport;
ready=0;
stop=0;
while ~stop
  [go,stim]=get_gostim(lpt);
  %stim=1; % always show when go
  if ~go    % go has to be off, before another stimulus is shown
      ready=1;
  end
  if go & ready
    stim
    Screen(window,'FillRect',round(color_high/maxstim*stim));
    ready=0;
  end
  pause(0.01);
%  if kbcheck
%      stop=1;
%  end
end

showcursor;

Screen('CloseAll');



















