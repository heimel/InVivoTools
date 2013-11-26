function analyze_bxd_data( crit )
%ANALYZE_BXD_DATA
%
%  2007, Alexander Heimel
%

cd(bxddatadir);
disp('Make sure to first run all_bxd_data');

n_shuffles=1000;
min_n=0; % minimal number of data points to report strain mean
global min_p
min_p=0.01

if nargin<1
  
  crit=4;
end

switch crit
  case 1
    extra_conditions='weight_outlier=0';
    critlabel='clean';
  case 2,
    extra_conditions='birthdate<2006-02-21';
    critlabel='with_mums';
  case 0,
    extra_conditions=''; % all
    critlabel='all';
  case 3,
    extra_conditions='weight_outlier=0';
    critlabel='scrambled';
    disp('not implemented. do sort of values with excel');
  case 4,
   extra_conditions='weight_outlier=0';
    critlabel='finished';
    min_n=3
  case 5,
    extra_conditions='weight_outlier=0';
    disp('removing BXD-02');
    critlabel='nobxd2';
    min_n=4
end

disp(['CRITLABEL = ' critlabel ]);

strains=neurobsik_strains;
n_strains=length(neurobsik_strains);

if crit==5
  strains{6}='BXD-XX'; % to remove BXD-02 animals
end

bxddb=[];

% load database with data
load('all_bxd_data.mat');

for i=1:length(bxddb)
  if isempty(bxddb(i).weight)
    bxddb(i).weight=nan;
  end
end


% assign strain numbers for faster finding
% strain numbers correspond with NEUROBSIK_STRAINS function
for i=1:length(bxddb)
  switch bxddb(i).strain(1)
    case 'C'
      if strcmp(bxddb(i).strain(1:3),'C57')
        bxddb(i).strain_nr=3;
      end
    case 'D'
      if strcmp(bxddb(i).strain(1:6),'DBA/2J')
        bxddb(i).strain_nr=4;
      end
    case 'B'
      if strcmp(bxddb(i).strain(1:3),'BXD')
        bxddb(i).strain_nr=eval(bxddb(i).strain(5:6))+4;
        while strcmp(bxddb(i).strain,strains{bxddb(i).strain_nr})==0 && ...
            bxddb(i).strain_nr>4
          bxddb(i).strain_nr=bxddb(i).strain_nr-1;
        end
        if bxddb(i).strain_nr==4
          disp(['Could not find strain ' bxddb(i).strain]);
          bxddb(i).strain_nr=[];
        end
      end
    otherwise
      bxddb(i).strain_nr=[];
  end
end


% index database per strain
ind_strain={};
for s=1:n_strains
  ind_strain{s}=find_record(bxddb,['strain=' strains{s} ]);
end



%calculate and mark weight outliers
n_weights=length(~isnan([bxddb(:).weight]));
disp(['Total weight measurements = ' num2str(n_weights) ]);
% OUTLIER REMOVAL
% average std in weight per strain is 2.0 grams
avg_weight_std=2.0;
% 1 want on average 1 false outlier ->
%nsigma = erfinv( 1-1/n_weights)*sqrt(2);
nsigma=2;
lowest_strain_weight=15.1;
minimum_weight=lowest_strain_weight-nsigma*avg_weight_std




for s=1:n_strains
  if ~isempty(ind_strain{s})
    weights=[bxddb(ind_strain{s}).weight]; % doesn't work if we have empty weight
    weight_mean=nanmean(weights);
    weight_std=nanstd(weights);
    
  % remove runted
%    ind_weight_outliers=[find(weights<minimum_weight) find(weights>weight_mean+6) ];
    ind_weight_outliers=find(weights<minimum_weight); % this removed two more runted animals
    
    ind_weight_ok=setdiff( (1:length(bxddb_per_strain{s})), ind_weight_outliers);

    %mark outliers
    for i=ind_strain{s}(ind_weight_outliers)
      bxddb(i).weight_outlier=1;
      disp(['mouse ' bxddb(i).mouse ' from strain ' bxddb(i).strain ' is runted, weight=' num2str(bxddb(i).weight) ' g' ]);

    end


    for i=ind_strain{s}(ind_weight_ok)
      bxddb(i).weight_outlier=0;
    end
  end
end

clear('ind_strain');

% select only records that meet extra conditions
ind=find_record(bxddb,extra_conditions);
bxddb=bxddb(ind);

% index database per strain
ind_strain={};
for s=1:n_strains
  ind_strain{s}=find_record(bxddb,['strain=' strains{s} ]);
