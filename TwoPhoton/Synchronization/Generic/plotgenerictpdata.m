function plotgenerictpdata(cells,cellnames,dir2plot)

for i=1:length(cells),
	A = findassociate(cells{i},'unlabeled resp raw','','');
	B = findassociate(cells{i},'unlabeled test','','');
	[dummy,ia] = intersect(B.data,dir2plot);
	if ~isempty(ia),
		data = A.data{ia};
		figure;
		plot(data.t,data.data,'k');
		ylabel('F'); xlabel('time (s)'); title([dir2plot ', ' cellnames{i}],'interp','none');
	end;
end;
