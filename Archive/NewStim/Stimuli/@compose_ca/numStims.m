function n = numStims(cca)


%  NUMSTIMS - Number of stims in list of a COMPOSE_CA stim object
%
%  N = NUMSTIMS(THECCA)
% 
%  Returns number of stims in the list of stimuli to be composed in a 
%  COMPOSE_CA object THECCA.
%
%  See also:  COMPOSE_CA, COMPOSE_CA/SET, COMPOSE_CA/GET,
%  COMPOSE_CA/REMOVE, COMPOSE_CA/APPEND

n = length(cca.stimlist);
