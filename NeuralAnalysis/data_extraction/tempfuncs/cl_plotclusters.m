function cl_plotclusters(fea,holdon,plotstr,ms)
 % ms = marker size

subplot(3,3,1);
if holdon, hold on; end;
plot(fea(:,1),fea(:,2),plotstr,'MarkerSize',ms);
title('1-2');

subplot(3,3,4);
if holdon, hold on; end;
plot(fea(:,1),fea(:,3),plotstr,'MarkerSize',ms);
title('1-3');

subplot(3,3,5);
if holdon, hold on; end;
plot(fea(:,2),fea(:,3),plotstr,'MarkerSize',ms);
title('2-3');

subplot(3,3,7);
if holdon, hold on; end;
plot(fea(:,1),fea(:,4),plotstr,'MarkerSize',ms);
title('1-4');

subplot(3,3,8);
if holdon, hold on; end;
plot(fea(:,2),fea(:,4),plotstr,'MarkerSize',ms);
title('2-4');

subplot(3,3,9);
if holdon, hold on; end;
plot(fea(:,3),fea(:,4),plotstr,'MarkerSize',ms);
title('3-4');
