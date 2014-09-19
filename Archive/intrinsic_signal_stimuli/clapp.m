% clapp
%
% show checkerboard,
%   blank=0 testing=1, ltp-induction=2
% 
%
% 2006-03-27 JFH: new
% 2006-08-31 JFH: some edits

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
n_x=2
n_y=2
width=width/n_x;
height=height/n_y;



% base stimulus parameters
par=struct('angle1',90); % angle (deg)
par.angle2=0;
par.sf=0.05;     % temporal frequency (Hz)            
par.tf=0;   % spatial frequency (cpd)
par.time=0.033; %   % time (s) 
par.color_high=WhiteIndex(window)/2;
par.color_low=BlackIndex(window);
%par.background=(par.color_high+par.color_low)/2;
par.background=0;
par.contrast=0.9; % from 0 to 1, 90% contrast matches Porciatti et al.1999
par.rect=[0 0 width height];
par.prestim_time=3;
par.poststim_time=2; % after which a reset stim in shown in bottom
par.resetstim_time=1; % time to show reset stim
par.randomize=1;
par.function='sign';


% manual gamma correction
gamma_corrected_clut(window);

% computing cocktail stimulus
Screen(window,'FillRect',par.background);
Screen(window,'TextSize',24);
Screen(window,'DrawText','Computing the movies ...',10,30,255);
clear('w');
w=plaid(par);

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
    switch stim
        case 0
            % blank
        case 1 % test 
        disp('test')
        col=0;
        row=0;  % top row
        rect=[col*width row*height (col+1)*width (row+1)*height];
        pause(par.prestim_time);
        show_movie(window,w,rect,0.3,par.background);
%        show_movie(window,w,rect,0.3,par.background);
%        show_movie(window,w,rect,par.time,par.background);
        case 2
         % induction (do nothing) 
        disp('induction')    
        col=0;
        row=0;  % top row
        tic
        rect=[col*width row*height (col+1)*width (row+1)*height];
        for i=1:1000
            show_movie(window,w,rect,par.time,par.background);
            pause( 1/9 - par.time );
%            pause( 1 - par.time );

        end
        toc
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
