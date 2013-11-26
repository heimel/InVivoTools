function chromosomes=create_population(N,param)
%CREATE_POPULATION creates population of stimulus chromosomes
%
%   CHROMOSOMES=CREATE_POPULATION(N,PARAM)
%     N  number of stimuli to generate
%     PARAM is struct with general parameters
%
%   if less input parameters are given, the default parameters
%   given by genetic_defaults are used and
%
%      N = 50
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if nargin<2
  param=genetic_defaults;
end

if nargin==0
  N=50;
end

for i=1:N
  chromosomes{i}=create_chromosome(param);
end