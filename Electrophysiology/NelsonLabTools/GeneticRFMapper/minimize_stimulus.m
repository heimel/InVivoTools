function minimal_stimulus=minimize_stimulus(stimulus,param,kernel)
%MINIMIZE_STIMULUS minimizes the optimal stimulus
%
%   STIMULUS=MINIMIZE_STIMULUS(STIMULUS,PARAM)
%   produces stimuli by leaving genes out, calculating response,
%   selecting one which still spike as well, leave one more gene
%   out and repeat this procedure until, one can no longer leave
%   any genes out, without lowering the fitness.
%   
%
%   STIMULUS=MINIMIZE_STIMULUS(STIMULUS,PARAM)
%   simulates the process with neuron with a linear KERNEL
%
%   The maximum tolerated difference in fitness is set by 
%   PARAM.FITNESS_VARIATION
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel (heimel@brandeis.edu)
%

if nargin==3
  simulation=1;
  disp('Simulating stimulus minimalization');
else
  disp('Measuring minimal stimulus');
  simulation=0;
  cksds = getcksds;
  if isempty(cksds), 
    errordlg(['No existing data---make sure you hit '...
	      'return after directory in RunExperiment window']);
    return;
  end; 
  nameref = getnameref;
  if isempty(nameref)
    errordlg('Could not get a namereference for the cell.');
    return
  end
end


if nargin<2
  param=genetic_defaults;
end

nonlinearity='poissonfiring';


param.repeats=20;

%calculate fitness again (but probably more accurate)
if simulation
  responses=simulate_response( {stimulus.chromosome}, kernel,...
			       nonlinearity, param);
else
  responses=measure_responses(chromosomes,cksds,nameref,param);
end
stimulus.fitness=compute_fitness(responses);



n_genes=length(stimulus.chromosome);

% generate all leave-one-out
for i=1:n_genes
  genetable(i,:)=[1:i-1 i+1:n_genes];
  chromosomes{i}=stimulus.chromosome(genetable(i,:));
end

if simulation
  responses=simulate_response( chromosomes, kernel,nonlinearity,param );
else
  responses=measure_responses(chromosomes,cksds,nameref,param);
end






fitnesses=compute_fitness(responses);			    
samefitness=find( fitnesses>(1-param.fitness_variation)*stimulus.fitness );

n_genes=n_genes-1;

not_essential=samefitness;

minimized=0;
while ~minimized
  
  
  % create new chromosome set
  newset=[];
  for i=1:length(samefitness)
    for j=1:n_genes
      f=find(not_essential==genetable(samefitness(i)  ,j));
      if ~isempty(f)
	proposal=genetable(samefitness(i),[1:j-1 j+1:n_genes]);
	alreadyfound=0;
	for k=1:size(newset,1)
	  if proposal==newset(k,:)
	    alreadyfound=1;
	    break;
	  end
	end
	if ~alreadyfound
	  newset(end+1,:)=proposal;
	end
      end
    end
  end
  
  old.responses=responses;
  old.fitnesses=fitnesses;
  old.chromosomes=chromosomes;
  old.genetable=genetable;
  
  genetable=newset;
  chromosomes={};
  for i=1:size(genetable,1)
    chromosomes{i}=stimulus.chromosome(genetable(i,:));
  end

  if size(genetable,1)==0
    disp('Already nothing left?');
    break;
  end
  
  if simulation
    responses=simulate_response(chromosomes,kernel,nonlinearity,param);
  else
    disp(['Going to show ' num2str(size(genetable,1)) ' stimuli.']);
    responses=measure_responses(chromosomes,cksds,nameref,param);
  end
  
  fitnesses=compute_fitness(responses);
  samefitness=find( fitnesses>(1-param.fitness_variation)* ...
		     stimulus.fitness );
  
  if isempty(samefitness) % no stimulus of same fitness as original
    minimized=1;    
  end
  n_genes=n_genes-1;
  disp(['Selected ' num2str(size(genetable,1)) ' chromosomes with' ...
		    ' each ' num2str(size(genetable,2)) ' genes.']);
end

% pick stimulus with highest fitness
[m,i]=max(old.fitnesses);
minimal_stimulus=struct('chromosome',old.chromosomes(i));
minimal_stimulus.response=old.responses(i,:);
minimal_stimulus.fitness=old.fitnesses(i);





