function [totalr,sf]=sf_groupresponse(highsf)

if nargin<1
  highsf=0.4;
end
midsf=highsf/2;

sf=(0:0.01:2*highsf);

n=30;

highsf=midsf+(highsf-midsf)*rand(n,1);
lowsf=midsf*rand(n,1);
highpass=rand(n,1);

for i=1:30
  [r(i,:),sf]=sf_response(highsf(i),lowsf(i),highpass(i));
  
end
totalr=sum(r,1);
totalr=totalr/max(totalr);

if 0
  figure;
  hold on;
  plot(sf,r,'k');
  plot(sf,totalr,'r');
end