end



% define groups
groups(1).name='all';
groups(1).filter='type=*';
groups(end+1).name='control';
groups(end).filter='type=contr*';
groups(end+1).name='deprived';
groups(end).filter='type=MD *';

for g=1:length(groups)
  groups(g).ind=find_record(bxddb,groups(g).filter);
end


% find numericfields
fields=fieldnames(bxddb);
numericfields={};
for i=1:length(fields)
  if isnumeric(bxddb(1).(fields{i})) ...
      && isempty(findstr(fields{i},'typing')) ...
      && isempty(findstr(fields{i},'usable')) ...
      && isempty(findstr(fields{i},'alive')) ...
      && isempty(findstr(fields{i},'sem')) ...
      && isempty(findstr(fields{i},'tg_number')) ...
      && strcmp('weight_outlier',fields{i})==0 ...
      && isempty(findstr(fields{i},'cbi')) ...
      && isempty(findstr(fields{i},'cage'))
    numericfields{end+1}=fields{i};
  end
end

% find age fields
agefields=[];
for i=1:length(numericfields)
  if ~isempty(findstr(numericfields{i},'age'))
    agefields(end+1)=i;
  end
end

% add general age field
numericfields{end+1}='age';
for m=1:length(bxddb)
  ages=[];
  for i=1:agefields
    ages(end+1)=bxddb(m).(numericfields{agefields(i)});
  end
  bxddb(m).age=nanmean(ages);
end

%remove other agefields
non_age_fields=setdiff( (1:length(numericfields)),agefields);
numericfields={numericfields{ non_age_fields}};

measures=numericfields;

% fill empty values with nan
for i=1:length(measures)
  for m=1:length(bxddb)
    if isempty( bxddb(m).(measures{i}) )
      bxddb(m).(measures{i})=nan;
    end
  end
end



disp('*** WRITE TRAITSFILE ***');
[strain_means,traits]=write_traitsfile( bxddb, measures,strains,groups,critlabel,min_n);



disp('*** 0. CALCULATE VARIANCES , #VALUES PER STRAIN THE SAME ***');
calculate_within_litter_variance( bxddb, measures,strains,ind_strain,groups,critlabel,n_shuffles,min_n)


disp('*** INTRASTRAIN CORRELATIONS (ALL MICE) ***')
calculate_intrastrain_correlations(bxddb , measures, groups, strain_means,traits,ind_strain,min_n);

disp('*** INTERSTRAIN CORRELATIONS (ONLY STRAINS WITH N>=MIN_N) ***')
calculate_interstrain_correlations( strain_means,traits);

disp('*** POINT CORRELATIONS ***')
calculate_correlations( bxddb , measures, groups);


disp([' NUMBER OF SHUFFLES FOR SHUFFLE TESTS = ' num2str(n_shuffles)]);

%%
disp('*** 1. CALCULATE HERITABILITY, ALL VALUES SHUFFLED, #VALUES PER STRAIN THE SAME ***');
calculate_heritability( bxddb, measures,strains,ind_strain,groups,critlabel,n_shuffles,min_n);

disp('*** 2. CALCULATE HERITABILITY, SHUFFLED WITH LITTERS STICKING TOGETHER ***');
calculate_heritability_litter_shuffle( bxddb, measures,strains,ind_strain,groups,critlabel,n_shuffles,min_n);

disp('*** 3. CALCULATE HERITABILITY, SHUFFLED WITH LITTERS STICKING TOGETHER AND CHOOSING FROM SIMILAR WEIGHTS***');
calculate_heritability_litter_shuffle_weight_balanced( bxddb, measures,strains,ind_strain,groups,critlabel,n_shuffles,min_n);


return




