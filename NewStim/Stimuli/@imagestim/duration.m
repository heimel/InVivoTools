function T = duration(S)

% DURATION- duration of imagestim
%
% T = DURATION(IMAGESTIM)
%
% returns the duration of the image stimulus
% in seconds

T = S.ISparams.duration+duration(S.stimulus)