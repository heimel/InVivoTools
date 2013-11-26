function [avg,v,tnew]=tsaverage(t,f,ts,start,stop)

%  TSAVERAGE - average around a list of time stamps
%
%     [AVG,SD,TNEW]=TSAVERAGE(T,F,TS,START,STOP)
%
%  Averages a function with values F at sample times T triggered on the time
%  stamps listed in TS in a window from START to STOP (use less than zero to
%  specify before trigger).  AVG is the average value, SD is the standard
%  deviation, and TNEW is a set of time points around each trigger.
%
%  See also:  MEAN, VAR

if min(ts)<min(t)|max(ts)>max(t), error('timestamps are out of range of t.'); end;
if length(f)<2, error('F must be longer than 2 points.'); end;
if size(ts,1)>size(ts,2), ts = ts'; end;
t0 = t(1); samp_dt = t(2)-t(1), sb=round(start/samp_dt),se=round(stop/samp_dt),
samptimes = round((ts-t0)/samp_dt)+1,
samptimes=samptimes(find((samptimes-sb)>0&(samptimes+sb)<length(f)));
length(samptimes),
size(repmat(sb:se,length(samptimes),1)),size(repmat(samptimes,se-sb+1,1)'),
T=f(repmat(sb:se,length(samptimes),1)+repmat(samptimes,se-sb+1,1)');
avg = mean(T); v = std(T); tnew = samp_dt * (sb:se);