function calculate_interstrain_correlations(strain_means,traits)
global min_p
for t1=1:length(traits)-1
  if not_do_correlation_of_trait( traits{t1})
    continue
  end
  for t2=t1+1:length(traits)
    if not_do_correlation_of_trait(traits{t2})
      continue
    end
    if not_do_correlation_of_traits(traits{t1},traits{t2})
      continue
    end
    [r,n,p]=nancorrcoef(strain_means(t1,:),strain_means(t2,:) );
    if p<1E-50 % same values
      break
    end
    if p<min_p % significant correlation
      disp([ 'correlation between ' traits{t1} ...
        ' and ' traits{t2} ': ' ...
        num2str(r,2) ' p = ' num2str(p,4)]);
    end

    combi=[traits{t1} ' and ' traits{t2}];
    switch combi
      case 'control_weight and control_od_iodi'
        plot_correlation(strain_means(t2,:),strain_means(t1,:),...
          'Weight (g)','iODI');
        save_figure('bxd_interstrain_weight_vs_iodi.png');
      case 'shift_od_contra and shift_od_ipsi'
        plot_correlation(strain_means(t2,:),strain_means(t1,:),...
          'Shift in contra response','Shift in ipsi response');
        
        save_figure('bxd_correlation_shifts.png');
      case 'control_od_contra and deprived_od_contra'
        plot_correlation(strain_means(t2,:),strain_means(t1,:),...
          'contra Response','contra Response after MD');
        axis([0 0.07 0 0.07]);
        c=get(gca,'children');
         set(c(1),'xdata',[0 0.07]);
         set(c(1),'ydata',[0 0.07]);
        save_figure('bxd_correlation_od_contra_before_after.png');
      case 'control_od_ipsi and deprived_od_ipsi'
        plot_correlation(strain_means(t2,:),strain_means(t1,:),...
          'ipsi Response','ipsi Response after MD');
        axis([0 0.07 0 0.07]);
        c=get(gca,'children');
         set(c(1),'xdata',[0 0.07]);
         set(c(1),'ydata',[0 0.07]);
        save_figure('bxd_correlation_od_ipsi_before_after.png');
   %   case 'control_od_response and deprived_od_response'
   %     plot_correlation(strain_means(t2,:),strain_means(t1,:),...
   %       'Response','Response after MD');
   %     axis([0 0.07 0 0.07]);
   %     c=get(gca,'children');
   %      set(c(1),'xdata',[0 0.07]);
    %     set(c(1),'ydata',[0 0.07]);
     %   save_figure('bxd_correlation_od_response_before_after.png');
      %case 'all_weight and all_bregma2lambda'
      %  plot_correlation(strain_means(t2,:),strain_means(t1,:),...
      %    'Weight (g)','Bregma2Lambda (mm)');
    end
    
  end
end
return


function plot_correlation(x,y,xlab,ylab)
graph(x,y,'style','xy','xlab',xlab,'ylab',ylab,'extra_options','regression,linear');



return





%%
function calculate_intrastrain_correlations( bxddb , measures, groups,strain_means,traits,ind_strain,min_n)


global min_p
warning('off','MATLAB:divideByZero');
n_measures=length(measures);

for g=1:length(groups)
  for i=1:n_measures
    trait=[groups(g).name '_' measures{i}];
    traitnum=find(strcmp(traits,trait));
    for s=1:length(ind_strain)
      ind=intersect(ind_strain{s},groups(g).ind);
      if ~isempty(ind)
          smean=nanmean([bxddb(ind).(measures{i})]);
          n=sum(~isnan([bxddb(ind).bregma2lambda]));
%          if strcmp(trait,'all_bregma2lambda')==1
%          disp([ bxddb(ind(1)).strain ...
%            ' n=' num2str(n) ...
%            ' mean= ' num2str(nanmean([bxddb(ind).bregma2lambda])) ...
%            ]);
%          end
          if n<min_n
            smean=nan;
          end
          for j=ind
            bxddbgroup{g}(j).(measures{i})=bxddb(j).(measures{i})- smean;
          end
      end
    end
  end
end


for g=1:length(groups)
  for i=1:n_measures
    trait1=[groups(g).name '_' measures{i}];
    if not_do_correlation_of_trait(trait1 )
      continue
    end
    di=[bxddbgroup{g}(groups(g).ind).(measures{i})];
    if isempty(find(~isnan(di),1));continue;end
    for j=i+1:n_measures
      trait2=[groups(g).name '_' measures{j}];
      if not_do_correlation_of_trait(trait2 )
        continue
      end
      if not_do_correlation_of_traits(trait1,trait2 )
        continue
      end
      dj=[bxddbgroup{g}(groups(g).ind).(measures{j})];
      if isempty(find(~isnan(dj.*di),1));continue;end
      [r,n,p]=nancorrcoef(di ,dj );
      if p<1E-50 % same values
        break
      end
      if p<min_p % significant correlation
        disp([groups(g).name ': correlation between ' measures{i}  ...
          ' and ' measures{j} ': ' ...
          num2str(r,2) ' p = ' num2str(p,4)]);
      end

      combi=[trait1 ' and ' trait2];
      switch combi
      %  case 'all_weight and all_bregma2lambda'
      %    plot_correlation(dj,di,...
      %      'Weight','Bregma2lambda');
      %    save_figure('bxd_intrastraincorrelation_weight_bregma2lambda.png');
        case 'all_weight and all_bregma2lamba_weight_corrected'
          plot_correlation(di,dj,...
            'Bregma2lambda corrected','Weight');
      end


    end
  end
