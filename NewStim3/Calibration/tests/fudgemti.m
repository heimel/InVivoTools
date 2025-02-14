

str = ['/home/vanhoosr/data/2002-09-10/t00010/stims.mat'];

g2 = load(str,'-mat');

disp(['Doing t00011 .']);

fudgefactor = 1.05;

for i=1:length(g2.MTI2)
  g2.MTI2{i}.startStopTimes=...
       g2.start+(g2.MTI2{i}.startStopTimes-g2.start)*fudgefactor;
  g2.MTI2{i}.frameTimes=g2.start+(g2.MTI2{i}.frameTimes-g2.start)*fudgefactor;
end

MTI2 = g2.MTI2;
start = g2.start;
saveScript = g2.saveScript;
StimWindowRefresh = g2.StimWindowRefresh;

save(str,'MTI2','start','saveScript','StimWindowRefresh','-v7');
