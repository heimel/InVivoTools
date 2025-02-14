function clip = kernel2clip( kernel )
%KERNEL2CLIP transform kernel into clip format
%
%   CLIP = KERNEL2CLIP( KERNEL )
%     SCALE is number of pixels per virtual pixels
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

duration = size(kernel,3);

maxi=kernel(1,1,1,1);
mini=kernel(1,1,1,1);
for f=1:duration
  clip{f}=squeeze(kernel(:,:,f,:));
  m=max(clip{f}(:));
  if m>maxi
    maxi=m;
  end
  m=min(clip{f}(:));
  if m<mini
    mini=m;
  end
end

if maxi-mini~=0
  for f=1:duration
    clip{f}=(clip{f}-mini)/(maxi-mini);
  end
end


