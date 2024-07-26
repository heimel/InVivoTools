function newcksds = reassignextractortypes(cksds)

cksds.extractor_list=struct('name',{},'ref',{},'extractor1','','extractor2','');
cksds.nameref_str = struct('name','','ref',0,'listofdirs',{});
cksds.dir_str     = struct('dirname','','listofnamerefs',{});
cksds.dir_list    = {};
nameref_list= struct('name',{},'ref',{}); % create empty

newcksds = update(cksds);

