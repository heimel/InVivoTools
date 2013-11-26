close all

% the model has a singularity at sf_crit=sf_low - sigma^n/contrast_high*(sf_high-sf_low)
% the reason for this is that shifting the contrast tuning curve can not arbitrarely 
% increase the responses, because it is a saturating function
% this means that below sf_crit the responses can no longer increase


sf=logspace(log10(0.1),log10(0.7),100);
contrasts=[ 0.5  1];
sf_low=0.1;
sf_high=0.5;
sigma=0.26;
n=2.8;
contrast_high=0.9;

sf_ticks=[0.1 0.3 0.5];
r_ticks=[0 1];

%%
h=figure;
p=get(h,'position');
p(3)=p(3)*2.6;
p(4)=p(4)*1.2;
set(h,'position',p);
n_cols=4;

cell=1;
titel{cell}='Low SF cell';
cell_color{cell}=[0 1 0];
lowsfwidth{cell}=0.01;
highsfwidth{cell}=0.25;
lowheight{cell}=0.95;
%sftuning_before_norm{cell}=sfcurve(sf,lowsfwidth{cell},highsfwidth{cell},lowheight{cell});

sftuning_before_norm{cell}=max(0,(sf_high-sf))/(sf_high-sf_low).*...
   normalization_pool(sf,sf_low,sf_high,contrast_high,sigma,n) / sigma^n;
        

sftuning_before_norm{cell}=sftuning_before_norm{cell}./max(sftuning_before_norm{cell}(:));

sftuning_before_norm{cell}=...
  repmat(sftuning_before_norm{cell},length(contrasts),1).* ...
  repmat(contrasts.^n',1,length(sf));
  
  
cell=2;
titel{cell}='High SF cell';
cell_color{cell}=[1 0 0];
lowsfwidth{cell}=0.3;
highsfwidth{cell}=0.3;
lowheight{cell}=0.9;
sftuning_before_norm{cell}=sfcurve(sf,lowsfwidth{cell},highsfwidth{cell},lowheight{cell});
sftuning_before_norm{cell}=sftuning_before_norm{cell}./max(sftuning_before_norm{cell}(:));
sftuning_before_norm{cell}=...
  repmat(sftuning_before_norm{cell},length(contrasts),1).* ...
  repmat(contrasts.^n',1,length(sf));

for cell=[1 2]
%   h1.fig{cell}=subplot(2,5,(cell-1)*5+1);
   h1.fig{cell}=subplot(2,n_cols,(cell-1)*n_cols+1);
   hold on
   h1.plot{cell}=plot(sf,sftuning_before_norm{cell});
  children=h1.plot{cell};
  for i=1:length(contrasts)
    set(children(i),'color',(1.5-contrasts(i))*cell_color{cell})
  end
   set(gca,'XScale','linear');
   set(gca,'XTick',sf_ticks)
   set(gca,'YTick',r_ticks)
   axis([0.05 0.6 0 1.2]);
   h1.title{cell}=title(titel{cell},'fontsize',16);
   set(h1.title{cell},'verticalalignment','top');
   axis square
   h1.legend{cell}=legend('50%','100%');
   legend boxoff
end

xlabel('Spatial frequency    ');
ylabel('                                   Unnormalized response, A_i');



%%
%h2.fig=subplot(4,5,[8 13]);
h2.fig=subplot(4,n_cols,[2+n_cols 2+2*n_cols]);
hold on


denominator=1+  ...
   contrasts.^n'*normalization_pool(sf,sf_low,sf_high,contrast_high,sigma,n) / sigma^n;
        
h2.plot=plot(sf,denominator,'k');
axis([0.05 0.6 0.5 60]);
set(gca,'XScale','linear');
set(gca,'YScale','log');
set(gca,'XTick',sf_ticks)
set(gca,'YTick',[1  4  16 ]);
xlabel('Spatial frequency');
h2.ylabel=ylabel('Normalization factor, N');
set(h2.ylabel,'verticalalignment','middle');

axis square

  children=h2.plot;
  for i=1:length(contrasts)
    set(children(i),'color',(1-contrasts(i))*[0.9 0.9 0.9])
  end
   h2.legend=legend('50%','100%');
   legend boxoff


%%  normalized firing rate examples


for cell=[1 2]
   h3.fig{cell}=subplot(2,n_cols,3+(cell-1)*n_cols);
   hold on
   sftuning{cell}=sftuning_before_norm{cell}./denominator;
   sftuning{cell}=sftuning{cell}/max(sftuning{cell}(:));
   h3.plot{cell}=plot(sf,sftuning{cell});
   children=h3.plot{cell};
  for i=1:length(contrasts)
    set(children(i),'color',(1.5-contrasts(i))*cell_color{cell})
  end
   axis([0.05 0.6 0 1.2]);
   set(gca,'XScale','linear');
   set(gca,'XTick',sf_ticks)
   set(gca,'YTick',r_ticks)
   h3.title{cell}=title(titel{cell},'fontsize',16);
   set(h3.title{cell},'verticalalignment','top');
   axis square
   h3.legend{cell}=legend('50%','100%');
   legend boxoff
end


xlabel('Spatial frequency    ');
ylabel('                                Firing rate, R_i');
   
   
   

%%  population response
[hc,lc,sf]=heeger_modelfit([2.7849 1.0305],0.5/0.9);
h4.fig=subplot(4,n_cols,[4+n_cols 4+2*n_cols]);
hold on
h4.plot{1}=plot(sf,lc);
h4.plot{2}=plot(sf,hc);
   axis([0.05 0.6 0 1.2]);
   set(gca,'XScale','linear');
   set(gca,'XTick',sf_ticks)
   set(gca,'YTick',r_ticks)
   ylabel('Population response, P')
   xlabel('Spatial frequency');
   axis square
   h4.legend=legend('50%','100%');
   legend boxoff
  for i=1:2
    set(h4.plot{i},'color',(1-contrasts(i))*[0.9 0.9 0.9])
  end

%%

bigger_linewidth(3);
smaller_font(-12);
   set(h1.legend{1},'fontsize',14);
   set(h1.legend{2},'fontsize',14);
   set(h2.legend,'fontsize',14);
   set(h3.legend{1},'fontsize',14);
   set(h3.legend{2},'fontsize',14);
   set(h4.legend,'fontsize',14);
   p1=get(h1.legend{2},'position');
   p=get(h3.legend{2},'position');
   p(1)=p(1)+0.020;
   p(2)=p(2)+0.025;
   set(h3.legend{2},'position',p);
   

save_figure('model_explanation_figure.png',fileparts(which('model_explanation_figure')),h);

disp('Do not forget to make white transparant before adding to the figure!!');



