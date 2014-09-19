function Stim = get(S, ind)

%  Part of the NewStim package
%
%  STIM = GET(STIMSCRIPT, INDEX)
%
%  Returns the stimulus at index INDEX, where INDEX runs from 1 to
%  NUMSTIMS(STIMSCRIPT).
%
%  One may additionally use
%
%  STIMS = GET(STIMSCRIPT)
%
%  which returns a cell array (aka a list) of the stims.
%
%  See also:  STIMSCRIPT, SETDISPLAYMETHOD, LIST, CELL

if nargin==2, index = ind; else, index = []; end;

l = numStims(S);

Stim = [];

if ~isempty(index),
	if (index>=1 & index <= l), Stim = S.Stims{index};
	else,
		error(['stimscript.Get(index): index out of bounds ' ...
			'(must be in [1..numStims]).']);
	end;
else,
	Stim = S.Stims;
end;

