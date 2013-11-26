function m=wave(size,center,freq,phase,rotation)
%WAVE produces array with plane wave
%
%  M=WAVE(SIZE,CENTER,FREQ,PHASE,ROTATION)
%    SIZE is vector with size of each dimension
%    CENTER is vector with center
%    FREQ is frequency
%    PHASE is phaseshift 
%    ROTATION is rotation matrix
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if nargin<5
  rotation=eye(length(size));
end
if nargin<4
  phase=0;
end
if nargin<3
  freq=1/4;
end
if nargin<2
  center=ceil(size/2);
end

m=zeros(size);
for i=1:prod(size)
  index = location(i,size);
  x = index - center;
  x = rotation*x';
  m(i)=sin( 2*pi*freq*x(1) + phase);
end


function index=location(pos,size)
  for i=length(size):-1:1
    subdimsize=prod(size(1:i-1));
    index(i)=ceil(pos/subdimsize);
    pos=pos-(index(i)-1)*subdimsize;
  end
  
    