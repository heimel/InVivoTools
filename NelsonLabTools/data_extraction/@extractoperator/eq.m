function b = eq(x,y)

b = 1;
if strcmp(class(x),class(y))~=1,
  b = 0;
else, 
  try,
    px = getparameters(x);
    py = getparameters(y);
  catch,
    px = 1; py = 2;
  end;
  b = (px==py);
end;

