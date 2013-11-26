function A = set(S, stim, index)

l = numStims(S);

if (index>=1 & index<=l+1 & isa(stim,'stimulus'))
	S.Stims{index} = stim;
	S.StimTimes(index) = stimTime(stim);
else,
	error('Error in set(S,stim,index): ''stim'' must be a stimulus + index must be in [1..numStims+1].');
end;

A = S;
