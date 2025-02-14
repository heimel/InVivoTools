function mov = clip2movie( clip, scale )
%CLIP2MOVIE make movie
%
%   MOV = CLIP2MOVIE( CLIP, SCALE )
%     SCALE is number of pixels per virtual pixels
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if nargin<2
  scale=1;
end

if scale==1  %quick
  for f=1:length(clip)
    mov(f)=im2frame( clip{f} );
  end
else
  scale=ceil(scale);
  for f=1:length(clip)
    for sx=0:(scale-1)
      for sy=0:(scale-1)
      scaledclip(sx+1:scale:sx+scale*size(clip{f},1),...
		 sy+1:scale:sy+scale*size(clip{f},2),:)=...
	  clip{f}(:,:,:);
      end
    end
    mov(f)=im2frame( scaledclip );
  end
end
  
