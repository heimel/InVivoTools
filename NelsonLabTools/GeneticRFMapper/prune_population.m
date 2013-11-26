function stimuli = prune_population( stimuli, generation, param)
%PRUNE_POPULATION removes all members who have reached maximum age
%
% stimuli = prune_population( stimuli, generation, param)
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if nargin<3
  param=genetic_defaults;
end

young=[];
for i=1:length(stimuli)
  if generation<stimuli(i).generation+param.max_age
    young = [young i];
  end
end

stimuli = stimuli(young);
