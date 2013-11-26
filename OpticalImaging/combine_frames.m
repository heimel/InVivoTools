function frame=combine_frames( framelist )
%COMBINE_FRAMES takes cell list of compressed frames and merges them
%
%   FRAME=COMBINE_FRAMES( FRAMELIST )
%      FRAMELIST = { XxY, X+1xY, X+2xY ..}
%
% April 2003, Alexander Heimel, heimel@brandeis.edu


n_frames=length(framelist);
xsize=size(framelist{1},1);
ysize=size(framelist{1},2);

frame=ones(xsize*n_frames,ysize);

yvals=(1:ysize);
xvals=(0:xsize-1)*n_frames;
for i=1:n_frames
  frame(xvals+i,yvals)=framelist{i};
end