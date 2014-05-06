function pvals=significant_pixels_avg_stddev(avg,stddev,n)
%SIGNIFICANT_PIXELS_AVG_STDDEV calcutes significant pixels using one-way
%  ANOVA
%
% 2006, Alexander Heimel

if nargin<3
  n=30;
end

logmsg('Calculating significant pixels, using stdev');
n_groups = size(avg,2);
n_x = size(avg,1);
pvals=nan*zeros(n_x,1);
for x=1:n_x
  data=zeros(n,n_groups);
  for g=1:n_groups
    data(:,g)=normrnd(avg(x,g),stddev(x,g),n,1);
  end
  pvals(x)=anova1(data,[],'off');
end

logmsg([num2str(sum(pvals<0.05)/length(pvals)*100) ' % of pixels significant at p<0.05 level']);
logmsg([num2str(sum(pvals<0.01)/length(pvals)*100) ' % of pixels significant at p<0.01 level']);
logmsg([num2str(sum(pvals<0.001)/length(pvals)*100) ' % of pixels significant at p<0.001 level']);
