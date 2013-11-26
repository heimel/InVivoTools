function make_bxdpos
cd(bxddatadir);

labels=[' ']; % ['yND';'yMD'];
strains=neurobsik_strains;

%strains={strains{2:10}};
n_strains=length(strains);
types={'control 1*'};
cluster_strains=1;


%% POSML  %%%


!rm results.csv
[r_n,p_n]=make_popgraph(strains,types,'retinotopy','screen_center_ml','',...
		    labels,'Lateral from Lambda (\mu m)',[1 3],...
			cluster_strains,[],0,[],[]);
save_figure('posml_bxd');

her_control=heritability( r_n);
herline=['heritability,BXD-\*,,control 1 month,male,,,,,,,,' num2str(her_control,2) ',0'];
disp(herline);
[status,result] = system(['echo ' herline ' >> results.csv']);

her_var_control=heritability_var( r_n);
herline=['heritability_var,BXD-\*,,control 1 month,male,,,,,,,,' num2str(her_var_control,2) ',0'];
disp(herline);
[status,result] = system(['echo ' herline ' >> results.csv']);

!mv results.csv posml_bxd.csv
!grep mean posml_bxd.csv | cut -f13 -d, > posml_bxd_means.txt


if 0
  [r_n,p_n]=make_popgraph(strains,types,'retinotopy','screen_center_ap_b2l','',...
    labels,'Anterior from Lambda (\mu m)',...
    [-0.5 1.5],[],[],0,[],[]);
  save_figure('posap_b2l_bxd');
  !mv results.csv posap_b2l_bxd.csv
end

return


