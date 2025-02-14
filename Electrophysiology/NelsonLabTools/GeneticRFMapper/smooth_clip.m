function clip=smooth_clip(clip)
%SMOOTH_CLIP smoothes clip for visual presentation
%
% CLIP=SMOOTH_CLIP(CLIP)
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%


for t=1:length(clip)
  clip{t}=smooth3(clip{t});
end
