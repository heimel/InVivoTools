function [newcksds,status] = extract(cksds,instruc)
%
%  [NEWDS,STATUS]=EXTRACT(THEDS,INSTRUC)
%
%  Perform extraction operation on the data described in the directories
%  associated with the DIRSTRUCT THEDS according to instructions
%  given in INSTRUC.
%
%  INSTRUC has the following fields:
%     extractincompletedir (0 or 1)      : 1 means will attempt to extract data
%                                        :   from directory where data is still
%                                        :   coming in
%
%  STATUS is one of -1 (error), 0 (no error but not operation not complete)
%  1 (operation complete).
%
%  See also:  DIRSTRUCT, INSTRUC

% set-up

list = 1:length(cksds.nameref_list);
newlist = 1:length(cksds.nameref_list);
while ~isempty(newlist),
list = newlist; newlist = [];
  for i=list,
   [ext1str,ext2str] = getextractors(cksds,cksds.nameref_list(i).name,...
			cksds.nameref_list(i).ref);
   if ~isempty(ext1str),
	try, ex1 = evalin('base',ext1str);
	catch, error(['Could not find extractor ' ext1str '.']);end;
	[ex1,status]=setupextract(ex1,cksds.nameref_list(i),cksds,instruc);
	if status<0,error(['Error in setup; extractor: ' ...
		ext1str ', nameref: ' cksds.nameref_list(i).name ',' ...
		int2str(cksds.nameref_list(i).ref) '.']);
        elseif status==0&instruc.extractincompletedir, newlist = [newlist i]; end;
	assignin('base',ext1str,ex1);
   end;
  end; if ~isempty(newlist), dowait(5); end;
end;

% perform extraction

list = 1:length(cksds.dir_str);
newlist = 1:length(cksds.dir_str);
while ~isempty(newlist),
list = newlist; newlist = [];
 for i=list,
  if isactive(cksds,cksds.dir_str(i).dirname),
   acqinfo = loadStructArray([cksds.pathname cksds.dir_str(i).dirname ...
		filesep 'acqParams_out']);
   for j=1:length(cksds.dir_str(i).listofnamerefs),
    nameref=cksds.dir_str(i).listofnamerefs(j);
    z = namerefind(acqinfo,nameref.name,nameref.ref);
    if z<0, error(['Could not find name/ref ' nameref.name ':' ...
     int2str(nameref.ref) ' in directory ' cksds.dir_str(i).dirname '.']); end;
    [ext1str,ext2str] = getextractors(cksds,nameref.name,nameref.ref);
    if ~isempty(ext1str),
	try, ex1 = evalin('base',ext1str);
	catch, error(['Could not find extractor ' ext1str '.']);end;
	[ex1,status]=extractdir(ex1,cksds.dir_str(i).dirname,acqinfo(z),...
		cksds,instruc);
	if status<0,error(['Error in extraction; extractor: ' ...
		ext1str ', nameref: ' cksds.nameref_list(i).name ',' ...
		int2str(cksds.nameref_list(i).ref) ' in directory ' ...
		cksds.dir_str.dirname '.']);
	elseif status==0&instruc.extractincompletedir, newlist = [newlist i]; end;
	assignin('base',ext1str,ex1);
    end;
   end;
  end;
 end; if ~isempty(newlist), dowait(5); end;
end;
  

% cleanup
list = 1:length(cksds.nameref_list);
newlist = 1:length(cksds.nameref_list);
while ~isempty(newlist),
list = newlist; newlist = [];
  for i=list,
   [ext1str,ext2str] = getextractors(cksds,cksds.nameref_list(i).name,...
			cksds.nameref_list(i).ref);
   if ~isempty(ext1str),
	try, ex1 = evalin('base',ext1str);
	catch, error(['Could not find extractor ' ext1str '.']);end;
	[ex1,status]=cleanupextract(ex1,cksds.nameref_list(i),cksds,instruc);
	if status<0,error(['Error in cleanup; extractor: ' ...
		ext1str ', nameref: ' cksds.nameref_list(i).name ',' ...
		int2str(cksds.nameref_list(i).ref) '.']);
	elseif status==0&instruc.extractincompletedir, newlist = [newlist i]; end;
	assignin('base',ext1str,ex1);
   end;
  end; if ~isempty(newlist), dowait(5); end;
