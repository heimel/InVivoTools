function fitness=compute_fitness(response)
%COMPUTE_FITNESS computes fitness given a response
%
%  FITNESS=COMPUTE_FITNESS(RESPONSE)
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%

if size(response,2)==1  % if only one column
  fitness=response;
else
  %fitness=max(response')';
  if ndims(response)==2
    fitness=sum(response,2);
  else
    fitness=sum(sum(response,3),2);
    fitness=fitness/size(response,3);
  end
end
