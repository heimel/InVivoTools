function b = eqlen(x,y)

%  EQLEN  Returns 1 if objects to compare are equal and have same size
%  
%    B = EQLEN(X,Y)
%
%  Returns 1 iff X and Y have the same length and all of the entries in X and
%  Y are the same.
%
%  Examples:  EQLEN([1],[1 1])=0, whereas [1]==[1 1]=[1 1], EQTOT([1],[1 1])=1
%             EQLEN([1 1],[1 1])=1
%             EQLEN([],[]) = 1
%
%  See also:  EQTOT, EQEMP, EQ

if sizeeq(x,y), b = eqtot(x,y); else, b = 0; end;

