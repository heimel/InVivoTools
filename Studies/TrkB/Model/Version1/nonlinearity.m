x=(0:0.01:5);

figure;
hold on
plot(x, x.^1,'k');
plot(x, x.^1.5,'b');
plot(x, x.^2,'r');
axis([0 0.5 0 0.5^1]);