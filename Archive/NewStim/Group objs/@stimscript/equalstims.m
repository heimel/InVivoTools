function b = equalstims(x,y)

%  STIMSCRIPT/EQUALSTIMS - Returns 1 iff two stimscript's stims are same
%
%  B = EQUALSTIMS(X,Y)
%
%  Returns 1 iff two stimscript objects have the same stims, and zero otherwise.
%  Two scripts are the same if they have the same stimuli with the same
%  parameters but not necessarily the same display order.

b = 0;
if (~isa(x,'stimscript'))|(~isa(y,'stimscript')), return; end;
nx = numStims(x); ny = numStims(y);
if (nx==ny),
  b = 1;
  for i=1:nx,
     b = b&(get(x,i)==get(y,i));
  end;
end;
