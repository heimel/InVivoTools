stimtimes=[0:100:1000];


% make spike train

t=0:0.001:10-0.001;

stimes_1 = []; stimes_2=[];
for i=0:10,
st1= 50*0.001>rand(length(t),1);
st2= 10*0.001>rand(length(t),1); st2(find(st1)+2)=1;
sum(st1),sum(st2),
stimes1=t(find(st1));
stimes2=t(find(st2));
	stimes_1 = cat(2,stimes_1,stimes1+(i)*100);
	stimes_2 = cat(2,stimes_2,stimes2+(i)*100);
end;

TT=-0.100:0.001:0.100;
[xcorrv,xcovar,xstddev,expect]=spikecrosscorrelationtest(stimes_1,stimes_2,...
TT,-Inf,Inf,stimtimes,-(0.001e-3)/2,1+(0.001e-3)/2);

figure(10);
clf;
subplot(3,1,1);
bar(TT,xcovar); hold on;
plot(TT,2*abs(xstddev),'b');
plot(TT,-2*abs(xstddev),'b');
subplot(3,1,2);
bar(TT,xcorrv);
subplot(3,1,3);
bar(TT,expect);
