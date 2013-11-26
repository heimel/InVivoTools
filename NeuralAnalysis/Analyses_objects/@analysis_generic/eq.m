function c = eq(a,b)

%  Part of the NeuralAnalysis package:
%
%  == Equal, C = EQ(A,B)
%
%  Returns in C either 1 or 0 depending upon whether or not the two 
%  ANALYSIS_GENERIC objects A and B are equal.  This determination is made by
%  looking at the WHERE field.  If both where fields are empty, then the
%  determination is made by looking at at the contextmenu handle fields.

c = 0;  if ~isa(b,'analysis_generic'), return; end;
awhere = location(a); bwhere = location(b);
if ~isempty(awhere),
	if isempty(bwhere), c=0;
	else,
		c=strcmp(awhere.units,bwhere.units)&...
				prod(double(awhere.rect==bwhere.rect))&...
				awhere.figure==bwhere.figure;
	end;
elseif ~isempty(bwhere), c = 0;
else, % both empty
	c=a.contextmenu==b.contextmenu;
end;
