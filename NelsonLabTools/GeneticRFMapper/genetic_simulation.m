function [stimuli, mov, fithis]=genetic_simulation(kernel,display,param)
%GENETIC_SIMULATION runs simulation of genetic algorithm 
%
%  [STIMULI, MOV, FITHIS]=GENETIC_SIMULATION(KERNEL, DISPLAY, PARAM)
%
%      DISPLAY            1 show graphs, 0 don't show graphs
%
%  [STIMULI, MOV, FITHIS]=GENETIC_SIMULATION()
%      uses default values
%      DISPLAY = 1
%      PARAM = GENETIC_DEFAULTS
%
%
%     returns
%      STIMULI, all constructed stimuli with chromosome, response
%      and fitness
%      MOV, movie of best stimulus
%      FITHIS, history of highest fitness per generation
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

%nonlinearity='thresholdlinear';
nonlinearity='poissonfiring';

verbose=0;

if nargin<3
  param=genetic_defaults;
end
if nargin<2
  display=1;
end
if nargin<1
  kernel=neuronkernel(param.window, param.duration);
end

% some checks on the parameters
if param.n_parents>param.N
  param.n_parents=param.N;
end


[maxfit,maxstddev]=compute_maximal_fitness(kernel,nonlinearity);
text=sprintf('Maximal possible fitness with %s : %f (stddev =%f)\n',...
	     nonlinearity,maxfit,maxstddev);
disp(text);

kernelclip=kernel2clip(kernel);
kernelclip=kernel2clip(kernel);
kernelmovie=clip2movie( kernelclip, 5);
if display
  plot_clip(kernelclip);
  clipfigure=figure;
  fitnessfigure=figure;
  
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
  if verbose;disp('Simulating response');end
  responses = simulate_response(chromosomes,kernel,nonlinearity,param );
  if verbose;disp('Computing fitness');end
  fitnesses = compute_fitness( responses );
  
  [value, ind]=max(fitnesses);
  
  if display 
    pause(.2) % give time to draw
  end
  
  disp(['Generation = ' num2str(generation) ', Max fitness = ' ...
	num2str(value)]);

  if verbose;disp('Inserting into population');end
  if generation==1
    stimuli = insert_in_population( stimuli, chromosomes, responses, ...
				    fitnesses, generation);
  else   
    if param.n_survive==0
      keep=[];
    else
      keep=(1:min(param.n_survive,length(stimuli)) );
    end
    stimuli = insert_in_population( stimuli(keep), chromosomes, responses, ...
				    fitnesses, generation);

    % idea not to loose maximum, but give shrunken stimuli a chance
    % that they wouldn't get if full set was kept
    %
    % initial convergence seems to go quicker if best stimuli are
    % kept, but later on they hinder the abstraction of the optimal
    % stimulus
    % best scheme seems a cross over to not keeping old stimuli
  end    

  if stimuli(1).generation==generation % new optimum
    clip = create_pseudoclips( {stimuli(1).chromosome}, param );
    sclip=smooth_clip(clip{1});
    if display
      plot_clip(sclip,clipfigure);
    end
  end

  
  disp(['Overall max. fitness = ' num2str(stimuli(1).fitness) ...
       ' from response: ' mat2str(stimuli(1).response,3) ])

  disp(['Stimulus time elapsed: ' num2str( generation*param.N*param.repeats*...
				  (param.duration*param.time_per_frame...
				   /1000 +param.isi )) ...
	' s']);
  %for i=1:10
  %  disp([num2str(i) ': ' num2str(stimuli(i).fitness)])
  %end
  fithis(generation)=stimuli(1).fitness;
  
  if display
    plot_fitness(stimuli,fitnessfigure);
  end

  % kill all that are older than max_age
  stimuli=prune_population(stimuli,generation, param); 
  
end

clip = create_pseudoclips( {stimuli(1).chromosome}, param );
mov = clip2movie( clip{1}, 10 );
sclip=smooth_clip(clip{1});
if display
  plot_clip(sclip,clipfigure);
end
