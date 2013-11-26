function A = append(S, stim)

if isa(stim,'stimulus'),

	l = numStims(S);

	S.Stims{l+1} = stim;
	S.displayOrder = [ S.displayOrder l+1];
	S.StimTimes(l+1) = stimTime(stim);
	
else,
	error('Error in stimscript.append(S, stim):  ''stim'' must be a stimulus object.');
end;

A = S;
