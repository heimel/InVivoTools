% 
% show cocktail of drifting gratings at several positions
% stimulus selection from parallel ports
%
% 2004-12-20 JFH: added call to gamma_corrected_clut
% 2005-03-08 JFH: changed contrast to 0.9

global whichScreen monitorframerate 

clear stims;
clear screen;

whichScreen=0;

% window
window=Screen(whichScreen,'OpenWindow');
monitorframerate=FrameRate(window);
%background=(WhiteIndex(window)+BlackIndex(window))/2;
%background=BlackIndex(window);

% how many blocks
n_x=2;
n_y=2;

r=Screen(window,'Rect'); % screen size
% only use top left quadrant of monitor
width=round( (r(3)-r(1))/n_x /2) ;
height=round( (r(4)-r(2))/n_y /2);


% base stimulus parameters
par=struct('angle',90); % angle (deg)
par.tf=2;     % temporal frequency (Hz)            
par.sf=0.05;   % spatial frequency (cpd)
par.time=0.6;   % time (s) 
par.color_high=WhiteIndex(window)/2;
par.color_low=BlackIndex(window);
par.background=(par.color_high+par.color_low)/2;
%par.background=0;
par.contrast=0.9; % from 0 to 1
par.rect=[0 0 width height];
par.prestim_time=3;
par.randomize=1;
par.function='sign';

n_directions=10;
n_stimuli=n_directions;
time=par.time*n_stimuli;

% defining cocktail stimulus
stims(1:n_stimuli)=par;
for i=1:n_stimuli
    stims(i).angle=360/n_directions*(i-1);
end
if par.randomize
  shuffle=randperm(n_stimuli);
  for i=1:n_stimuli
      shuffled_stims(i)=stims(shuffle(i));
  end
  stims=shuffled_stims;
end 

gamma_corrected_clut(window);




% computing cocktail stimulus
Screen(window,'FillRect',par.background);
Screen(window,'TextSize',24);
Screen(window,'DrawText','Computing the movies ...',10,30,255);
w=[];
for i=1:length(stims)
    w=[w drifting_grating(stims(i))];
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
        row=floor( (stim-1)/n_x) ;
        col=stim-1-row*n_x;
        row=row+1;
        rect=[col*width row*height (col+1)*width (row+1)*height];
        pause(par.prestim_time);
        show_movie(window,w,rect,time,par.background);
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












