function t = duration(stim)
%ADVANCEDFLYOVER/DURATION
%
% 2017,  Alexander Heimel

par = getparameters(stim);
df = struct(getdisplayprefs(stim));
t = df.BGpretime + par.duration + df.BGposttime;

if t>2.8
    t = 2.8;
    warning('DURATION:HARDCODED','Stimulus duration is hardcoded to 2.8s');
    warning('off','DURATION:HARDCODED');
end