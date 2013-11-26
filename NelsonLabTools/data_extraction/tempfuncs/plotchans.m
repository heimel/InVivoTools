function plotchans(csp,cl,lim,plotcmd,bnd);

L = size(csp,1)/4;
p = 1;
for i=1:length(cl),
  for n=1:4,
	subplot(length(cl),4,p); p = p + 1;
	plot(csp( (n-1)*L+1:n*L,cl(i).idx(1:lim:end)), plotcmd);
	if ~isempty(bnd),axis(bnd);end;
  end;
end;
