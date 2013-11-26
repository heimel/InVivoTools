function make_bxdiodi
cd(bxddatadir);
labels=[' ']; % ['yND';'yMD'];
strains=neurobsik_strains;

n_strains=length(strains);

prefax=[];

!rm results.csv

types={'control 1*'};
[r_n,p_n]=make_popgraph(strains,types,'od','iodi','',...
		    labels,'imaged Ocular Dominance Index',prefax,[],[],0);
save_figure('control_bxd_iodi');

her_control=heritability( r_n);
herline=['heritability,BXD-\*,,control 1 month,male,,,,,,,,' num2str(her_control,2) ',0'];
disp(herline);
[status,result] = system(['echo ' herline ' >> results.csv']);

her_var_control=heritability_var( r_n);
herline=['heritability_var,BXD-\*,,control 1 month,male,,,,,,,,' num2str(her_var_control,2) ',0'];
disp(herline);
[status,result] = system(['echo ' herline ' >> results.csv']);

!mv results.csv control_iodi_bxd.csv
!grep mean control_iodi_bxd.csv | cut -f13 -d, > control_iodi_bxd_means.txt

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   DEPRIVED IODI    %%%
types={'MD 7d from*'};
[r_d,p_d]=make_popgraph(strains,types,'od','iodi','',...
		    labels,'imaged Ocular Dominance Index',prefax,[],[],0);
save_figure('deprived_bxd_iodi');

her_deprived=heritability( r_d);
herline=['heritability,BXD-\*,,MD 7d from p28,male,,,,,,,,' num2str(her_deprived,2) ',0'];
disp(herline);
[status,result] = system(['echo ' herline ' >> results.csv']);

her_var_deprived=heritability_var( r_d);
herline=['heritability_var,BXD-\*,,MD 7d from p28,male,,,,,,,,' num2str(her_var_deprived,2) ',0'];
disp(herline);
[status,result] = system(['echo ' herline ' >> results.csv']);

!mv results.csv deprived_iodi_bxd.csv
!grep mean deprived_iodi_bxd.csv  | cut -f13 -d, > deprived_iodi_bxd_means.txt


%% %%%% DELTA IODI %%%%%%%%%%%%%%%%%5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

delta_iodi={};
std_delta_iodi={};
rel_delta_iodi={};
for s=1:n_strains
  std_delta_iodi{s}=[];
  delta_iodi{s}=[];
  std_delta_iodi{s}=[];
  means(s)=nan;
  stds(s)=nan;
  counts(s)=0;
  if ~isempty(r_n{s}) & ~isempty(r_d{s})
    delta_iodi{s}=mean(r_n{s})-mean(r_d{s});
    means(s)=delta_iodi{s};
    std_delta_iodi{s}=nan;
    if length(r_n{s})>1 & length(r_d{s})>1 
      counts(s)=sqrt( length(r_n{s})^2 + length(r_d{s})^2);
      std_delta_iodi{s}=sqrt( std(r_n{s})^2/length(r_n{s}) + ...
        std(r_d{s})^2/length(r_d{s}) );
      stds(s)=std_delta_iodi{s};
    end
    rel_delta_iodi{s}=(mean(r_n{s})-mean(r_d{s}))/mean(r_n{s});
    
  end
end

her_var_delta=heritability_var(means, stds, counts);
herline=['heritability_var,BXD-\*,,delta IODI at p35,male,,,,,,,,' num2str(her_var_delta,2) ',0'];
disp(herline);
[status,result] = system(['echo ' herline ' > results.csv']);
!mv results.csv delta_iodi_bxd.csv

plotresult(delta_iodi,std_delta_iodi,strains);
save_figure('bxd_delta_iodi');

fid=fopen('delta_iodi_bxd_means.txt','w');
for s=1:length(strains)
  if isnan(means(s))
    val='x';
  else
    val=num2str(means(s),2);
  end
  fprintf(fid,'%s\n',val);
end
fclose(fid);

%%
disp(['Heritability of control bxd iodi: ' num2str(her_control,2)]);
disp(['Heritability of control bxd iodi from variance: ' num2str(her_var_control,2)]);
disp(['Heritability of deprived bxd iodi: ' num2str(her_deprived,2)]);
disp(['Heritability of deprived bxd iodi from variance: ' num2str(her_var_deprived,2)]);
disp(['Heritability of  bxd delta iodi from variance: ' num2str(her_var_delta,2)]);

return


%%
function plotresult( r,dr,strains)
y=[];
dy=[];
l=[];
for s=1:length(r)
  if ~isempty(r{s})
    y(end+1)=r{s};
    if ~isempty(dr{s})
      dy(end+1)=dr{s};
    else
      dy(end+1)=0;
    end
    if isempty(findstr(strains{s},'BXD'));
      l(end+1,1:3)=strains{s}(1:min(3,end));
    else
      l(end+1,1:3)=[' ' strains{s}(5:end)];
    end
    
  end
end
l=char(l);   
x=(1:length(y));

figure
h=bar(x,y,0.6);
hold on;
errorbar(x,y,dy,'.k');
set(h,'FaceColor',0.7*[1 1 1]);
set(gca,'XTick',x);
set(gca,'XTickLabel',l);

bigger_linewidth(3);
smaller_font(-11);


