% contrast
%
% show cocktail of reversing gratings at several positions
% stimulus selection from parallel port
%
% 2008-08-08 JFH: newly created by copying sf_contrast
% 2008-08-08 JFH: set spatialfrequencies to 0.1cpd
% 2008-08-08 JFH: contrasts = [0.2 0.4 0.6 0.75 0.9];

spatialfrequencies=[0.1];
contrasts=[0.2 0.4 0.6 0.75 0.9];

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


n_stimuli=length(spatialfrequencies)*length(contrasts);
time=3;
n_x=2
n_y=2

width=width/n_x;
height=height/n_y;


% base stimulus parameters
par=struct('angle',90); % angle (deg)
par.tf=2;     % temporal frequency (Hz)            
par.sf=max(spatialfrequencies);   % spatial frequency (cpd)
par.time=time;   % time (s) 
par.color_high=WhiteIndex(window)/2;
par.color_low=BlackIndex(window);
par.background=(par.color_high+par.color_low)/2;
%par.background=0;
par.contrast=0.9; % from 0 to 1, 90% contrast matches Porciatti et al.1999
par.rect=[0 0 width height];
par.prestim_time=3;
par.poststim_time=2; % after which a reset stim in shown in bottom
par.resetstim_time=1; % time to show reset stim
par.randomize=1;
par.function='';

for i=1:n_stimuli
  stims(i)=par;
  stims(i).sf=spatialfrequencies(mod(i-1,length(spatialfrequencies))+1);
  stims(i).contrast=contrasts(floor((i-1)/length(spatialfrequencies))+1);
end


%  defining cocktail stimulus
directions=[0 45 90 135];
n_directions=length(directions);
if par.randomize
  directions=directions(randperm(n_directions))
end 

% manual gamma correction
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
        w{i}=[w{i} reversing_grating(stim)];
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
        if stim>n_stimuli
          showcursor;
          Screen('CloseAll')
          disp('Requested stimulus number larger than number of available stimuli.')
          return
        end

        col=0;
        row=0;  % top row
        rect=[col*width row*height (col+1)*width (row+1)*height];
        pause(par.prestim_time);
        show_movie(window,w{stim},rect,time,par.background);
        pause(par.poststim_time);
        row=1;  % bottom row
        rect=[col*width row*height (col+1)*width (row+1)*height];
        show_movie(window,w{stim},rect,par.resetstim_time,par.background);
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