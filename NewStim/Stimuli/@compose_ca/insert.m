function ncca = insert(thecca, stim, ind)

% INSERT - Insert a stim into COMPOSE_CA 
%
%  NEWCCA = INSERT(THECCA, STIMULUS, INDEX)
%
%  Inserts the stim STIMULUS into the list of stimuli to be
%  composed after the location INDEX.  Note that 0 is a valid
%  INDEX and this means the stimulus will be inserted at the
%  first location.
%
%  The inserted stimulus will have a clut index number of 1.
%  One may use SETCLUTINDEX to change this value.
%
%  See also:  COMPOSE_CA, COMPOSE_CA/SET, COMPOSE_CA/GET
%   COMPOSE_CA/NUMSTIMS, COMPOSE_CA/REMOVE
% 

l = numStims(thecca);

if ind<0|ind>l, error(['INDEX must be in 0..numStims.']); end;

if isa(stim,'stimulus'),
	thecca.stimlist = cat(2,thecca.stimlist(1:ind),{stim},thecca.stimlist(ind+1:end));
	thecca.clutindex = cat(2,thecca.clutindex(1:ind),1,thecca.clutindex(ind+1:end));
else, error(['Stimulus must be of class ''stimulus'' .']);
end;

ncca = thecca;
