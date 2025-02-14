function [param, fitness, stimuli] = meta_simulate( kernel, ranges, number, ...
					   max_n_presentations,defparam)
%META_SIMULATE finds optimal parameters for genetic algorithm to evolve solution
%
%  [PARAM, FITNESS] = META_SIMULATE( KERNEL, RANGES, NUMBER, ...
%                         MAX_N_PRESENTATIONS, DEFPARAM)
%
%     e.g. RANGES=struct('n_deletes',[1 2 3],'repeats',[1 3 5])
%
%     META_SIMULATE randomly picks NUMBER parameter settings and performs
%     genetic_simulation with these parameters. 
%     Output [PARAM, FITNESS, STIMULI] is sorted for fitness in 
%     descending order. STIMULI contains the best stimulus of each
%     parameter set.
%
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%
  
if nargin<5
  defparam=genetic_defaults;
end
if nargin<4
  max_n_presentations=30*60; % half an hour if each presentation takes a second
end
if nargin<3
  number=5;
end
if nargin<2
  ranges=struct(...%'mutationrate',{{0.8}},...
		'max_n_genes',{{10 30}},...
		'min_n_genes',{{3 10}},...
		'n_parents',{{1 4 10}},...
		...%'N',{{20}},...
		'repeats',{{2 8 16}}...
		);
end
if nargin<1
  kernel=gaborkernel;
end


% create sets of parameters
fields=fieldnames(ranges);
for i=1:number
  param(i)=defparam;
  
  for j=1:length(fields)
    options=getfield(ranges,fields{j})
    rndnr=ceil( rand(1) * length(options ))
    options(rndnr)
    fields{j}
    param(i)=setfield(param(i),fields{j},options{rndnr})
  end
  param(i).max_n_generations=round( max_n_presentations/param(i).repeats ...
				    / param(i).N );
end

  
% run simulations
figure; hold on;
colors='bkrgy';

for i=1:number
  disp(['PARAMETER SET ' num2str(i)]);
  [stims,mov,fithis]=genetic_simulation(kernel,0,param(i));

  p=param(i);
  p.repeats=20; % TO GET MORE ACCURATE MEASUREMENT
  response=simulate_response( {stims(1).chromosome},gaborkernel,...
			      'poissonfiring',p);
  stimuli(i)=stims(1);
  fitness(i)=compute_fitness(response);
  fithis(end+1)=fitness(i);
  plot(fithis,colors(mod(i,5)+1));
  pause(0.1); % to give time to draw
end





% sort in descending order of fitness  
[x, ind]=sort(-fitness);
fitness=fitness(ind);
param=param(ind);
stimuli=stimuli(ind);



% report
for i=1:number
  x=sprintf('Fitness: %3.2f ',fitness(i));
  for j=1:length(fields)
    x=[x sprintf('%s=%s ',fields{j},mat2str(getfield(param(i),fields{j}) ))];
  end
  disp(x);
end

