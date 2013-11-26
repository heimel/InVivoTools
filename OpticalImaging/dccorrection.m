function img=dccorrection(img,roi)
%DCCORRECTION removes per stimulus the mode (following Schuett PhD-thesis)
%
%   IMG=DCCORRECTION(IMG)
%     where img = M x N x N_STIMULI

if nargin<2
  roi=[];
end

%correction_type='mode';
correction_type='mode';
  
for stim=1:size(img,3)
  intensity=img(:,:,stim);
  if ~isempty(roi)
       intensity=intensity(find(roi'>0));
  end
  switch correction_type
    case 'mode'
      [n,x]=hist(intensity(:),1000);
      n=smoothen(n,4);
      [m,i]=max(n);
      mode=x(i);
      
      img(:,:,stim)=img(:,:,stim)-mode;
    case 'mean'
      img(:,:,stim)=img(:,:,stim)-mean(intensity(:));
    case 'max'
      img(:,:,stim)=img(:,:,stim)-max(intensity(:));
  end
end
