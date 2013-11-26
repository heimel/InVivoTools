function make_bxdacuity
%MAKE_BXDACUITY
cd(bxddatadir);

labels=[' ']; % ['yND';'yMD'];
strains=neurobsik_strains;

n_strains=length(strains);

types={'control 1*'};
[r_n,p_n]=make_popgraph(strains,types,'sf','sf_cutoff','contra',...
		    labels,'Acuity (cpd)',[0.2 0.7],[],[],0);
save_figure('control_bxd_acuity');

her_control=heritability( r_n);
herline=['heritability,BXD-\*,,control 1 month,male,,,,,,,,' num2str(her_control,2) ',0'];
disp(herline);
[status,result] = system(['echo ' herline ' >> results.csv']);

her_var_control=heritability_var( r_n);
herline=['heritability_var,BXD-\*,,control 1 month,male,,,,,,,,' num2str(her_var_control,2) ',0'];
disp(herline);
[status,result] = system(['echo ' herline ' >> results.csv']);

!mv results.csv control_bxd_acuity.csv
!grep mean control_bxd_acuity.csv | cut -f13 -d, > control_bxd_acuity_means.txt

return


