%Urethane dose



weight=(10:40);


% dose=[10*0.03 36*0.015];

dose=0.0285*weight.^0.7;

figure

plot( weight,dose,'k');
set(gca,'XTick',(10:2:40))
set(gca,'YTick',(0.12:0.02:0.4))
grid on
axis([10 40 0.12 0.4]);

xlabel('weight (g)');
ylabel('dose ip (ml)');
title('Urethane alone','fontsize',20)

smaller_font(-5);
bigger_linewidth(3);
saveas(gcf,'urethane_dose.png');
