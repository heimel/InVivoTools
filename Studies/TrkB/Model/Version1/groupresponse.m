

sf=(0:0.01:0.08);

n=30;

highsf=0.1+0.5*rand(n,1);
lowsf=0.1*rand(n,1);
highpass=rand(n,1);

for i=1:10
  [r(i,:),sf]=sf_response(highsf(i),lowsf(i),highpass(i));
  
end
totalr=sum(r,1);
totalr=totalr/max(totalr);

figure;
hold on;
plot(sf,r,'k');
plot(sf,totalr,'r');


