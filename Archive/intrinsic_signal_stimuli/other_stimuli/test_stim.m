% test_stim
%
% 2005-04-05 JFH: Nieuw


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

time=3;
n_x=1
n_y=1
width=width/n_x;
height=height/n_y;



% base stimulus parameters
%  W=CIRCLES(PAR)
%       PAR.RECT [ x_left y_top x_right y_bottom ]
%       PAR.TIME 
%       PAR.BACKGROUND
%       PAR.CIRCLE_RATE  number of new circles per second
%       PAR.CIRCLE_DURATION   if [2x1] interpreted as gaussian
%       PAR.CIRCLE_RADIUS (deg)   if  [2x1] interpreted as gaussian
par=struct('time',3); % time (s)
par.rect=[0 0 width height];     
par.color_high=WhiteIndex(window)/2;
par.color_low=BlackIndex(window);
par.background=(par.color_high+par.color_low)/2;
par.circle_duration=0.1; % s
par.circle_rate=10; % Hz
par.circle_radius=10; % degs
par.prestim_time=0.5;

% manual gamma correction
gamma_corrected_clut(window);

% computing cocktail stimulus
Screen(window,'FillRect',par.background);
Screen(window,'TextSize',24);
Screen(window,'DrawText','Computing the movies ...',10,30,255);
clear('w');
w=circles(par);

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
