function neuron = csneuron(window,duration,center,ctime,csigmat,csigma, ...
			   ccones,stime,ssigmat,ssigma,scones)
%CSNEURON creates center-surround neuron struct
%
% NEURON = CSNEURON(WINDOW,DURATION,CENTER,CTIME,CSIGMAT,CSIGMA, ...
%			   CCONES,STIME,SSIGMAT,SSIGMA,SCONES)
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if nargin<11
  scones=[-1 -1];
end
if nargin<10
  ssigma=window/3;
end
if nargin<9
  ssigmat=duration/4;
end
if nargin<8
  stime=duration/8;
end
if nargin<7
  ccones=[1 1];
end
if nargin<6
  csigma=window/4;
end
if nargin<5
  csigmat=duration/4;
end
if nargin<4
  ctime=-duration/8;
end
if nargin<3
  center=[window/2 duration/2];
end


neuron.type='cs';
neuron.center=center;
neuron.ctime=ctime;
neuron.csigmat=csigmat;
neuron.csigma=csigma;
neuron.ccones=ccones;
neuron.stime=stime;
neuron.ssigmat=ssigmat;
neuron.ssigma=ssigma;
neuron.scones=scones;