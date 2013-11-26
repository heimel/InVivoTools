function heritability_bottleneck

disp('Example heritability calculation')


disp(['Note: in inbred (homozygous) populations the genetic covariance is twice '...
  'the additive covariance of an outbred (heterozygous) population, '...
  'because both alleles are now strongly correlated (i.e. identical).']);

n_genes=1;
n_strains=100;
n_mice_per_strain=50;


% genotypes( n_strains , n_genes )
genotypes=2*((rand(n_strains,n_genes)>0.5)-0.5);

% phenotypes{ n_strains} ( n_mice_per_strain )
phenotypes={};

std_environment=1;

for s=1:n_strains
  for m=1:n_mice_per_strain
    phenotypes{s}(m)=geno2phenotype( genotypes(s,: ), std_environment );
  end
end

h2var= 1/2/(1/2+std_environment^2)


h=heritability(phenotypes)



for s=1:n_strains
  mean_phenotypes(s)=mean(phenotypes{s});
  std_phenotypes_per_strain=std(phenotypes{s});
end
mean_std_phenotypes_per_strain=mean(std_phenotypes_per_strain);
std_mean_phenotypes=std(mean_phenotypes);

h2empir=1/2*std_mean_phenotypes^2/...
  (1/2*std_mean_phenotypes^2+mean_std_phenotypes_per_strain^2)

%unrelated_phenotypes=zeros(n_strains,1);
%for s=1:n_strains
%  unrelated_phenotypes(s)=phenotypes{s}(1);
%end
%sigma_z=std(unrelated_phenotypes);
%H2_broad_sense_empirical=std_mean_phenotypes^2/sigma_z^2


return

pvals=ones(n_genes,1);
for g=1:n_genes
  [r,p]=corrcoef(mean_phenotypes,genotypes(:,g));
  pvals(g)=p(1,2);
end
pvals(1)
median(pvals)


fid=fopen('/home/heimel/fake_her_data.csv','w');
for s=1:n_strains
  for m=1:n_mice_per_strain
    %fprintf([num2str(s) ',' num2str(phenotypes{s}(m),3) ' \n']);
    fprintf(fid,[num2str(s) ',' num2str(phenotypes{s}(m),3) ' \n']);
  end
  
end
fclose(fid);


return

function phenotype=geno2phenotype( genome,std_environment )
% std_genotype should be 1 
phenotype=genome(1)+std_environment*random('norm',0,1,1);
%  phenotype=sum(genome)+sqrt(length(genome))*random('norm',0,1,1);
return