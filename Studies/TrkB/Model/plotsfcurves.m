

sigma=0.5;
k=1;
n=2;

if 1
figure;
hold off
c=(0:0.01:1);
g=contrastmod( c,n, 2, sigma);
g=g/max(g);
plot(c,g,'k-');
hold on
g=contrastmod( c,n, 0, sigma);
g=g/max(g);
plot(c,g,'r-');
xlabel('contrast');
ylabel('normalized response');
bigger_linewidth(3);
smaller_font(-12);
h_l=legend('= very modulated','= unmodulated',4);
set(h_l,'FontSize',12);
end
return

sf=(0.01:0.01:0.7);
c=[0 0.25 0.5 1];
k=1;
g=contrastmod( c,n, k, sigma);
if 0
figure(1);
title('flat modulation strength')
plot(sf, g'*sfcurve(sf,0.2,0.45));
hold on
plot(sf, g'*sfcurve(sf,0.1,0.2),'--');
ylabel('normalized response');
xlabel('spatial frequency');
hold off
end

if 0
figure(2);
k=0.1;
g= (c.^n )./ (sigma^n + k^n * c.^n);
plot(sf, g'*sfcurve(sf,0.2,0.45));
hold on
plot(sf, g'*sfcurve(sf,0.1,0.2),'--');
hold off
end