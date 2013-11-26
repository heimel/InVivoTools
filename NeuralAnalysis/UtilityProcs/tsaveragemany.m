function [avg,v,tnew]=tsaveragemany(t,f,ts,start,stop)

%  TSAVERAGE - average around a list of time stamps
%
%     [AVG,SD,TNEW]=TSAVERAGE({T},{F},{TS},START,STOP)
%
%  Averages a list of functions with values F{1}, F{2}, ... at sample times T{1},
%  T{2}... triggered on the time stamps listed in TS{1},TS{2}, ... in a window
%  from START to STOP (use less than zero to specify before trigger).  AVG is
%  the average value, SD is the standard deviation, and TNEW is a set of time
%  points around each trigger.
%
%  See also:  MEAN, VAR


T = [];
for i=1:length(t),
  if min(ts{i})<min(t{i})|max(ts{i})>max(t{i}), error('timestamps are out of range of t.'); end;
  if length(f{i})<2, error('F must be longer than 2 points.'); end;
  if size(ts{i},1)>size(ts{i},2), ts{i} = ts{i}'; end;
  t0 = t{i}(1); samp_dt = t{i}(2)-t{i}(1);
  samptimes = round((ts{i}-t0)/samp_dt)+1;
  sb=round(start/samp_dt);se=round(stop/samp_dt);
  samptimes=samptimes(find((samptimes-sb)>0&(samptimes+sb)<length(f{i})));
  %size(repmat(sb:se,length(samptimes),1)),size(repmat(samptimes,se-sb+1,1)'),
  T=cat(1,T,f{i}(repmat(sb:se,length(samptimes),1)+repmat(samptimes,se-sb+1,1)'));
end;

avg = mean(T); v = std(T); tnew = samp_dt * (sb:se);