end;

% secondaryextractors

list = 1:length(cksds.nameref_list);
newlist = 1:length(cksds.nameref_list);
while ~isempty(newlist),
list = newlist; newlist = [];
  for i=list,
   [ext1str,ext2str] = getextractors(cksds,cksds.nameref_list(i).name,...
			cksds.nameref_list(i).ref);
   if ~isempty(ext2str),
	try, ex1 = evalin('base',ext1str);ex2 = evalin('base',ext2str);
	catch, error(['Could not find extractor ' ext2str '.']);end;
	[ex2,status]=setupextract(ex2,ex1,cksds.nameref_list(i),cksds,instruc);
	if status<0,error(['Error in setup; extractor: ' ...
		ext2str ', nameref: ' cksds.nameref_list(i).name ',' ...
		int2str(cksds.nameref_list(i).ref) '.']);
        elseif status==0&instruc.extractincompletedir, newlist = [newlist i]; end;
	assignin('base',ext2str,ex2);
   end;
  end; if ~isempty(newlist), dowait(5); end;
end;

% perform extraction

list = 1:length(cksds.dir_str);
newlist = 1:length(cksds.dir_str);
while ~isempty(newlist),
list = newlist; newlist = [];
 for i=list,
  if isactive(cksds,cksds.dir_str(i).dirname),
   acqinfo = loadStructArray([cksds.pathname cksds.dir_str(i).dirname ...
		filesep 'acqParams_out']);
   for j=1:length(cksds.dir_str(i).listofnamerefs),
    nameref=cksds.dir_str(i).listofnamerefs(j);
    z = namerefind(acqinfo,nameref.name,nameref.ref);
    if z<0, error(['Could not find name/ref ' nameref.name ':' ...
     int2str(nameref.ref) ' in directory ' cksds.dir_str(i).dirname '.']); end;
    [ext1str,ext2str] = getextractors(cksds,nameref.name,nameref.ref);
    if ~isempty(ext2str),
	try, ex1 = evalin('base',ext1str); ex2=evalin('base',ext2str);
	catch, error(['Could not find extractor ' ext2str '.']);end;
	[ex2,status]=extractdir(ex2,ex1,cksds.dir_str(i).dirname,acqinfo(z),...
		cksds,instruc);
	if status<0,error(['Error in extraction; extractor: ' ...
		ext2str ', nameref: ' cksds.nameref_list(i).name ',' ...
		int2str(cksds.nameref_list(i).ref) ' in directory ' ...
		cksds.dir_str.dirname '.']);
	elseif status==0&instruc.extractincompletedir, newlist = [newlist i]; end;
	assignin('base',ext2str,ex2);
    end;
   end;
  end;
 end; if ~isempty(newlist), dowait(5); end;
end;

% cleanup
list = 1:length(cksds.nameref_list);
newlist = 1:length(cksds.nameref_list);
while ~isempty(newlist),
list = newlist; newlist = [];
  for i=list,
   [ext1str,ext2str] = getextractors(cksds,cksds.nameref_list(i).name,...
			cksds.nameref_list(i).ref);
   if ~isempty(ext2str),
	try, ex1 = evalin('base',ext1str);ex2 = evalin('base',ext2str);
	catch, error(['Could not find extractor ' ext2str '.']);end;
	[ex2,status]=cleanupextract(ex2,ex1,cksds.nameref_list(i),cksds,instruc);
	if status<0,error(['Error in cleanup; extractor: ' ...
		ext2str ', nameref: ' cksds.nameref_list(i).name ',' ...
		int2str(cksds.nameref_list(i).ref) '.']);
	elseif status==0&instruc.extractincompletedir, newlist = [newlist i]; end;
	assignin('base',ext2str,ex2);
   end;
  end; if ~isempty(newlist), dowait(5); end;
end;

newcksds = cksds; status = 1;
