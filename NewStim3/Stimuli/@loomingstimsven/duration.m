function t = duration(stim)
%LOOMINSTIMSVEN/DURATION
%
% 2015, Simon Lansbergen & Alexander Heimel

par = getparameters(stim);
df = struct(getdisplayprefs(stim));
t = df.BGpretime + (par.expansiontime + par.statictime)*par.n_repetitions + df.BGposttime;

