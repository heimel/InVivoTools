function show_pseudoclip( clip )
%SHOW_PSEUDOCLIP shows pseudoclip as movie
%
%  SHOW_PSEUDOCLIP( CLIP )
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%



for f=1:length(clip)
  frames(f)=im2frame( clip{f} );
end

figure;
movie(frames,10,5)

