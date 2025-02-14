function kernel=onoffkernel(window,duration)
%ONOFFKERNEL creates kernel white kernel for first half, black later half
%
%  
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

par=genetic_defaults;

if nargin<2
  duration=par.duration;
end
if nargin<1
  window = par.window;
end

half=floor(duration/2);
kernel(1:window(1),1:window(2),1:half,1:3)=1;
kernel(1:window(1),1:window(2),half+1:duration,1:3)=-1;