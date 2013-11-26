function newcksds = setextractortype(cksds,name,ref,extractor1,extractor2)

ind2 = namerefind(cksds.extractor_list,name,ref);

if ind2>0,
	cksds.extractor_list(ind2).extractor1 = extractor1;
	cksds.extractor_list(ind2).extractor2 = extractor2;
else,
	warning(['Could not find name/ref pair in ' inputname(cksds) '.']);
end;

newcksds = cksds;