end
warning('on','MATLAB:divideByZero');
return



%%
function calculate_correlations( bxddb , measures, groups)
global min_p
warning('off','MATLAB:divideByZero');
n_measures=length(measures);
for g=1:length(groups)
  for i=1:n_measures
    
    if not_do_correlation_of_trait( [groups(g).name '_' measures{i}])
      continue
    end
    
    di=[bxddb(groups(g).ind).(measures{i})];
    if isempty(find(~isnan(di),1));continue;end

    for j=i+1:n_measures

      if not_do_correlation_of_trait( [groups(g).name '_' measures{j}])
        continue
      end
      if not_do_correlation_of_traits([groups(g).name '_' measures{i}], [groups(g).name '_' measures{j}])
        continue
      end

      dj=[bxddb(groups(g).ind).(measures{j})];
      if isempty(find(~isnan(dj.*di),1));continue;end
      [r,n,p]=nancorrcoef(di ,dj );
      if p<1E-50 % same values
        break
      end
      if p<min_p % significant correlation
        disp([groups(g).name ': correlation between ' measures{i}  ...
          ' and ' measures{j} ': ' ...
          num2str(r,2) ' p = ' num2str(p,4)]);
      end
      
      combi=[groups(g).name '_' measures{i} ' and ' groups(g).name '_' measures{j}];
      switch combi
        case 'control_weight and control_od_iodi'
          plot_correlation(dj,di,...
            'Weight (g)','iODI');
          save_figure('bxd_allpoints_weight_vs_iodi.png');
      end
    end
  end
end
warning('on','MATLAB:divideByZero');
return



function calculate_within_litter_variance( bxddb, measures,strains,ind_strains,groups,critlabel,n_shuffles,min_n)
%%
warning('off','MATLAB:divideByZero');
global min_p
n_measures=length(measures);
n_strains=length(strains);

for g=1:length(groups)
  for m=1:n_measures
    trait=[groups(g).name '_' measures{m}];
    if not_do_trait(trait)
      continue
	 end

	 std_strains=[];
	 std_litters=[];
    for s=1:n_strains
      bxddbs=bxddb(ind_strains{s});
      ind=find_record(bxddbs,groups(g).filter);

      vals=[];
      for i=ind
        value=bxddbs(i).(measures{m});
        litter_nr=bxddbs(i).strain_nr + ...
          eval([bxddbs(i).birthdate(3:4) bxddbs(i).birthdate(6:7) ...
          bxddbs(i).birthdate(9:10)])/1e6;
        if ~isnan(value)
          vals(end+1,1)=value;
          vals(end,2)=litter_nr;
          vals(end,3)=bxddbs(i).strain_nr;
        end
		end


		if ~isempty(vals)
        if length(find(~isnan(vals)))>=min_n
			  std_strains(end+1)=std(vals(:,1));
			  
			  uniqlitters=uniq(sort(vals(:,2)));
			  for l=uniqlitters
				  litvals=vals(find(vals(:,2)==l),1);
				  litvals=litvals(~isnan(litvals));
				  if length(litvals)>1
					  std_litters(end+1)=std(litvals);
				  end
			  end
		  
		  end
		end
	 end % strains

  
	 disp(   [ trait ' : mean_strain_std = ' num2str(mean(std_strains)) ...
		 ', mean_litters_std = ' num2str(mean(std_litters)) ]);
  end % measures
end % groups
	 



%%
function calculate_heritability_litter_shuffle( bxddb, measures,strains,ind_strains,groups,critlabel,n_shuffles,min_n)
warning('off','MATLAB:divideByZero');
global min_p
n_measures=length(measures);
n_strains=length(strains);

