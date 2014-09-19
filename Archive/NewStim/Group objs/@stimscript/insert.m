function A = insert(S, stim, index)

l = numStims(S);

if (index>0 & index<=l & isa(stim,'stimulus')),
	S.Stims = { Stims{1:index} stim Stims{index+1:l} };
	S.StimTimes = [ S.StimTimes(1:index) stimTime(stim) S.StimTimes(index+1:l)];
	S.displayOrder = [ S.displayOrder(1:index) l+1 S.displayOrder(index+1:l))];
else,
	error('Error in set(S,stim,index): ''stim'' must be a stimulus + index must be in [1..numStims+1].');
end;

A = S;
