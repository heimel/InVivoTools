function geneticstimuli()
%GENETICSTIMULI provides general help on genetic algorithm for receptive field mapping
%
% Genetic Algorithm for Receptive Field Mapping
%
% To create a new population:
%   chromosomes = create_population( N, param )
%
% To create single chromosome:
%   chromosome = create_chromosome( param )
%
% To create offspring:
%   chromosomes = procreate( stimuli, param )
%
% To create pseudoclips (device independent movieclips)
%   clips = create_pseudoclips( chromosomes, param )
% 
% To generate a neuron kernel
%    kernel=neuronkernel( window, duration, neuron )
%
% To simulate response of a neuron to clips
%   response=simulate_response(clips,kernel,nonlinearity
%
% To calculate fitness from response
%   fitness=compute_fitness(response)
%
% To create movie from a pseudoclip
%   mov = clip2movie( clip, scale )
%
% To insert evaluated chromosome(s) into stimulus population
%   stimuli = insert_in_population( oldstimuli, chromosome, ...
%                              response, fitness, generation )
% 
% To run simulation
%   [stimuli, mov, fithis]=genetic_simulation(kernel, N, ...
%            max_n_generations,display,param)
%
% To run real experiment
%   [stimuli, fithis]=genetic_rfmapper(param)
%   
% To minimize optimal stimulus
%   minimal_stimulus = minimize_stimulus( stimulus, param )
%
% To simulate minimizing the optimal stimulus
%   [stimuli]=minimize_simulation(stimuli,kernel,param)
%
% To import population of genetic stimuli from a previous experiment
%   [stimuli,param] = import_population( generation, path, testname, cellname)
% 
%
%
% See HELP GENETIC_DEFAULTS for explanation on use and defaults of parameters
%
%   2003, Alexander Heimel (heimel@brandeis.edu)
%
disp('Type `help geneticstimuli');
