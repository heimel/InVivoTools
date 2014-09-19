function newcca = set(thecca, stim, index)

%  SET- Sets stimulus value in COMPOSE_CA object
%
%  NEWCCA = SET(THECCA,STIMULUS,INDEX)
%
%  Sets the stimulus in the list of stimuli to be
%  composed at index INDEX to be STIMULUS.
%
%  The clut index number for that stimulus position is not
%  changed or is set to 1 in the case of an additional
%  stimulus.  Use SETCLUTINDEX to change this value.
%
%  See also:  COMPOSE_CA, COMPOSE_CA/GET, COMPOSE_CA/REMOVE
%             COMPOSE_CA/NUMSTIMS, COMPOSE_CA/INSERT
%

newcca = thecca;

if index > (1+numStims(newcca)),
	error(['INDEX must be in 1..numStims+1.]);
end;

if isa(stim,'stimulus'),
	newcca.stimlist = cat(2,newcca.stimlist(1:index-1),{stim},newcca.stimlist(index+1:end));
	if length(newcca.clutindex)<length(newcca.stimlist), newcca.clutindex(index) = 1; end;
else, error(['STIMULUS must be an object of class ''stimulus''.']);
end;