fid=fopen(['all_heritabilities_' critlabel '.txt'],'w');
for g=1:length(groups)
  for m=1:n_measures
    trait=[groups(g).name '_' measures{m}];
    if not_do_trait(trait)
      continue
    end

    vals_allstrains=[];
    for s=1:n_strains
      bxddbs=bxddb(ind_strains{s});
      ind=find_record(bxddbs,groups(g).filter);

      vals=[];
      for i=ind
        value=bxddbs(i).(measures{m});
        litter_nr=bxddbs(i).strain_nr + ...
          eval([bxddbs(i).birthdate(3:4) bxddbs(i).birthdate(6:7) ...
          bxddbs(i).birthdate(9:10)])/1e6;
        if ~isnan(value)
          vals(end+1,1)=value;
          vals(end,2)=litter_nr;
          vals(end,3)=bxddbs(i).strain_nr;
        end
      end
      if ~isempty(vals)
        if length(find(~isnan(vals)))>=min_n
          vals_allstrains=[vals_allstrains; vals];
        else
          % do not include strain in results
        end
      end
    end

    % calculate heritability


    uniqstrains=uniq(sort(vals_allstrains(:,3)));
    uniqlitters=uniq(sort(vals_allstrains(:,2)));
    n_litters_per_strain=[];
    for s=uniqstrains
      n_litters_per_strain(end+1)=length(find(floor(uniqlitters)==s));
    end

    for j=1:(1+n_shuffles)


      vals_her={};
      % prepare values for heritability calculation
      for s=uniqstrains
        ind= find(vals_allstrains(:,3)==s);
        vals_her{end+1}=vals_allstrains(ind,1)';
      end
      her(j)=heritability(vals_her);


      % shuffle litters
      % i.e. for each strain keep the number of litters the same, but pick
      % random litters (by first doing a permutation of all litters
      % and just pick the next in line)
      [temp,shuffle_ind]=sort(rand(length(uniqlitters),1));
      uniqlitters=uniqlitters(shuffle_ind);
      litter=1;
      for s=1:length(uniqstrains)
        for i=1:n_litters_per_strain(s)
          % select all mice from current litter
          ind=find(vals_allstrains(:,2)==uniqlitters(litter));

          % change strain_nr for these mice into current strain number
          vals_allstrains(ind,3)=uniqstrains(s);

          % go to next litter
          litter=litter+1;
        end
      end


    end % j

    if her(1)>min_p | 1
      n_smaller_than=length(find(her(1)<her(2:end)));
      p=n_smaller_than/n_shuffles;
      txt=[trait '\t' num2str(her(1),2)  ', p = ' num2str(p,4) ' (shuffle test)\n'];
      fprintf(txt);
      fprintf(fid,txt);
    end

    if 0
      figure
      hist(her(2:end),max(10,ceil(length(her)/10)));
      hold on
      ax=axis;
      ax(2)=1;
      axis(ax);
      line( [her(1) her(1)],[ax(3) ax(4)]);
    end


  end
end
warning('on','MATLAB:divideByZero');

fclose(fid);
return





%%
function calculate_heritability_litter_shuffle_weight_balanced( bxddb, measures,strains,ind_strains,groups,critlabel,n_shuffles,min_n)
global min_p




warning('off','MATLAB:divideByZero');
n_measures=length(measures);
n_strains=length(strains);

    pm_gram=2;
    disp(['shuffling ' num2str(n_shuffles) ...
      ' times, while keeping mean litter weights within ' num2str(pm_gram) ' grams']);

