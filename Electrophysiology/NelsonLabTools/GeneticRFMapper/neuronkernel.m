function kernel=neuronkernel( window, duration, neuron )
%NEURONKERNEL creates kernel array 
%
%  KERNEL=NEURONKERNEL( NEURON )
%    creates kernel array of size WINDOW(1)xWINDOW(2)xDURATION
%    of neuron described by struct NEURON
%
% general:
%   NEURON.TYPE      'gabor','cs'
%   NEURON.CENTER    centerlocation (x,y,t) (in virtual pixels)
%  
% specific for 'gabor'
%   NEURON.SIGMA    3d vector with stddevs of gaussians (in
%                   vpixels) (x,y,t)
%   NEURON.ROTATION 3x3 rotation matrix
%   NEURON.FREQ     freq (in 1/vpixels)
%   NEURON.PHASE    phase
%
% specific for 'cs'
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
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if nargin<3
  neuron.type='gabor';
end

switch neuron.type
 case 'gabor'
  kernel=gaborkernel(window,duration);
 case 'cs'
  kernel=cskernel(window,duration);
end





