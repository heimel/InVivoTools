function neuron=gaborneuron(window,duration,center,time,sigma,freq,phase,rotation)
%GABORNEURON creates gabor-neuron struct
%
% NEURON=GABORNEURON(WINDOW,DURATION,CENTER,SIGMA,ROTATION,FREQ,PHASE)
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if nargin<7
  rotation=eye(3);
end
if nargin<6
  phase=pi/3;
end
if nargin<5
  len=rotation*[window duration]';
  freq=3/( len(1));
end
if nargin<4
  sigma=[window(1)/6 window(2)/6 duration/4];
end
if nargin<3
  center=[window(1)/2 window(2)/2 duration/2];
end

neuron.type='gabor';
neuron.center=center;
neuron.sigma=sigma;
neuron.freq=freq;
neuron.phase=phase;
neuron.rotation=rotation;