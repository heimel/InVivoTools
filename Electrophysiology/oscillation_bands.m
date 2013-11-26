function bands = oscillation_bands
%OSCILLATION_BANDS returns structure with neural oscillation bands
%
%  BANDS = OSCILLATION_BANDS
%  
%    bands.delta = [1 4];
%    bands.theta = [4 8];
%    bands.alpha = [8 12];
%    bands.delta = [12 30];
%    bands.gamma = [30 70];
%
%    Taken from http://en.wikipedia.org/wiki/Neural_oscillation
%
% 2012, Alexander Heimel
%

bands.gamma = [30 70];
bands.beta = [12 30];
bands.alpha = [8 12];
bands.theta = [4 8];
bands.delta = [1 4];

