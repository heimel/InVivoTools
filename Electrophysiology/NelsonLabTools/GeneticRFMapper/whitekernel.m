function kernel=whitekernel(window,duration)
%WHITEKERNEL creates completely +1 kernel
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

kernel(1:window(1),1:window(2),1:duration,1:3)=1;