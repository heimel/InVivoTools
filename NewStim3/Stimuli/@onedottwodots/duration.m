function t = duration(stim)
%ADVANCEDFLYOVER/DURATION
%
% 2017,  Alexander Heimel

par = getparameters(stim);
df = struct(getdisplayprefs(stim));
t = df.BGpretime + par.duration + df.BGposttime;

