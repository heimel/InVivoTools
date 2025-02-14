function kernel=cskernel( window, duration, neuron )
%CSKERNEL creates kernel array from centersurround neuron
%
%  KERNEL=CSKERNEL( WINDOW, DURATION, NEURON )
%   NEURON.TYPE     'cs'
%   NEURON.CENTER   centerlocation (x,y,t) (in virtual pixels)
%   NEURON.CTIME    time of center max (in vpixels) relative to CENTER(3)
%   NEURON.CSIGMAT  duration of center stimulus (in vpixels)
%   NEURON.CSIGMA   width of center (in vpixels)
%   NEURON.CCONES   [bluecone_activitation greencone_activation]
%                   each between [-1,1]
%
%   NEURON.STIME    time of surround max (in vpixels) relatice to CENTER(3)
%   NEURON.SSIGMAT 
%   NEURON.SSIGMA  
%   NEURON.SCONES
%
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%
% NOTE! CONE-ABSORPTIONS NOT PROPERLY SET!
%

% should be different!!!!
bluecone=[0 0 1];
greencone=[0 1 0];

param=genetic_defaults;
if nargin<1
  window=param.window;
end
if nargin<2
  duration=param.duration;
end
if nargin<3
  neuron=csneuron(window,duration);
end

center=1.3*gaussian([window duration],neuron.center+[0 0 neuron.ctime], ...
	   [neuron.csigma neuron.csigmat]);
surround=gaussian([window duration],neuron.center+[0 0 neuron.stime], ...
	   [neuron.ssigma neuron.ssigmat]);
kernel=zeros([window duration 3]);

%no surround
%clear('surround');
%surround=0;
for c=1:3
  kernel(:,:,:,c)=center*(bluecone(c)*neuron.ccones(1)+...
			  greencone(c)*neuron.ccones(2))+...
      surround*(bluecone(c)*neuron.scones(1)+...
		greencone(c)*neuron.scones(2));
end

kernel=kernel/norm(kernel(:))^2;
kernel=kernel*8; % to get reasonable firing rate
