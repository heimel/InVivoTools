function b = eq(x,y)

b = 0;
if strcmp('displaystruct',class(y)),
  g1=struct(x);g2=struct(y);
  b=(g1==g2);
end;