fid=fopen(['all_heritabilities_' critlabel '.txt'],'w');
for g=1:length(groups)
  for m=1:n_measures
    % calculate heritability
    trait=[groups(g).name '_' measures{m}];
    if not_do_trait(trait)
      continue
    end

    vals_allstrains=[];
    for s=1:n_strains
      bxddbs=bxddb(ind_strains{s});
      ind=find_record(bxddbs,groups(g).filter);

      vals=[];
      for i=ind
        value=bxddbs(i).(measures{m});
        litter_nr=bxddbs(i).strain_nr + ...
          eval([bxddbs(i).birthdate(3:4) bxddbs(i).birthdate(6:7) ...
          bxddbs(i).birthdate(9:10)])/1e6;
        if ~isnan(value) && ~isnan(bxddbs(i).weight) % if weight is nan I can't do weight shuffle
          vals(end+1,1)=value;
          vals(end,2)=litter_nr;
          vals(end,3)=bxddbs(i).strain_nr;
          vals(end,4)=bxddbs(i).weight;
        end
      end
      if ~isempty(vals)
        if  length(find(~isnan(vals)))>=min_n
          vals_allstrains=[vals_allstrains; vals];
        else
          % do not include strain in results
        end
      end
    end

    uniqstrains=uniq(sort(vals_allstrains(:,3)));
    uniqlitters=uniq(sort(vals_allstrains(:,2)));

    % compute number of litters per strain
    n_litters_per_strain=[];
    for s=uniqstrains
      n_litters_per_strain(end+1)=length(find(floor(uniqlitters)==s));
    end

    % compute vector with mean litter weights
    mean_litter_weight=[];
    for l=uniqlitters
      ind_litter=find(vals_allstrains(:,2)==l);
      mean_litter_weight(end+1)=mean(vals_allstrains(ind_litter,4));
    end
    
    
    shuffles=1;
    org_vals_allstrains=vals_allstrains;
    global max_shuffletime
    max_shuffletime=0.2;
    global start_clock
    set(0,'RecursionLimit',length(uniqlitters)+5)
    while shuffles<=n_shuffles
      
      
      % calculate heritability first, so that it first time it is not
      % shuffled
      vals_her={};
      % prepare values for heritability calculation
      for s=uniqstrains
        ind= find(vals_allstrains(:,3)==s); % select all mice of strain s
        vals_her{end+1}=vals_allstrains(ind,1)'; % add values of these mice
      end
      her(shuffles)=heritability(vals_her); % compute heritability
      
      
      % randomize litter order for random seed of weight-matched litter shuffle
      [temp,shuffle_ind]=sort(rand(length(uniqlitters),1));
      uniqlitters=uniqlitters(shuffle_ind);
      mean_litter_weight=mean_litter_weight(shuffle_ind);
      
      % shuffle litter weights while keeping within PM_GRAM distance of
      % original weight
      start_clock=clock;
      shuffled_weights=shuffle_similar(mean_litter_weight,mean_litter_weight,[],pm_gram);
      if isempty(shuffled_weights)
        continue
      end
      if isnan(shuffled_weights(1))
        continue 
      end
      shuffles=shuffles+1;
      
      ind_shuffle=[];
      for l=1:length(mean_litter_weight)
        % match shuffled weights to original list to find shuffle sequence
        ind_shuffle(l)=find(mean_litter_weight==shuffled_weights(l),1);
      end
      if sum(abs(mean_litter_weight(ind_shuffle)-shuffled_weights))~=0
        disp('something is wrong');
      end
      
      %disp(mat2str(mean_litter_weight(ind_shuffle),2));
      %disp(mat2str(shuffled_weights,2));
     
      % perform the shuffle on mice values
      for l=1:length(uniqlitters)
        ind_mice_litter=find(org_vals_allstrains(:,2)==uniqlitters(l)); % select all mice of original litter
        vals_allstrains(ind_mice_litter,3)=floor(uniqlitters(ind_shuffle(l))); % and give them the randomly chosen strain number
      end




          end % shuffles

    if her(1)>min_p || 1
      n_smaller_than=length(find(her(1)<her(2:end)));
      p=n_smaller_than/n_shuffles;
      txt=[ trait '\t' num2str(her(1),2)  ', p = ' num2str(p,4) ' (shuffle test)\n'];
      fprintf(txt);
      fprintf(fid,txt);
    end

    
    if 0
      figure
      hist(her(2:end),max(10,ceil(length(her)/10)));
      hold on
      ax=axis;
      ax(2)=1;
      axis(ax);
      line( [her(1) her(1)],[ax(3) ax(4)]);
    end

  end
end
warning('on','MATLAB:divideByZero');

fclose(fid);
return




%%
function calculate_heritability( bxddb, measures,strains,ind_strains,groups,critlabel,n_shuffles,min_n)
global min_p
warning('off','MATLAB:divideByZero');
n_measures=length(measures);
n_strains=length(strains);

fid=fopen(['all_heritabilities_' critlabel '.txt'],'w');

for g=1:length(groups)
  for i=1:n_measures
    trait=[groups(g).name '_' measures{i}];
    if not_do_trait(trait)
      continue
    end

    vals_allstrains={};

    for s=1:n_strains
      bxddbs=bxddb(ind_strains{s});
      ind=find_record(bxddbs,groups(g).filter);
      vals=[ bxddbs(ind).(measures{i})];
      vals=vals(find(~isnan(vals)));

      if ~isempty(vals)
        if length(find(~isnan(vals)))>= min_n
          vals_allstrains{end+1}=vals;
        else
          % do not include strain in results
        end
      end
    end

    % calculate heritability
    [her,p]=heritability_shuffle(vals_allstrains,n_shuffles);

    if her>min_p || 1
      txt=[trait '\t' num2str(her,2) ', p = ' num2str(p,4) ' (shuffle test)\n'];
      fprintf(txt);
      fprintf(fid,txt);
    end

  end
