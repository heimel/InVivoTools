function [stimout] = setdisplayprefs(stimulus, displayprefs);

  % this is a work around since children cannot access fields of parents (grrr)

  if isa(displayprefs, 'displayprefs')|isempty(displayprefs),
	  stimulus.displayprefs = displayprefs;
  else, error('Cannot set displayprefs to non-displayprefs object.');
end;

stimout = stimulus;
