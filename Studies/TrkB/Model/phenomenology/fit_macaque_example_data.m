function fit_macaque_example_data
%FIT_MACAQUE_EXAMPLE_DATA for T1 paper
%

%From Carandini & Sengpiel 2004:
%cat: median n=1.64, median c50=32.7

n=1.64;
c50=0.327;
sigma = c50; % CHECK THIS!

sf=logspace(log10(0.1),log10(10),100);

% from Schmidt et al. 2004
% cat vep response linear on a x-log axis (y linear)
% and end at 4 cpd (below 6cpd literature value)
sf_low=0.1;
sf_high=4;
contrast_high=0.93;


n_cells=1;
cells=(2);

% Cell from Sceniak et al. 2002, Fig. 6b or 7a
% not enough info on both Sceniak cells
% the paper does strongly support our point
% high sfs show a consistent downward shift
cell=1;
animal='macaque';
titel{cell}='Cell from Sceniak et al. 2002, Fig. 6b';
fit{cell}='dog';
load('scen02_fig6b.mat')
data{cell}=scen02_fig6b;
max_rate{cell}=max([data{cell}.y{1};data{cell}.y{2}]);
contrasts{cell}=[mean([0.66 0.99]) 0.2 ];
cell_color{cell}=[0 1 0];
[m,ind_max_contrast{cell}]=max(contrasts{cell});
[m,ind_max_sf]=max(data{cell}.y{ind_max_contrast{cell}});
peakrate=[];
for i=1:length(contrasts{cell})
  peakrate(i)=data{cell}.y{i}(ind_max_sf);
end
[rm_fit{cell},b_fit{cell},n_fit{cell}]=naka_rushton(contrasts{cell},peakrate)
%b_fit{cell}=0.04; % 0.13 
%n_fit{cell}=1.2   % 5
ax{cell}=[0.1 10 -0.1 120];

h.fig=figure;
p=get(h.fig,'position');
p(3)=p(3)*1.5;
%p(4)=p(4)*1.2;
set(h.fig,'position',p);

