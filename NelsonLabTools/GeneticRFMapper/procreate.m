function chromosomes=procreate( stimuli, param )
%PROCREATE produces chromosomes of stimuli by cross-over and mutation
% 
%   CHROMOSOMES=PROCREATE( STIMULI, PARAM )
%      divides all stimuli randomly in pairs and for each pair
%      produces two children by random position cross-over and 
%      mutation. Returns chromosomes
%
%   CHROMOSOMES=PROCREATE( STIMULI )
%      uses genetic_defaults as PARAM
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if nargin<2
  param = genetic_defaults;
end

N=length(stimuli);
parents=randperm( N );

if param.nocrossover
  for i=1:N
    chromosomes{i}=stimuli(i).chromosome;
  end
else
  % cross-over
  for i=1:2:N
    mom = stimuli(parents(i));
    dad = stimuli(parents( mod(i,N) + 1));
    cutmom = ceil( (length(mom.chromosome)-1)*rand(1) );
    cutdad = ceil( (length(dad.chromosome)-1)*rand(1) );
    
    chromosomes{i} = [ mom.chromosome(1:cutmom),...
		       dad.chromosome(cutdad+1:end) ];
    
    chromosomes{i+1} = [ dad.chromosome(1:cutdad),...
		    mom.chromosome(cutmom+1:end) ];
  end
end

%mutate
for i=1:N
  chromosomes{i} = mutate( chromosomes{i}, param );
end






