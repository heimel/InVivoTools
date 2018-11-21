% 
% show cocktail of drifting gratings at several positions
% stimulus selection from parallel port
%
%  settings of 2004-09-07:
%     all stims: single bar moving at 0.125 Hz with SF=0.0125  
%     stim 1: bar moving leftwards, starting from left side of screen
%     stim 2: bar moving upwards, starting from top of screen
%     stim 3: bar moving rightwards, starting from left side of screen
%     stim 4: bar moving downwards, starting from top of screen
%
% 2004-12-20 JFH: Added call to gamma_corrected_clut

global whichScreen monitorframerate 

clear stims;
clear screen;

whichScreen=0;

waitframes=10; % to reduce number of frames to calculate and show

% window

window=Screen(whichScreen,'OpenWindow');
monitorframerate=FrameRate(window)/waitframes;
%background=(WhiteIndex(window)+BlackIndex(window))/2;
%background=BlackIndex(window);

PsychDebugWindowConfiguration


rect=Screen(window,'Rect'); % screen size
disp(rect)

% base stimulus parameters
par=struct('angle',90); % angle (deg)
%par.tf=0.125;     % temporal frequency (Hz)            
%par.tf=0.125; %changed 2004-09-07 after exp26    % temporal frequency (Hz)            
par.tf=0.09987  ; % to calculate less frames % to be used with acqtime:580747ms, 12camframperdataframe
%par.tf=0.1257; %Hz, (73 cycles) to be used with acqtime: 580747ms
%par.tf=0.19974; %Hz (116 cycles) to be used with acqtime: 580747ms
%%%%
par.sf= 0.0048 ; %1 / (640/pixels_per_degree); % 0.0125;   % spatial frequency (cpd)
par.time=20; %1/par.tf ;   % time (s) 
par.color_high=WhiteIndex(window)/2;
par.color_low=BlackIndex(window);
%par.background=(par.color_high+par.color_low)/2;
par.background=0;
par.contrast=1; % from 0 to 1
par.rect=rect;
par.prestim_time=0;
par.randomize=1;
par.function='top';

n_directions=4;
n_stimuli=n_directions;

% defining cocktail stimulus
stims(1:n_stimuli)=par;
for i=1:n_stimuli
    stims(i).angle=360/n_directions*(i-1);
    stims(i).phase=pi/2;
end


gamma_corrected_clut(window);


% computing cocktail stimulus
Screen(window,'FillRect',128);
Screen(window,'TextSize',24);
Screen(window,'DrawText','Computing the movies ...',10,30,255);

Screen(window,'Flip');

clear('w');
for i=1:length(stims)
    w{i}=drifting_grating(stims(i));
end
Screen(window,'FillRect',par.background);
Screen(window,'Flip');


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
        show_movie(window,w{stim},par.rect,par.time,par.background,waitframes,1);
    else
      % blank (do nothing) 
    end
    %ready=0;
  end
  pause(0.001);
%  if kbcheck
%      stop=1;
%  end
end

showcursor;

Screen('CloseAll');
