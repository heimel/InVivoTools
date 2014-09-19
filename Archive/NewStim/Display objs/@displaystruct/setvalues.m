function ds = setvalues(displaystruct, parameters);

[good, errormsg] = verify(parameters);

if good,
	for i=1:2:length(parameters),
		eval(['displaystruct.' parameters{i} ' = parameters{i+1};']);
	end;
else, error(['Could not update displaystruct: ' errormsg]);
end;

ds = displaystruct;
