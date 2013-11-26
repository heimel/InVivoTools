function frame=combine_compressed_frames( framelist )
%COMBINE_FRAMES takes cell list of compressed frames and merges them
%
%   FRAME=COMBINE_FRAMES( FRAMELIST )
%      FRAMELIST = { XxY, X+1xY, X+2xY ..}
%
% April 2003, Alexander Heimel, heimel@brandeis.edu


n_frames=length(framelist);

compression=sqrt(n_frames);
if compression~=round(compression)
  disp('Error: not a full set of frames');
end

xsize=size(framelist{1},1);
ysize=size(framelist{1},2);

frame=zeros(xsize*compression,ysize*compression);

yvals=(0:ysize-1)*compression;
xvals=(0:xsize-1)*compression;
for y=1:compression
  for x=1:compression
    frame(xvals+x,yvals+y)=framelist{(y-1)*compression+x};
  end
end

