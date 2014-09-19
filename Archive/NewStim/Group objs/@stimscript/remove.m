function S = remove(A, ind)

%  Part of the NewStim package
%
%  SCRIPT = REMOVE(SCRIPT, IND)
%
%  Removes the stimulus at index IND from the script.  It also adjust the
%  entries in the displayOrder field to reflect the change.
%
%  See also:  STIMSCRIPT, SETDISPLAYMETHOD, GETDISPLAYORDER, STIMSCRIPT/APPEND

l = numStims(A);
if ind<1|ind>l,error('Error: ind must be in 1..numStims.'); end;

if l==1, A.Stims = {}; A.displayOrder = []; A.StimTimes = [];
else,
	newStims = cell(1,l-1);

	[newStims{:}] = deal( (A.Stims{[1:ind-1 ind+1:l]}));
	A.Stims = newStims;
	ind2 = find(A.displayOrder~=ind);
	A.displayOrder = A.displayOrder(ind2);
	ind1 = find(A.displayOrder>ind);
	A.displayOrder(ind1)=A.displayOrder(ind1)-1;
	A.StimTimes = A.StimTimes([1:ind-1 ind+1:l]);
end;
S = A;
