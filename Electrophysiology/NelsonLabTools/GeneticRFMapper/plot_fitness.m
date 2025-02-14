function fig=plot_fitness( stimuli, fig)
%PLOT_FITNESS plots fitness histogram of a population
%
%  plot_fitness( stimuli, fig)
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel (heimel@brandeis.edu)
%
 
if nargin<2
  fig=figure;
else
  figure(fig);
end


for i=1:length(stimuli)
  fitness(i)=stimuli(i).fitness; 
end

[n,x]=hist(fitness,10);
bar(x,n);
