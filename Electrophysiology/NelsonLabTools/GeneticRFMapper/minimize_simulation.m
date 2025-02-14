function minimal_stimulus=minimize_simulation(stimulus,kernel,param)
%MINIMIZE_SIMULATION runs simulation of minimizing the optimal stimulus
%
%  MINIMAL_STIMULUS=MINIMIZE_SIMULATION(STIMULUS,KERNEL,PARAM)
%    is only a shell around MINIMIZE_STIMULUS
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if nargin<4
  param=genetic_defaults;
end
if nargin<3
  display=1;
end
if nargin<2
  kernel=gaborkernel;
end

minimal_stimulus=minimize_stimulus(stimulus,param,kernel);
