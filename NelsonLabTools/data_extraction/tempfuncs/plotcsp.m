function plotcsp(csp)

L = size(csp,1)/4;
inds = 0:L:size(csp,1);
hold off
plot(csp(inds(1)+1:inds(2),1),'color',[0 0       1]);
hold on
plot(csp(inds(2)+1:inds(3),1),'color',[0 0.5     0]);
plot(csp(inds(3)+1:inds(4),1),'color',[1 0       0]);
plot(csp(inds(4)+1:inds(5),1),'color',[0 0.75 0.75]);
