function [fitness, stddev]=compute_maximal_fitness( kernel, nonlinearity )
%COMPUTE_MAXIMAL_FITNESS computes maximal fitness for a given kernel
%
%  [FITNESS, STDDEV]=COMPUTE_MAXIMAL_FITNESS( KERNEL, NONLINEARITY )
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if nargin<2
  nonlinearity='poissonfiring';
end

optimal=sign(kernel);
conv=optimal(:)'*kernel(:);
response=feval(nonlinearity,conv*ones(1,400));
fit=compute_fitness(response');
fitness=mean(fit);
stddev=std(fit);
