function newcca = remove(thecca,index)

%  REMOVE - removes stimuli from COMPOSE_CA stimulus object
%
%  NEWCCA = REMOVE(THECCA, INDEX)
%
%  Removes the stimulus at index INDEX from the list of stimuli
%  to be composed in the COMPOSE_CA stimulus THECCA.
%
%  See also: COMPOSE_CA, COMPOSE_CA/SET, COMPOSE_CA/GET,
%            COMPOSE_CA/NUMSTIMS
%

l = numStims(thecca);
if index<1|index>l,error('Error: index must be in 1..numStims.'); end;

 % to make sure we don't leave hanging window pointers, unload stims to be deleted
for i=1:length(index), thecca.stimlist{i} = unloadstim(thecca.stimlist{i}); end;

 % now do the removal
thecca.stimlist = thecca.stimlist(setdiff(1:l,index));
thecca.clutindex = thecca.clutindex(setdiff(1:l,index));

newcca = thecca;

