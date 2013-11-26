function [ output_args ] = xl(mx)

for i=1:size(mx,1)
  s = '';
  for j = 1:size(mx,2)
    m = mx(i,j);
    if (~isnan(m)) s = [s num2str(m)]; end
    if (j<size(mx,2)) s=[s 9];  end
  end
  disp(s);
end
    
