function c = plus(a,b)

%  STIMSCRIPT/PLUS Add two stimscripts
%
%  C = PLUS(A,B)
%
%  'Adds' the stimscripts A and B.  This involves adding all of the stimuli
%  in B to A, and setting the display order such that the stimulus
%  presentation would be the same as if A were displayed and then B.
% 
%  See also:  SETDISPLAYMETHOD

na = numStims(a);
nb = numStims(b);
doa= getDisplayOrder(a);
dob= getDisplayOrder(b);
dob = dob + na;

c = a;
for i=1:nb, c = append(c,get(b,i)); end;
c = setDisplayMethod(c,2,[doa dob]);
