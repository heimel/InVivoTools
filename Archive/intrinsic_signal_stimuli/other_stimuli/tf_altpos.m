% tf_altpos 
%
% show cocktail of reversing gratings at several positions
% stimulus selection from parallel port
%
% 2005-03-14 JFH: Nieuw
% 2005-03-15 JFH: Changed from 4 to 2 orientation
% 2005-03-15 JFH: Changed contrast from 90 to 50%


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

width=640;
height=240;

temporalfrequencies=[2.5 5 10 20];
n_stimuli=length(temporalfrequencies);
time=3;
n_x=2
n_y=2


% base stimulus parameters
par=struct('angle',90); % angle (deg)
par.sf=0.05;     % temporal frequency (Hz)            
par.tf=max(temporalfrequencies);   % spatial frequency (cpd)
par.time=time;   % time (s) 
par.color_high=WhiteIndex(window)/2;
par.color_low=BlackIndex(window);
par.background=(par.color_high+par.color_low)/2;
%par.background=0;
par.contrast=0.5; % from 0 to 1, 90% contrast matches Porciatti et al.1999
par.rect=[0 0 width height];
par.prestim_time=3;
par.randomize=1;
par.function='sign';

for i=1:n_stimuli
  stims(i)=par;
  stims(i).tf=temporalfrequencies(i);
end


%  defining cocktail stimulus
%directions=[0 45 90 135];
directions=[0 90];
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
        col=0;
        row=floor(stim/8);  % odd stimuli upper row
        rect=[col*width row*height (col+1)*width (row+1)*height];
        stim=mod(stim-1,8)+1;
        if stim>n_stimuli
          showcursor;
          Screen('CloseAll')
          disp('Requested stimulus number larger than number of available stimuli.')
          return
        end
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
