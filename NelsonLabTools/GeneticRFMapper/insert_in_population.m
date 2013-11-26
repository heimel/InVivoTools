function stimuli=insert_in_population( oldstimuli, chromosome, ...
				       response, fitness, generation )
%INSERT_IN_POPULATION inserts evaluated chromosomes into population
%
%  STIMULI=INSERT_IN_POPULATION( OLDSTIMULI, CHROMOSOME, ...
%	  		       RESPONSE, FITNESS, GENERATION )
%  insertion is done in order of fitness, highest fitness comes
%  first. Can be one or many
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%


Nnew=length(fitness);
stimuli=oldstimuli;

for i=1:Nnew
  [ind,v] = findclosest([stimuli(:).fitness],fitness(i));
  if v>fitness(i)  % new should come after ind
    stimuli=insert_stimulus(stimuli,ind+1,chromosome{i},squeeze(response(i,:,:)), ...
		    fitness(i),generation);
  else % new should come at ind
    stimuli=insert_stimulus(stimuli,ind,chromosome{i},squeeze(response(i,:,:)), ...
		    fitness(i),generation);
  end
end


function stimuli=insert_stimulus(stimuli,n,chromosome,response,fitness, ...
		      generation)
if n>length(stimuli)
    stimuli(end+1).chromosome=chromosome;
    stimuli(end).response=response;
    stimuli(end).fitness=fitness;
    stimuli(end).generation=generation;
  else
    if ~isempty(n)
      stimuli(n+1:end+1)=stimuli(n:end);
    else
      n=1;
    end
    stimuli(n).chromosome=chromosome;
    stimuli(n).response=response;
    stimuli(n).fitness=fitness;
    stimuli(n).generation=generation;
  end
			   

