function m=gaussian(size,center,sigma,rotation,normalized)
%GAUSSIAN produces array with gaussian function
%
%  M=GAUSSIAN(SIZE,CENTER,SIGMA,ROTATION,NORMALIZED)
%    SIZE is vector with size of each dimension
%    CENTER is vector with center
%    SIGMA is vector with std.dev
%    ROTATION is rotation matrix
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%
if nargin<5
    normalized = [];
end
if isempty(normalized)
    normalized = false;
end

if nargin<4
    rotation = [];
end
if isempty(rotation)
    rotation=eye(length(size));
end
if nargin<3
  sigma=ones(1,length(size));
end
if nargin<2
  center=ceil(size/2);
end

m=zeros(size);
for i=1:prod(size)
  index = location(i,size);
  x = index - center;
  x = rotation*x';
  m(i)=exp( -0.5*sum((x./sigma').^2 ));
end

if normalized 
    m  = m/sum(m(:));
end

function index=location(pos,size)
  for i=length(size):-1:1
    subdimsize=prod(size(1:i-1));
    index(i)=ceil(pos/subdimsize);
    pos=pos-(index(i)-1)*subdimsize;
  end
  
    