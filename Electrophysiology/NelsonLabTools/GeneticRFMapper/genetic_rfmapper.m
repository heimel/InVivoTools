function [stimuli, fithis]=genetic_rfmapper(param,display)
%GENETIC_RFMAPPER runs genetic algorithm to find a cell's optimal stimulus
%
%  [STIMULI, FITHIS]=GENETIC_RFMAPPER(param,display)
%
%  [STIMULI, FITHIS]=GENETIC_RFMAPPER
%      uses PARAM=GENETIC_DEFAULTS 
%      DISPLAY, set to 1 to plot optimal stimuli
% 
%     returns
%      STIMULI, best stimuli, with chrosomes, responses 
%      and fitness
%      FITHIS, history of highest fitness per generation
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%


verbose=1;

if nargin<2
  display=1;
end
  
if nargin<1
  param=genetic_defaults;
end

cksds = getcksds;
if isempty(cksds), 
  errordlg(['No existing data---make sure you hit '...
	    'return after directory in RunExperiment window']);
  return;
end; 

cellname = getcellname(cksds);
if isempty(cellname)
  errordlg('Could not get a cellname.');
  return
end

fid=fopen(['/home/data/logs/genetic_rfmapper-' date '.log'],'a');
fprintf(fid,'#gen.  test.  fitness\n');


if display
  clipfigure=figure;
  fitfigure=figure;
  fithisfigure=figure;
end


stimuli(1)=struct('chromosome',[],'response',[],'fitness',[],'generation',0);
stimuli(1)=[];
for generation=1:param.max_n_generations
  if generation==1
    if verbose;disp('Creating population');end
    chromosomes = create_population( param.N, param);
  else
    parents=floor(linspace(1,param.n_parents,param.N));
    if verbose;disp('Procreating');end
    chromosomes = procreate( stimuli(parents), param );
  end
  
  [responses,testname]=measure_responses(chromosomes,cksds,cellname,param,verbose);

  if verbose;disp('Computing fitnesses');end
  fitnesses = compute_fitness( responses );

  [value, ind]=max(fitnesses); 
  disp(['Generation = ' num2str(generation) ', Max fitness = ' ...
	num2str(value)]);
  
  if verbose;disp('Inserting into population');end
  if (param.n_survive==0) | (generation==1) 
    keep=[];
  else
    keep=(1:min(param.n_survive,length(stimuli)) );
  end
  stimuli = insert_in_population( stimuli(keep), chromosomes, responses, ...
				  fitnesses, generation)

  disp(['Overall max. fitness = ' num2str(stimuli(1).fitness) ...
       ' from response: ' mat2str(stimuli(1).response,3) ])

  fithis(generation)=stimuli(1).fitness;

  if display
    figure(fitfigure);
    plot(fithis);
    plot_fitness(stimuli,fithisfigure);
    if stimuli(1).generation==generation % new highest fitness
      plot_chromosome(stimuli(1).chromosome,param,clipfigure);
    end
  end
  

  
  if generation>param.min_n_generations 
    if fithis(generation)<=fithis(max(1, generation-5))
      break; % not converging anymore
    end
  end

  % kill all that are older than max_age
  stimuli=prune_population(stimuli,generation,param);
  
  q=input('Type q to quit','s');
  if strcmp(q,'q')
    break;
  end



  fprintf(fid,'%d  %s %f\n', generation, testname,stimuli(1).fitness );

end

fclose(fid);

if display
  plot_chromosome(stimuli(1).chromosome,param,clipfigure);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBROUTINES 
  
