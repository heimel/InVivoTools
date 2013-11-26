% 
% show cocktail of drifting gratings at several positions
% stimulus selection from parallel port
%
% 2004-12-22 JFH: Added gamma_corrected_clut
% 2005-02-18 JFH: Change SF from 0.05 to 0.1
% 2005-02-18 JFH: Changed time from 6 to 3s
% 2005-03-01 JFH: Changed from half width to full screen width
% 2005-03-08 JFH: Changed to square wave stimulus
% 2005-03-08 JFH: Changed to upper half of screen
% 2005-03-08 JFH: Changed to 2 Hz

global whichScreen monitorframerate 

clear stims;
clear screen;

whichScreen=0;

% window
window=Screen(whichScreen,'OpenWindow');
monitorframerate=FrameRate(window);
%background=(WhiteIndex(window)+BlackIndex(window))/2;
%background=BlackIndex(window);


r=Screen(window,'Rect'); % screen size
width=r(3)-r(1);
height=r(4)-r(2);

%width=320;
height=240;

contrasts=[0.1 0.4 0.7 0.9]
n_stimuli=length(contrasts);
n_directions=4;
time=3;


% base stimulus parameters
par=struct('angle',90); % angle (deg)
par.tf=2;     % temporal frequency (Hz)            
par.sf=0.05;   % spatial frequency (cpd)
par.time=time/n_directions;   % time (s) 
par.color_high=WhiteIndex(window)/2;
par.color_low=BlackIndex(window);
par.background=(par.color_high+par.color_low)/2;
%par.background=0;
par.contrast=1; % from 0 to 1
par.rect=[0 0 width height];
par.prestim_time=3;
par.randomize=1;
par.function='sign';

for i=1:n_stimuli
  stims(i)=par;
  stims(i).contrast=contrasts(i);
end


% defining cocktail stimulus
directions=360/n_directions*(0:n_directions-1);
if par.randomize
  directions=directions(randperm(n_directions));
end 

gamma_corrected_clut(window);

% computing cocktail stimulus
Screen(window,'FillRect',par.background);
Screen(window,'TextSize',24);
Screen(window,'DrawText','Computing the movies ...',10,30,255);
clear('w');
for i=1:length(stims)
    w{i}=[];
    stim=stims(i);
    for j=1:n_directions
        stim.angle=stims(i).angle+directions(j);
        w{i}=[w{i} drifting_grating(stim)];
    end    
end
Screen(window,'FillRect',par.background);

% waiting for stimulus signal on parallelport
lpt=open_parallelport;
ready=0;
stop=0;
while ~stop
  [go,stim]=get_gostim(lpt);
  if ~go    % go has to be off, before another stimulus is shown
      ready=1;
  end
  if go & ready
      stim
    if stim~=0 % not blank 
        rect=[0 0 width height];
        pause(par.prestim_time);
        show_movie(window,w{stim},rect,time,par.background);
    else
      % blank (do nothing) 
    end
    ready=0;
  end
  pause(0.01);
%  if kbcheck
%      stop=1;
%  end
end

showcursor;

Screen('CloseAll');