end
warning('on','MATLAB:divideByZero');

fclose(fid);
return

%%
function [strain_means,traits]=write_traitsfile( bxddb, measures,strains,groups,critlabel,min_n)

filename=['levelt_traits_' critlabel '_min' num2str(min_n) '.txt'];
fid=fopen(filename,'w');

% write header
header='@format=column' ;
for g=1:length(groups)
  for i=1:length(measures)
    trait=[ groups(g).name '_' measures{i}];
    if ~not_do_trait(trait)
      header=[header '\t' trait '\tSE\tN'];
    end
  end
end
header=[header '\tabs_shift_od_iodi\tSE'];
header=[header '\trel_shift_od_iodi\tSE'];
header=[header '\tabs_shift_od_contra\tSE'];
header=[header '\trel_shift_od_contra\tSE'];
header=[header '\tabs_shift_od_ipsi\tSE'];
header=[header '\trel_shift_od_ipsi\tSE'];
header=[header '\tabs_shift_od_response\tSE'];
header=[header '\trel_shift_od_response\tSE'];

weight_traits={}; %{'10358','10461','10647','10892'};
% '10031','10157' have too few overlapping strains
for wt=1:length(weight_traits)
  header=[header '\trel_weight_' weight_traits{wt}];
end
  header=[header '\n'];
fprintf(fid,header);


% write data, each line a strain
for s=1:length(strains)

  strain=strains{s};
  p=find(strain=='-',1);
  if ~isempty(p)
    strain=[strain(1:p-1) strain(p+1:end)];
  end
  if streq(strain,'BXD0*')
    strain=[strain(1:3) strain(end)];
  end


  fprintf(fid, [strain '\t']);

  t=1;
  bxdstraindb=bxddb(find_record(bxddb,['strain=' strains{s} ]));
  for g=1:length(groups)
    ind=find_record(bxdstraindb,groups(g).filter);
    for i=1:length(measures)
      trait=[ groups(g).name '_' measures{i}];
      if not_do_trait(trait)
        continue
      end
      
      

      vals=[ bxdstraindb(ind).(measures{i})];
      vals=vals(~isnan(vals));

      if length(find(~isnan(vals)))>=min_n
        valsmean=nanmean(vals);
        valssem=sem(vals);
        valsn=length(~isnan(vals));
      else
        valsmean=nan;
        valssem=nan;
        valsn=nan;
      end

      if ~isempty(findstr(trait,'contra')) ||...
          ~isempty(findstr(trait,'ipsi')) || ...
          ~isempty(findstr(trait,'response')) 
        valsmean=valsmean * 10; % to make 0/00
        valssem=valssem * 10;
        
        % because this is done before updating strain_means, 
        % automatically the shifts are also in 0/00
      end

      strain_means(t,s)=valsmean;
      strain_sems(t,s)=valssem;
      traits{t}=trait;
      t=t+1;
          
      
      value_out(fid,valsmean);
      value_out(fid,valssem);
      value_out(fid,valsn);

 
      
    end
  end

  % shift traits
  shifttrait={'od_iodi','od_contra','od_ipsi','od_response'};
  for stn=1:length(shifttrait)
    % absolute
    
    tn1=find(strcmp(traits,['control_' shifttrait{stn}])==1);
    tn2=find(strcmp(traits,['deprived_' shifttrait{stn}])==1);
    valsmean=strain_means(tn2,s)-strain_means(tn1,s);
    value_out(fid,valsmean);

    valssem=sqrt(strain_sems(tn2,s)^2+strain_sems(tn1,s)^2);
    value_out(fid,valssem);

    strain_means(t,s)=valsmean;
    traits{t}=['abs_shift_' shifttrait{stn}];
    t=t+1;
    
    % relative
    valsmean=valsmean/strain_means(tn1,s);
    value_out(fid,valsmean);

    valssem=sqrt(strain_sems(tn2,s)^2+strain_sems(tn1,s)^2)/strain_means(tn1,s); %not all contributions!
    value_out(fid,valssem);

    strain_means(t,s)=valsmean;
    traits{t}=['rel_shift_' shifttrait{stn}];
    t=t+1;
    
    
  end

  
  %relative weights
  for wt=1:length(weight_traits)
    tn1=find(strcmp(traits,'all_weight')==1);
    val=get_genenetwork_probe(strain, 'BXDPublish',weight_traits{wt});
    valsmean=strain_means(tn1,s)/val;
    value_out(fid,valsmean);
    strain_means(t,s)=valsmean;
    traits{t}=['rel_weight_' weight_traits{wt}];
    t=t+1;
  end  
  
  % end line
  fprintf(fid,'\n');
