function w=circles(par)
%CIRCLES makes movie of flickering circles
%
%  W=CIRCLES(PAR)
%       PAR.RECT [ x_left y_top x_right y_bottom ]
%       PAR.TIME 
%       PAR.BACKGROUND
%       PAR.CIRCLE_RATE  (Hz) number of new circles per second
%       PAR.CIRCLE_DURATION  (s) if [2x1] interpreted as gaussian
%       PAR.CIRCLE_RADIUS (deg) if  [2x1] interpreted as gaussian

global whichScreen monitorframerate 


%gray=(par.color_high+par.color_low)/2;
%inc=(par.color_high-gray)*par.contrast;


n_frames=round(monitorframerate*par.time); 

width=par.rect(3)-par.rect(1)
height=par.rect(4)-par.rect(2)


for i=1:n_frames
    w(i)=Screen(whichScreen,'OpenOffscreenWindow',0,par.rect);
    Screen(w(i),'FillRect',par.background);    
end 



rate=par.circle_rate*par.time/n_frames; % rate per frames
duration=par.circle_duration*par.time/n_frames;
radius=par.circle_radius*pixels_per_degree;
f=1
while f<=n_frames
   f=f+random('exp',1/rate) % 1 interval from exponential distr.
   x=round(rand(1)*width)
   y=round(rand(1)*height)
   rect=[x-radius y-radius x+radius y+radius]
   fs=round(f:f+duration) 
   fs=mod(fs,n_frames)+1 % wrap round
   for fi=fs
       screen(w(fi),'FillOval',par.color_high,rect)
   end 
end
