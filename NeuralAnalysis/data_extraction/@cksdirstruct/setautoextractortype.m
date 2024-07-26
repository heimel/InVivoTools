function newcksds = setautoextractortype(cksds,type,extractor1,extractor2)

ind2 = typefind(cksds.autoextractor_list,type);

if ind2>0,
	cksds.autoextractor_list(ind2).extractor1 = extractor1;
	cksds.autoextractor_list(ind2).extractor2 = extractor2;
else,
	cksds.autoextractor_list(end+1) = struct('type',type,...
		'extractor1',extractor1,'extractor2',extractor2);
end;

newcksds = cksds;
