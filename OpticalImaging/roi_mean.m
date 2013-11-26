function meanstim=roi_mean(avg,roi,show)
%ROI_MEAN calculates mean of all stimuli in roi
% 
% MEANSTIM=ROI_MEAN(AVG,ROI,SHOW)
%
%   AVG=XxYxStim
%   ROI=XxY with 1 on pixels in ROI
%   SHOW={0,1} if 1 show results
%

if nargin<3
  if nargout==1
    show=0;
  else
    show=1;
  end
end
  
if nargin<2
  roi=[];
end

if isempty(roi)
  roi=ones(size(avg,1),size(avg,2));
end

for stim=1:size(avg,3)
  avgstim=avg(:,:,stim)';
  % notice transpose in line above
  % ROI is coordinates from the images, which
  % are transposes of the arrays AVG(:,:,stim)
  
  meanstim(stim)=mean(avgstim(find(roi>0)));
  if show
    disp([' ROI mean stim ' num2str(stim) ': ' ...
	  num2str(meanstim(stim))  ]);
  end
end

