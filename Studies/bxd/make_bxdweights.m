%make_bxdweights
cd(bxddatadir)

labels=[' ']; % ['yND';'yMD'];
strains=neurobsik_strains;

%strains={strains{2:10}};
n_strains=length(strains);
cluster_strains=1;

!rm results.csv
types={'(type=control 1 month*|type=MD 7d from p28*)'};
[r_n,p_n]=make_popgraph(strains,types,'none','weight','',...
		    labels,'Weight (g)',[1 40],...
			cluster_strains,[],0,[],[]);
save_figure('weight_bxd');

her_control=heritability( r_n);
herline=['heritability,BXD-\*,,1 month,male,,,,,,,,' num2str(her_control,2) ',0'];
disp(herline);
[status,result] = system(['echo ' herline ' >> results.csv']);

her_var_control=heritability_var( r_n);
herline=['heritability_var,BXD-\*,,1 month,male,,,,,,,,' num2str(her_var_control,2) ',0'];
disp(herline);
[status,result] = system(['echo ' herline ' >> results.csv']);


!mv results.csv weight_bxd.csv
!grep mean weight_bxd.csv | cut -f13 -d, > weight_bxd_means.txt
her=heritability( r_n);

weight=[];
for i=1:length(r_n)
  weight(i)=nanmean(r_n{i});
end




