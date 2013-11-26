function param=genetic_defaults()
%GENETIC_DEFAULTS returns default parameters for population
%
%  PARAM=GENETIC_DEFAULTS()
%
%  param.duration        length of stimulus (virtual frames)
%  param.window          [width height] of stimulus (virtual pxls)
%  param.types           cell-list of genetypes to use
%  param.colors          cell-list of [R G B] colors to use
%  param.sizelimits      upper and lower raidus in virtual pixels
%  param.speedlimits     [speedxlimit speedylimit]
%  param.contrastlimits  [lowest contrast highestcontrast]
%  param.eccentricitylimits  [min max] eccentricity
%  param.n_deletes       number of genes to delete
%  param.n_creations     number of genes to create
%  param.mutationrate    fraction of genes to mutate
%  param.background      background of movie clips
%  param.min_n_genes     minimum number of genes per chromosome
%  param.max_n_genes     maximum number of genes per chromosome
%  param.shrinkingforce  number of vpixels to take away each generation
%  param.time_per_frame  time to show one virtual frame (ms)
%  param.isi             interval between frames (s)
%  param.n_parents       number of parents to pick and produce offspring
%  param.n_survive       number of chromosome to survive from one  generation
%  param.N               number of offspring to produce 
%  param.max_n_generations  maximal number of generations to run
%  param.min_n_generations  minimal number of generations to run
%  param.scale           (int) windowsize (pixels) / param.window (vpixels)
%  param.repeats         number of times stimulus sequence is shown
%  param.bins            bin edges in second to quantify response
%  param.fitness_variation  between (0,1) deviation of responses
%                            to still call them identical
%  param.BGpretime       time (in seconds) between repeats
%
%  Type 'genetic_defaults' to see default values
%
%  GENERAL CONSIDERATIONS
%
%  If one keeps more members (N_SURVIVE) from a generation to generation, 
%  this will increase initial convergence rate, but will counteract 
%  the shrinking forces (SHRINKINGFORCE and N_DELETES) and looking 
%  for a `minimal' optimal stimulus.
%
%  Using smaller stimulus elements (set by SIZELIMITS) will more 
%  closely approximate the real receptive field, but the initial 
%  convergence might slow down, because neuron is driven less
%  effectively
%  
%  Using smaller ISI will speed up stimulus showing, but responses
%  may start to interfere, because of adaptation or late responses.
%
%  
%
%   2003, Alexander Heimel (heimel@brandeis.edu)
%

squirrelcolor

param.types=[3];  % 1=disk, 2=gaussian, and  3=oval, later rectangle
param.window=[50 50];  %[width height] virtual pixels  
param.duration=4;      %virtual frames
param.colors = { squirrel_white, [0; 0; 0] };
param.sizelimits = [3 6] ;  % upper and lower radius in virtual pixels
param.contrastlimits = [1 1];
param.speedlimits = [8 8];
param.eccentricitylimits = [0.5 5];
param.n_deletes = 1;
param.n_creations = 1;
param.mutationrate = 1;
param.background = round(squirrel_white/2);
param.nocrossover = 0;
param.min_n_genes = 3;
param.max_n_genes = round(sqrt(param.window(1)*param.window(2))/param.sizelimits(2));
param.shrinkingforce = 0;
param.time_per_frame = 100; 
param.isi = 0.5;
param.n_survive = 100; 
param.max_age = 3;
param.N=15;
param.n_parents = 3; %min(2,round(param.N/10));
param.max_n_generations=15;
param.min_n_generations=3;
param.scale=6;
param.repeats=4;
param.bins=linspace( 0.000, (param.duration*param.time_per_frame+100)/1000,...
		     10);
param.fitness_variation=0.05;
param.BGpretime=8.0;
