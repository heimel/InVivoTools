function fit_reviewers_cat_example_data
%FIT_CAT_EXAMPLE_DATA for T1 paper
%

%From Carandini & Sengpiel 2004:
%cat: median n=1.64, median c50=32.7

%close all

n=1.64;
c50=0.327;
sigma = c50; % CHECK THIS!

sf=logspace(log10(0.1),log10(2),100);

% from Schmidt et al. 2004
% cat vep response linear on a x-log axis (y linear)
% and end at 4 cpd (below 6cpd literature value)
sf_low=nan;
sf_high=nan;
contrast_high=0.93;


n_cells=1;
cells=[1];%(1:n_cells);


%% Simple cell Skottun et al. 1987
cell=1;
animal='cat';
fit{cell}='dog';
titel{cell}='Simple cell (Skottun et al. 1987)';
load('skot_fig3_1.mat')
data{cell}=skot_fig3_1;
max_rate{cell}=max([data{cell}.y{1};data{cell}.y{2};data{cell}.y{3}]);
contrasts{cell}=[0.8 0.2 0.05];
[m,ind_max_contrast{cell}]=max(contrasts{cell});
[m,ind_max_sf]=max(data{cell}.y{ind_max_contrast{cell}});
peakrate=[];
for i=1:length(contrasts{cell})
  peakrate(i)=data{cell}.y{i}(ind_max_sf);
end
[rm_fit{cell},b_fit{cell},n_fit{cell}]=naka_rushton(contrasts{cell},peakrate)
rm_fit{cell}=55;% 57
b_fit{cell}=0.20  %0.26
n_fit{cell}=1.4
cell_color{cell}=[0 1 0];
ax{cell}=[0 1.5 0 50];

%% Low SF cell Skottun et al. 1986
cell=2;
animal='cat';
fit{cell}='dog';
titel{cell}=' Intermediate SF neuron\newline     (Skottun et al. 1986)';
load('skot86_fig1b.mat')
data{cell}=skot86_fig1b;
max_rate{cell}=max([data{cell}.y{1};data{cell}.y{2};data{cell}.y{3}]);
contrasts{cell}=[0.5 0.16 0.03];
[m,ind_max_contrast{cell}]=max(contrasts{cell});
[m,ind_max_sf]=max(data{cell}.y{ind_max_contrast{cell}});
peakrate=[];
for i=1:length(contrasts{cell})
  peakrate(i)=data{cell}.y{i}(ind_max_sf);
end
[rm_fit{cell},b_fit{cell},n_fit{cell}]=naka_rushton(contrasts{cell},peakrate)
b_fit{cell}=0.06%0.07
n_fit{cell}=1.7  %1.8
cell_color{cell}=[0 1 0];
ax{cell}=[0 1.5 0 60];


%% High SF cell Skottun et al. 1986
cell=3;
animal='cat';
fit{cell}='cell3';%'spline';
titel{cell}='     High SF neuron\newline (Skottun et al. 1986)';
load('skot86_fig1c.mat')
data{cell}=skot86_fig1c;
data{cell}.x

data{cell}.x

max_rate{cell}=max([data{cell}.y{1};data{cell}.y{2};data{cell}.y{3}]);
contrasts{cell}=[0.8 0.2 0.08];
[m,ind_max_contrast{cell}]=max(contrasts{cell});
[m,ind_max_sf]=max(data{cell}.y{ind_max_contrast{cell}});
peakrate=[];
for i=1:length(contrasts{cell})
  peakrate(i)=data{cell}.y{i}(ind_max_sf);
end
[rm_fit{cell},b_fit{cell},n_fit{cell}]=naka_rushton(contrasts{cell},peakrate)
rm_fit{cell}=39;% 39
b_fit{cell}=0.1%0.22  %0.22
n_fit{cell}=1.8  %1.8
cell_color{cell}=[0 1 0];
ax{cell}=[0 1.5 -5 50];

%%%%%%


h.fig=figure;
p=get(h.fig,'position');
p(3)=p(3)*2;
%p(4)=p(4)*1.2;
set(h.fig,'position',p);



for cell=cells
%  sftuning_before_norm{cell}=sfcurve(sf,lowsfwidth{cell},highsfwidth{cell},lowheight{cell},shifthigh{cell})...
%    .*(1+max(contrasts{cell})^n.*normalization_pool(sf,sf_low,sf_high,contrast_high,sigma,n,animal) / b_fit{cell}^n_fit{cell});

% fit tuning curve of highest contrast
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

  

  %sftuning_before_norm{cell}=max(0,(sf_high-sf))/(sf_high-sf_low).*...

  % normalize maximum response to 1
  sftuning_before_norm{cell}=sftuning_before_norm{cell}./max(sftuning_before_norm{cell}(:));

  sftuning_before_norm{cell}=...
    repmat(sftuning_before_norm{cell},length(contrasts{cell}),1).* ...
    repmat(contrasts{cell}.^n_fit{cell}',1,length(sf));

  denominator=1+  ...
    contrasts{cell}.^n'*normalization_pool(sf,sf_low,sf_high,contrast_high,sigma,n,animal) / ...
    b_fit{cell}^n_fit{cell};

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
  h.title{cell}=title(titel{cell},'fontsize',18);
  axis(ax{cell});
  axis square
  h.legend{cell}=legend( [num2str(contrasts{cell}(1)*100) '%'],...
  [num2str(contrasts{cell}(2)*100) '%'],...
  [num2str(contrasts{cell}(3)*100) '%']);
  legend boxoff
  set(h.legend{cell},'fontsize',14);

end

bigger_linewidth(3);
smaller_font(-12);
for cell=cells
  set(h.legend{cell},'fontsize',14);
end
%set(h.legend{3},'Location','NorthWest');
save_figure('fit_skottun87_example_data.png',fileparts(which('model_explanation_figure')),h.fig);

