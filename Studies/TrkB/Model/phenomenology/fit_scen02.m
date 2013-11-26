%From Sceniak et al. 2002
%
%
close all
h.fig = figure;
hold on

load('scen02_fig3b.mat','-mat');

lc_sf=scen02_fig3b.x;
hc_sf=scen02_fig3b.y;
%hc_sf=hc_sf+0.1;
ind=find(hc_sf>1);
lc_sf=lc_sf(ind);
hc_sf=hc_sf(ind);

%plot(lc_sf,hc_sf,'o');

x=hc_sf;
y=(lc_sf-hc_sf)./hc_sf;
y=(lc_sf-hc_sf);


[yn,xn,yerr] = slidingwindowfunc(x,y, 0, 0.05, 8, 2,'median',0)
hp=plot(xn,yn,'r');
set(hp,'color',[0.5 0.5 0.5]);

plot([0 10],[0 0],'-k');
plot(x,y,'ok');

%[b,bint]=regress(hc_sf,(lc_sf_hc_sf)./hc_sf)
%sf=linspace(0,6,100);
%y=sf*b;
%plot(sf,y)

axis([1 7 -3 2]);
xlabel('Preferred SF at high contrast (cpd)');
ylabel('Shift in preferred SF (cpd)');
title('       Macaque V1\newline (Sceniak et al. 2002)','fontsize',18);
axis square


bigger_linewidth(3);
smaller_font(-12);
%  set(h.legend{cell},'fontsize',14);
%set(h.legend{3},'Location','NorthWest');
save_figure('fit_scen02.png',fileparts(which('model_explanation_figure')),h.fig);





