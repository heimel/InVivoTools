function chromosome = mutate( chromosome, param )
%MUTATE mutates a stimulus chromosome
%    
%   CHROMOSOME = MUTATE( CHROMOSOME, PARAM )
%      deletes param.n_deletes genes
%      mutates ceil(param.mutationrate * length(chromosome)) genes
%
%   CHROMOSOME = MUTATE( CHROMOSOME )
%      uses genetic_defaults as PARAM
% 
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if nargin<2
  param=genetic_defaults;
end

% deleting
i=0;
while (length(chromosome)>param.min_n_genes & i<param.n_deletes) | ...
      length(chromosome) > param.max_n_genes
  g=ceil( length(chromosome) *rand(1));
  chromosome = delete_element(chromosome, g);
  i=i+1;  
end

% creating
i=0;
while (length(chromosome)<param.max_n_genes & i<param.n_creations)| ...
      length(chromosome)<param.min_n_genes
  if rand(1)>0.5
    chromosome(end+1)=create_gene(param); % completely new
  else 
     chromosome(end+1)=chromosome( unidrnd(length(chromosome)) ); % copy gene
  end
end
  
%mutating
n_mutates = ceil( length(chromosome) * param.mutationrate);
for i=1:n_mutates
  g=ceil( length(chromosome) *rand(1));
  chromosome(g)=mutate_gene( chromosome(g),param );
end


%shrink
if param.shrinkingforce~=0
    for g=1:length(chromosome)
	chromosome(g).size=chromosome(g).size- ...
	    round(param.shrinkingforce*rand(1));
	chromosome(g).size=max(1,chromosome(g).size);

	chromosome(g).duration=chromosome(g).duration- ...
	    round(param.shrinkingforce*rand(1));
	chromosome(g).duration=max(1,chromosome(g).duration);
    end
end