end

fclose(fid);

return

%%
function value_out(fid,valsmean)
if isnan(valsmean)
  valsmean='x';
else
  valsmean=num2str(valsmean,8);
end
fprintf(fid, [valsmean '\t']);
return

function ret=not_do_correlation_of_trait(trait)
switch trait
  case {'all_od_iodi','all_od_contra','all_od_ipsi','all_sf_sf_cutoff','all_sf_max_response','all_age','all_strain_nr',...
      'all_retinotopy_screen_center_ap_b2l','all_retinotopy_screen_center_ml_b2l'}
    ret=1;
  case {'control_sf_max_response',...
      'control_sf_sf_cutoff','control_strain_nr',...
      'control_retinotopy_screen_center_ap',...
      'control_retinotopy_screen_center_ap_b2l'...
      }
    ret=1;
  case {'deprived_sf_sf_cutoff',...
      'deprived_sf_max_response','deprived_strain_nr',...
      'deprived_retinotopy_screen_center_ap',...
      'deprived_retinotopy_screen_center_ap_b2l',...
      'deprived_retinotopy_screen_center_ml_b2l'...
      }
    ret=1;
  otherwise
    ret=0;
end
return


function ret=not_do_correlation_of_traits(trait1,trait2)
combi=[trait1 ' and ' trait2];
switch combi
  case {'all_retinotopy_screen_center_ap and all_retinotopy_screen_center_ap_mb2l',...
      'all_od_response and control_od_contra',...
      'all_od_response and control_od_ipsi',...
      'all_od_response and control_od_response',...
      'all_od_response and deprived_od_contra',...
      'all_od_response and deprived_od_ipsi',...
      'all_od_response and deprived_od_response',...
      'control_od_iodi and control_od_ipsi',...
      'control_od_contra and control_od_response',...
      'control_od_ipsi and control_od_response',...
      'deprived_od_iodi and deprived_od_ipsi',...
      'deprived_od_contra and deprived_od_response',...
      'deprived_od_ipsi and deprived_od_response',...
      'control_retinotopy_screen_center_ml and control_retinotopy_screen_center_ml_b2l',...
      'control_bregma2lambda and control_retinotopy_screen_center_ml_b2l',...
      'shift_od_contra and shift_od_response',...
      'shift_od_ipsi and shift_od_response'...
      }
  ret=1;
  otherwise
    ret=0;
end
return


%%
function ret=not_do_trait(trait)
switch trait
  case {'all_od_iodi','all_od_contra','all_od_ipsi','all_sf_sf_cutoff',...
      'all_sf_max_response','all_age','all_strain_nr',...
      	'all_od_response',...
      	'all_retinotopy_screen_center_ml_b2l',...
      'all_retinotopy_screen_center_ap_b2l',...
      'all_od_pc_response',...
      'all_od_pc_od'...
      }
    ret=1;
  case { ...%'control_weight',
      'control_bregma2lambda',...
      'control_retinotopy_screen_center_ap',...
      'control_retinotopy_screen_center_ap_b2l',...
      'control_retinotopy_screen_center_ap_mb2l',...
      'control_retinotopy_screen_center_ml',...
      'control_retinotopy_screen_center_ml_b2l',...
      'control_retinotopy_screen_center_ml_mb2l',...
      'control_age','control_sf_max_response',...
      'control_sf_sf_cutoff','control_strain_nr',...
      'control_bregma2lambda_weight_corrected',...
      'control_od_pc_od'...
    }
      ret=1;
  case {'deprived_weight','deprived_bregma2lambda','deprived_retinotopy_screen_center_ml',...
      'deprived_retinotopy_screen_center_ml_b2l','deprived_retinotopy_screen_center_ap',...
      'deprived_retinotopy_screen_center_ap_b2l','deprived_age','deprived_sf_sf_cutoff',...
      'deprived_sf_max_response','deprived_strain_nr',...
      'deprived_retinotopy_screen_center_ap_mb2l',...
      'deprived_bregma2lambda_weight_corrected',...
      'deprived_od_pc_response',... 
      'deprived_od_pc_od'...
      }
    ret=1;

  otherwise
    ret=0;
end