function [data,t] = interval2continuous(ts,dp,tres)

%  INTERVAL2CONTINUOUS
%
%    [DATA,T] = interval2continuous(TIMESTAMPS,DATAPOINTS,TRES)
%
%  Transforms a discrete interval function to continuous time.  The function
% is expressed as a set of TIMESTAMPS and values (DATAPOINTS), where the
% function takes the value DATAPOINT(i) from TIMESTAMP(i) to TIMESTAMP(i+1).
% Thus, length(TIMESTAMPS)=length(DATAPOINT)+1.  The data are sampled
% continuously with sample difference TRES.  The data and sample times are
% returned in DATA and T, respectively.
%
% See also:  SQUARE

t = ts(1):tres:ts(end);
data = zeros(size(t));

for i=1:length(ts)-1,
	data(round((ts(i)-ts(1))/tres)+1:round((ts(i+1)-ts(1))/tres))=dp(i);
end;
