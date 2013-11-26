function hilite_rast(hr, rast, trials, plotcode);

	xx = []; yy = [];
for i=1:length(trials),
	zz = find(rast(2,:)==trials(i));
        xx = [ xx  rast(1,zz) ];
        yy = [ yy  rast(2,zz) ];
end;

if length(xx)>0,
	axes(hr);
	hold on;
	plot(xx,yy,plotcode,'MarkerSize',20);
end;
