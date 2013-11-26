% From Mallik et al. 2008

load('mall_sf_tuning.mat');

h.fig=figure;
hold on

plot(5,5,'-ok');
plot(5,5,'-ob');

cats=4;
x=mall{1}.x;
y=mall{1}.y;
for cat=2:cats
 x=x+mall{cat}.x;
 y=y+mall{cat}.y;
end
x=x/cats;
y=y/cats;
y=y/max(y);
plot(x,y,'ok');



sf=logspace(log10(0.1),log10(2),100);

% best fit
    p=sf.^1.1.*exp(-sf.^2/0.65^2);
    p=p/max(p); % normalize
%    p=p*0.9;
plot(sf,p,'k');

if 0
% from Heywood, Petry, Casagrande, 1983
    p=250*sf.^0.6.*exp(-sf.^2/0.9^2);
    p=p/max(p); % normalize
plot(sf,p);
    end


set(gca,'Xscale','log');
axis([0.1 3 0 1.3])
set(gca,'XTick',[0.1 0.2 0.5 1 2 ]);
xlabel('Spatial frequency (cpd)');
ylabel('Norm. intrinsic signal response');
%h.legend=legend('Response (Mallik)','Sensitivity);
legend boxoff
title('Cat Area 17 (Mallik et al. 2008)','fontsize',18);

bigger_linewidth(3);
smaller_font(-12);
%set(h.legend,'fontsize',14);

save_figure('fit_Mallik_et_al_2008.png',fileparts(which('model_explanation_figure')),h.fig);

