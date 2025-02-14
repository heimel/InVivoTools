function chromosome=create_chromosome(param)
%CREATE_CHROMOSOME creates new stimulus chromosome
%
%   CHROMOSOME=CREATE_CHROMOSOME(PARAM)
%      PARAM is struct with general parameters
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if nargin==0
  param=genetic_defaults;
end

for g=1:ceil(rand(1)*param.max_n_genes)
  chromosome(g)=create_gene(param);
end