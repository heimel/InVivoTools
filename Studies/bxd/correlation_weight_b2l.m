if ~exist('weight')
  make_bxdweights
end
if ~exist('b2l')
  make_bxdbregma2lambda
end

ind=find(weight>14 & weight<25);

[r,n,p]=nancorrcoef(weight(ind),b2l(ind))

disp(['Correlation between weights and bregma2lambda: ' num2str(r) ]);
disp(['Significance of correlation: p=' num2str(p) ]);

figure;
h=plot(weight,b2l,'ok');
hold on

ind=find(~isnan(b2l) & ~isnan(weight));
b2l=b2l(ind);
weight=weight(ind);
x=weight-mean(weight);
y=b2l-mean(b2l);
a=(y*x')/(x*x');
b=mean(b2l)-a*mean(weight);

x=[10 30];
y=a*x+b;
plot(x,y,':k');

xlabel('Weight (g)');
ylabel('Distance of Lambda to Bregma (mm)');
smaller_font(-10);
bigger_linewidth(3);
save_figure('correlation_weight_b2l_bxd');

