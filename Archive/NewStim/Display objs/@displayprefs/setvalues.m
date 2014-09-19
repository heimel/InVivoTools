function df = setvalues(displayPrefs, parameters);

[good, errormsg] = verify(parameters);

if good,
	for i=1:2:length(parameters),
		eval(['displayPrefs.' parameters{i} ' = parameters{i+1};']);
	end;
else, error(['Could not update displayprefs: ' errormsg]);
end;
df = displayPrefs;
