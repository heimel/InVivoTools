function [extractor1,extractor2] = getextractors(cksds,name,ref)

ind=namerefind(cksds.extractor_list,name,ref);
if ind>0,
	extractor1=cksds.extractor_list(ind).extractor1;
	extractor2=cksds.extractor_list(ind).extractor2;
else,
	error('Could not find name/ref');
end;
