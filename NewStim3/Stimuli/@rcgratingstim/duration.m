function t = duration(rcgs)

% DURATION - Duration of a 
%
%  T = DURATION(RCGS)
%
%  Returns the expected duration of the RCGRATING stimulus RCGS.
%
%  See also:  RCGRATINGSTIM, STIMULUS/DURATION

t = 0;

p = getparameters(rcgs);

do = getdisplayorder(rcgs);

t = duration(rcgs.stimulus) + (p.dur*length(do))+p.reps*(p.pausebetweenreps - p.dur);

