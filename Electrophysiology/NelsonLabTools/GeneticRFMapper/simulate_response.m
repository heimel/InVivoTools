function response=simulate_response(chromosomes,kernel,nonlinearity,param)
%SIMULATE_RESPONSE calculates response of a LN neuron to clip(s) 
%
%  RESPONSE=SIMULATE_RESPONSE(CHROMOSOMES,KERNEL,NONLINEARITY,PARAM)
%
%  CHROMOSOMES should be a cell list of chromosomes, which
%  are arrays of gene structures
%
%  KERNEL is a X x Y x T x 3 array describing a neuron's linear
%  kernel
%
%  NONLINEARITY is a string containing the name of the nonlinearity
%   e.g. 'thresholdlinear'
%  
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%
squirrelcolor;

if nargin<4
  param=genetic_defaults;
end


clips = create_pseudoclips( chromosomes, param);


window=[size(clips{1}{1},1) size(clips{1}{1},2)];
duration=length(clips{1});

if nargin<3
  nonlinearity='poissonfiring';
  %nonlinearity='thresholdlinear';
end
if nargin<2
  kernel=neuronkernel(window,duration);
end



shiftmask(:,:,1)=0.5*squirrel_white(1)*ones([window])/255;
shiftmask(:,:,2)=0.5*squirrel_white(2)*ones([window])/255;
shiftmask(:,:,3)=0.5*squirrel_white(3)*ones([window])/255;
for c=1:length(clips)
  clip=clips{c};
  duration=length(clip);
  window=[size(clip{1},1) size(clip{1},2)];
  
  for t=1:duration
    shiftedclip{t}=clip{t}-shiftmask;
  end
  
  for t=1:2*duration-1
    resp(c,t)=0;
    for tau=max(0,t-duration):min(duration-1,t-1)
      %k=reshape(kernel(:,:,t-tau,:),[window(1) window(2) 3]);
      %this is equivalent to
      %k=squeeze(kernel(:,:,t-tau,:));
      k=kernel(:,:,t-tau,:);
      if t-tau>=1 & t-tau<=duration
	resp(c,t)=resp(c,t)+k(:)'*shiftedclip{t-tau}(:);
      end
    end
    
  end
  
  for i=1:param.repeats
    response(c,:,i)=feval(nonlinearity,resp(c,:));
  end
end
