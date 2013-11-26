function [vals,mousedb,testdb]=make_histogram(groups,measure,varargin)
%MAKE_HISTOGRAM deprecated function
%
% 2007, Alexander Heimel
%
%

disp('MAKE_HISTOGRAM: DEPRECATED. WILL BE REMOVED IN FUTURE');

% possible varargins with default values
pos_args={...
  'test','ttest2',...
  'eyes','contra',...
  'verbose',1,...
  'grouplabels',groups,...
  'histbin_centers',[],...
  'xlab','',...
  'prefax',[],...
  'color',[],...
  'measurelabels','',...
  'style','histogram',...
  'reliable',1,... % 1 to only use reliable records, 0 to use all
  'celltype','su',...     % one of 'all','mu','su'
  'save_option',1 };

assign(pos_args{:});

%parse varargins
nvarargin=length(varargin);
if nvarargin>0
  if rem(nvarargin,2)==1
    warning('odd number of varguments');
    return
  end
  for i=1:2:nvarargin
    found_arg=0;
    for j=1:2:length(pos_args)
      if strcmp(varargin{i},pos_args{j})==1
        found_arg=1;
        assign(pos_args{j}, varargin{i+1});
      end
    end
    if ~found_arg
      warning(['could not parse argument ' varargin{i}]); 
      return
    end
  end
end

% center grouplabels for use in captions
grouplabels=strjust(char(grouplabels),'center');

if strcmp(style,'cumulative')==1
  histbin_centers=1000;
end

if reliable==1
  reliable_filter=', reliable!0';
else
  reliable_filter='';
end

testdb=load_testdb(expdatabases('ec'));
mousedb=load_mousedb;

% get data
vals={};
for s=1:length(groups)
  vals{s}=[];
  ind_mice=find_record(mousedb,groups{s});
  for i=ind_mice
    mouse=mousedb(i).mouse;
    ind=find_record(testdb,['mouse=' mouse reliable_filter]);
    if isempty(ind)
      continue
    end
    val=[];
    for r=ind
      record=testdb(r);
      value=get_measure_from_record(record,measure,celltype);
      if isempty(value)
        value=nan;
      end
      testdb(r).(measure)=value;
      val=[val value ];
    end
    vals{s}=[vals{s} val];
    if mousedb(i).typing_lsl>0 & mousedb(i).typing_cre>0
      tlt=1;
    else
      tlt=0;
    end
    mousedb(i).(measure)=nanmean(val);
    age=mouse_age(mousedb(i).mouse,record.date);
    disp([' mouse ' mouse ' (P' num2str(age) ') is ' num2str(tlt) ' transgenic and has ' num2str(length(val)) ...
      ' units, ' measure ' mean:' num2str(mousedb(i).(measure),3)]);
  end
end


%remove nans
for s=1:length(vals)
  vals{s}=vals{s}(~isnan(vals{s}));
end


n_hist={};
if length(histbin_centers)==1 % only number specified
  [n,histbin_centers]=hist( [vals{:}],histbin_centers);
end
if isempty(histbin_centers)
  [n,histbin_centers]=hist( [vals{:}]);
end

for s=1:length(groups)
  n_hist{s}=hist(vals{s},histbin_centers);
  f_hist{s}=n_hist{s}/length(vals{s}); % compute fraction
end

figure;
hold on

switch style
  case 'histogram'
    bar(histbin_centers,[f_hist{1}',f_hist{2}'],2);
  case 'cumulative'
    plot(histbin_centers,cumsum(f_hist{1}),'b');
    plot(histbin_centers,cumsum(f_hist{2}),'r');
end


if strcmp(style,'cumulative') 
  ax=axis;
  ax([3 4])=[0 1]; 
  axis(ax);
end

if ~isempty(prefax)
  ax=axis;
  if length(prefax)==2
    ax([1 2])=[-2 22];
  else
    ax=prefax;
  end
  axis(ax);
end

legend(grouplabels,'Location','Best');
legend(gca,'boxoff');

box off;
ylabel('Fraction')
xlabel(xlab);

% compute means
for s=1:length(groups)
  disp(['Mean ' grouplabels(s,:) ' : ' num2str(nanmean(vals{s}),2) ]);
end

% compute significances
for s=1:length(groups)
  for t=s+1:length(groups)
    valss=vals{s}; valss(isnan(valss))=[];
    valst=vals{t}; valst(isnan(valst))=[];
    
    switch test
      case {'ttest2','ttest'}
        [h,p]=ttest2(valss,valst);
      case {'kruskal-wallis','kruskal_wallis'}   
        p=kruskal_wallis_test(valss,valst);
    end
    disp([grouplabels(s,:) ' and ' grouplabels(t,:) ' : ' test ' significance: p = ' num2str(p,2)]);

    x1=median(valss);
    ax=axis;
    plot_significance(valss,x1,valst,x1,ax(3)+0.9*(ax(4)-ax(3)),0,0,test);
  end
end

bigger_linewidth(3);
smaller_font(-10);
if save_option
  l=grouplabels';
  filename=['hist_' l(:)' '_' measure '_' celltype ];
  save_figure(filename);
end

% plot means and sems

graph({valss,valst},[1 2],'style','bar','xlab',xlab,'ylab',measurelabels,...
  'xticklabels',grouplabels,'color',color,'errorbars',  'sem','test',test,'showpoints',0);
 
if save_option
  l=grouplabels';
  filename=['mean_' l(:)' '_' measure '_' celltype ];
  save_figure(filename);
end

