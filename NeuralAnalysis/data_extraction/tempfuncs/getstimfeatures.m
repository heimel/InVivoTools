function f = getstimfeatures(v,st,p,x,y,rect)

pars = getparameters(st);
if isa(st,'stochasticgridstim'),
  values = pars.values;
elseif isa(st,'blinkingstim'),
  values = [pars.BG; pars.value];
end;
f = reshape(v,y,x,size(v,2));
ff = values(f,:);
f = reshape(ff,y,x,size(v,2),3);
if p.feature==3,
  f = cat(3,zeros(size(f(:,:,1,:))),f(:,:,2:end,:)-f(:,:,1:end-1,:));
end;
if p.feature==4,
  f = abs(cat(3,zeros(size(f(:,:,1,:))),f(:,:,2:end,:)-f(:,:,1:end-1,:)));
end;
