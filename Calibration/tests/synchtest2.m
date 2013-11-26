direct='/home/data/2002-04-29/t00081/';

%mult = 1/0.9999971246;
mult = 1/1.00000;
if 1,
   s = loadStructArray([direct 'acqParams_out']);
   eval(['load ' direct 'stims']);
   cd(direct)
  if 1,
    g2=[loadIgor('r001_tung');loadIgor('r002_tung');loadIgor('r003_tung');...
	loadIgor('r004_tung');loadIgor('r005_tung');];
  end;
   cd /home/vanhoosr/nelson/tests
   t0=1;
   t1=20;
   dt = 3.180762746900000e-05;%  - 0.000875e-5; %- 0.00127e-5;
 %3/14/2001 - 0.00127e-5; check again
 %3/15/2001 - 0.0005538e-5;
  t=0:dt:t1;
end;

dps=struct(getdisplayprefs(get(saveScript,1)));
%fps=1/8.508099024108009e+01;
fps = 1/StimWindowRefresh;

%sh=mean(diff(MTI2{1}.frameTimes))-fps;
%fps = fps+sh;

fr=t0:fps:t1;

frs = round(fr/dt)+1;
mfr = (MTI2{1}.frameTimes-start)*mult;
mfr = mfr(find(mfr<t1));
mfrs= round(mfr/dt)+1;

%length(frs),
%subplot(2,1,1);
%n = zeros(length(frs),1501);
%for i=1:length(frs), n(i,1:1501)=g2(frs(i)-500:frs(i)+1000)'; end;
%plot((0:dt:1500*dt),n(1:1:length(frs),:)');

subplot(2,1,2);
length(mfrs),
n2 = zeros(length(mfrs),1001);
for i=1:length(mfrs), n2(i,1:1001)=g2(mfrs(i)-000:mfrs(i)+1000)'; end;
%plot((0:dt:1000*dt),n2(1:length(mfrs),:)');
plot((0:dt:1000*dt),n2(1:1:length(mfrs),:)');
