function A = unloadStimScript(S);

for i=1:numStims(S),
	S.Stims{i} = unloadstim(S.Stims{i});
end;

A = S;
