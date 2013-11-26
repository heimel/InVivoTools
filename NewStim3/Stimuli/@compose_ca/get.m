function stim = get(thecca,ind)

% GET - Get stimulus to be composed in COMPOSE_CA stimulus
%
%  [STIM,CLUTIND] = GET(THECCA, [INDEX])
%
%  Returns stimulus at index INDEX from the list to be composed
%  in a COMPOSE_CA stimulus.  If INDEX is not present or is empty,
%  then the entire list is returned as a cell list of stimuli.
%
%  The clut index number for each stimulus in STIM is returned
%  in the array CLUTIND.
%
%  Use NUMSTIMS to read the number of stims in the list.
%
%  See also:  COMPOSE_CA, COMPOSE_CA/SET, COMPOSE_CA/APPEND
%             COMPOSE_CA/NUMSTIMS

if nargin==2, index = ind; else, index = []; end;

l = numStims(thecca);

stim = [];

if ~isempty(index),
	if index>=1&index<=l, stim = thecca.stimlist{index};
	else, error('Stimulus index out of bounds, must be in [1..numStims].');
	end;
else, stim = thecca.stimlist;
end;
