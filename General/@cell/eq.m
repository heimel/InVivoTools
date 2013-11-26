function b = eq(x,y)
  % does element by element comparison
b = 0;
if iscell(y),
 sz1=size(x); sz2=size(y);
 if prod(double(sz1==sz2)),
     b=1; for i=1:prod(sz1), if ~eqlen(x{i},y{i}), b=0; break; end; end;
 end;
end;
