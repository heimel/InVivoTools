% From Victor et al.,  1994
% VICTOR, KEITH PURPURA, EPHRAIM KATZ, AND BUQING MAO
% data from <5d deg of fovea
%

load('vict_sf_tuning.mat');

h.fig=figure;
hold on

plot(5,5,'-ok');

layers=2;
x=vict.x{1};
y=vict.y{1};
for layer=2:layers
 x=x+vict.x{layer};
 y=y+vict.y{layer};
end
x=x/layers;
y=y/layers;
y=y/max(y);
plot(x,y,'ok');



sf=logspace(log10(0.1),log10(10),100);

% best fit
    p=sf.^0.05.*exp(-sf.^2/10^2);
    p=p/max(p); % normalize

%    p=mean(y)*ones(size(sf));
%    p=p*0.9;
plot(sf,p,'k');

    


set(gca,'Xscale','log');
axis([0.1 10 0 1.3])
set(gca,'XTick',[0.1 0.2 0.5 1 2 5 10]);
%set(gca,'XTickLabel',['0.1';'0.5';' 1 ';' 5 ';' 10']);
xlabel('Spatial frequency (cpd)');
ylabel('Normalized LFP response');
legend boxoff
title('Macaque V1 (Victor et al. 1994)','fontsize',18);


bigger_linewidth(3);
smaller_font(-12);

save_figure('fit_Victor_et_al_1994.png',fileparts(which('model_explanation_figure')),h.fig);

