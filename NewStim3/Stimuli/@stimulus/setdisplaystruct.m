function [stimout] = setdisplaystruct(stimulus, displaystruct);

  % this is a work around since children cannot access fields of parents (grrr)

  if isa(displaystruct, 'displaystruct')|isempty(displaystruct),
	  stimulus.displaystruct = displaystruct;
  else, error('Cannot set displayprefs to non-displayprefs object.');
end;

stimout = stimulus;
