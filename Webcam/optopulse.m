function optopulse( duration)
%OPTOPULSE wrapper around calling optopulse.c
%   should become mex file
%   
%   2018, Alexander Heimel
%

if nargin<1 || isempty(duration)
  system('~/Software/InVivoTools/Webcam/optopulse',false,'async');
else
  system(['~/Software/InVivoTools/Webcam/optopulse ' num2str(duration)],false,'async');
end


