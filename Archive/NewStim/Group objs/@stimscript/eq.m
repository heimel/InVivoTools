function b = eq(x,y)

%  STIMSCRIPT/EQ - Returns 1 iff two stimscript objects are the same
%
%  B = EQ(X,Y)
%
%  Returns 1 iff two stimscript objects are the same, and zero otherwise.
%  Two scripts are the same if they have the same stimuli with the same
%  parameters and the same display order.

b = 0;
if (~isa(x,'stimscript'))|(~isa(y,'stimscript')), return; end;
dox = getDisplayOrder(x); doy = getDisplayOrder(y); 
nx = numStims(x); ny = numStims(y);
if eqlen(dox,doy)&(nx==ny),
  b = 1;
  for i=1:nx,
     b = b&(get(x,i)==get(y,i));
  end;
end;