for cell=1
switch fit{cell}
  case 'spline'
    sftuning_before_norm{cell}=spline( data{cell}.x{ind_max_contrast{cell}}(:)',...
      data{cell}.y{ind_max_contrast{cell}}(:)',sf);
  case 'dog'
    r=dog_fit(data{cell}.x{ind_max_contrast{cell}}(:)',data{cell}.y{ind_max_contrast{cell}}(:)')
    lowsfwidth{cell}=sqrt(2)*r(5)
    highsfwidth{cell}=sqrt(2)*r(3)
    lowheight{cell}= r(4)/r(2)
    shifthigh{cell}=0;
    sftuning_before_norm{cell}=sfcurve(sf,lowsfwidth{cell},highsfwidth{cell},lowheight{cell},shifthigh{cell});
    
  case 'cell3'
   sftuning_before_norm{cell}=exp(-(sf-1.1).^2/2/0.3^2).*exp(-sf/0.5);
    %    sftuning_before_norm{cell}=sf.^4.*exp(-sf.^2.5/0.4);
end

% multiple with normalization to make fitted curve unchanged after
% normalizing
sftuning_before_norm{cell}=sftuning_before_norm{cell} .* ...
 (1+max(contrasts{cell})^n.*normalization_pool(sf,sf_low,sf_high,contrast_high,sigma,n,animal) / b_fit{cell}^n_fit{cell})...


 % normalize maximum response to 1
  sftuning_before_norm{cell}=sftuning_before_norm{cell}./max(sftuning_before_norm{cell}(:));

  sftuning_before_norm{cell}=...
    repmat(sftuning_before_norm{cell},length(contrasts{cell}),1).* ...
    repmat(contrasts{cell}.^n_fit{cell}',1,length(sf));

  denominator=1+  ...
    contrasts{cell}.^n'*normalization_pool(sf,sf_low,sf_high,contrast_high,sigma,n,animal) / ...
   ( b_fit{cell}^n_fit{cell});

  sftuning{cell}=sftuning_before_norm{cell}./denominator;
  sftuning{cell}=sftuning{cell}/max(sftuning{cell}(:))*max_rate{cell};
  
   % plot cell
  subplot(1,n_cells,cell)
  hold on
  h.plot{cell}=plot(sf,sftuning{cell});
  children=h.plot{cell};
  for i=1:length(contrasts{cell})
    set(children(i),'color',(1-contrasts{cell}(i))*cell_color{cell})
  end

  % calculate and plot maxima
  [max_r,max_i]=max(sftuning{cell}');
  max_sf=sf(max_i);
  for i=1:length(contrasts{cell})
    h.plot_max{cell}(i)=plot(max_sf(i),max_r(i),'v');
    set(h.plot_max{cell}(i),'color',(1-contrasts{cell}(i))*cell_color{cell})
  end
  h.maxline{cell}=plot(max_sf,max_r,'-');
  set(h.maxline{cell},'color',(1-contrasts{cell}(2))*cell_color{cell});
  
  % plot data
  for i=1:length(contrasts{cell})
    h.plot_data{cell}(i)=plot(data{cell}.x{i},data{cell}.y{i},'o');
    set(h.plot_data{cell}(i),'color',(1-contrasts{cell}(i))*cell_color{cell})
  end
  xlabel('Spatial frequency (cpd)');
  ylabel('Response (Hz)');
  h.title{cell}=title(titel{cell},'fontsize',16);
 axis square
 h.legend{cell}=legend( [num2str(contrasts{cell}(1)*100) '%'],...
  [num2str(contrasts{cell}(2)*100) '%']);
   legend boxoff
   set(h.legend{cell},'fontsize',14);

set(gca,'Xscale','log');
axis(ax{cell});
end





% Cell from Carandini et al. 1997 fig 5
cell=2;
animal='macaque';
titel{cell}='Example Macaque V1 Neuron\newline       (Carandini et al. 1997)';
load('cara_contrast_tuning.mat')

subplot(1,2,cell);
hold on;

plot([10 10],[500 500],'o-k');
h2=plot([10 10],[500 500],'o-b');
set(h2,'color',[0.5 0.5 0.5]);
plot(cara.x{1}*100,cara.y{1},'ok');
h2=plot(cara.x{2}*100,cara.y{2},'o');
set(h2,'color',[0.5 0.5 0.5]);

[rm_cara,b_cara,n_cara]=naka_rushton(cara.x{2},cara.y{2}')

rm_cara=mean([39 24])
b_cara=mean([0.43 0.50]);
n_cara=mean([2.6 3.1]);
r14=1.25;
r11=0.75;
%r11or14=.6;
contrasts=logspace(log10(0.1),log10(1),100);


%   np=250*cara.sf.^0.6.*exp(-cara.sf.^2/0.9^2)
np=normalization_pool([1.4 1.1],sf_low,sf_high,contrast_high,sigma,n,animal) 


y_fit14=r14*rm_cara*contrasts.^n_cara./(b_cara^n_cara + np(1)/np(2)*contrasts.^n_cara);
plot(contrasts*100,y_fit14,'k-');

y_fit11=r11*rm_cara*contrasts.^n_cara./(b_cara^n_cara + np(2)/np(2)*contrasts.^n_cara);
h2=plot(contrasts*100,y_fit11,'b-');
set(h2,'color',[0.5 0.5 0.5]);

set(gca,'Xscale','log');
set(gca,'yscale','log');
h.legend{cell}=legend([num2str(cara.sf(1)) ' cpd'],...
                      [num2str(cara.sf(2)) ' cpd'],'location','NorthWest');
legend boxoff
axis([10 100 1.9 54]);
axis square
set(gca,'XTick',[10 20 40 60 100]);
set(gca,'YTick',[2 5 10 20 40]);
xlabel('Contrast (%)');
ylabel('Response (Hz)');
h.title{cell}=title(titel{cell},'fontsize',18);


bigger_linewidth(3);
smaller_font(-12);
for cell=cells
  set(h.legend{cell},'fontsize',14);

end
save_figure('fit_macaque_example_data.png',...
  fileparts(which('model_explanation_figure')),h.fig);

