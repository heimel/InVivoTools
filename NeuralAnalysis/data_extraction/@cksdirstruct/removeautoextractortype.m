function newcksds = removeautoextractortype(cksds,type)

l = length(cksds.autoextractor_list);
ind = typefind(cksds.autoextractor_list,type);

if ind>0,
	cksds.autoextractor_list=cksds.autoextractor_list([1:ind-1 ind+1:l]);
end;

newcksds = cksds;
