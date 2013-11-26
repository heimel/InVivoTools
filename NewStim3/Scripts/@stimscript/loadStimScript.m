function A = loadStimScript(S);

for i=1:numStims(S),
	if ~isloaded(S.Stims{i}),
		S.Stims{i} = loadstim(S.Stims{i});
	end;
end;

A = S;
