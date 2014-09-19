% 
% show oriented gratings
% stimulus selection from parallel port

global whichScreen monitorframerate 

clear stims;
clear screen;

whichScreen=0;

% window
window=Screen(whichScreen,'OpenWindow');
monitorframerate=FrameRate(window);
background=(WhiteIndex(window)+BlackIndex(window))/2;

% base stimulus parameters
par=struct('angle',90); % angle (deg)
par.tf=4;     % temporal frequency (Hz)            
par.sf=1;   % spatial frequency (cpd)
par.time=1;   % time (s) 
par.color_high=WhiteIndex(window);
par.color_low=BlackIndex(window);
par.contrast=1; % from 0 to 1
par.rect=[0 0 640 480];

n_directions=4;
n_stimuli=n_directions;

% defining stimuli
stims(1:n_stimuli)=par;
for i=1:n_stimuli
    stims(i).angle=360/n_directions*(i-1);
end

% computing movies
Screen(window,'FillRect',background);
Screen(window,'TextSize',24);
Screen(window,'DrawText','Computing the movies ...',10,30);
for i=1:length(stims)
    w{i}=drifting_grating(stims(i));
end
Screen(window,'FillRect',background);

% waiting for stimulus signal on parallelport
lpt=open_parallelport;
ready=0;
while 1
  [go,stim]=get_gostim(lpt);
  if ~go    % go has to be off, before another stimulus is shown
      ready=1;
  end
  if go & ready
      stim
    if stim~=0 % not blank 
      show_movie(window,w{stim},par.rect,par.time,background);
    else
      % blank (do nothing) 
    end
    ready=0;
  end
  pause(0.01);
end

showcursor;

Screen('CloseAll');

