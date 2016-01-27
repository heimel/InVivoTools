function t = duration(stim)
%OPTOSTIM/DURATION
%
% 2016, Alexander Heimel
%

par = getparameters(stim);
df = struct(getdisplayprefs(stim));
t = df.BGpretime + par.duration + df.BGposttime;
