function res = opp(x,y)
  s = size(x);
  s = s(1,2);
  tot = 0;
  for i = (2:1:s)
    tot = tot + abs(.5*(x(i)-x(i-1))*(y(i)-y(i-1)));
    tot = tot + (x(i)-x(i-1))*min([y(i) y(i-1)]);
  end
  res = tot;
end

