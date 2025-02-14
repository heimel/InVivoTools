function [new_aeInfo] = autoextract(aeInfo);

%naming convention:

%  aeInfo:
%  data_dir:  where the data are
%  noextract_types: type not to extract, including ALL
%  extract_types:  types to extract (ALL by default)
%  noextract_names: specific names not to extract, including NONE
%  extract_names: specific names to extract, including ALL
%  analysis_dir: where to save results
%  name_append: string to append to cell names
%  update: 0/1, 0 => start from scratch, 1 => update
%  CELLsub:  - string for which to substitute computed cell name
%  extract_params:
%     type
%     algor
%     algor_p
%     output_type
%     output_p
%  visited_dirnames:
%  record_lists:
%      name
%      type
%      ref
%      needs_update

prev = pwd; % save current directory

aeInfo.noextract_names = [aeInfo.noextract_names ' '];
aeInfo.extract_names = [aeInfo.extract_names ' '];
aeInfo.noextract_types = [aeInfo.noextract_types ' '];
aeInfo.extract_types = [aeInfo.extract_types ' '];

if (aeInfo.update==0), aeInfo.record_lists = {}; end;

if isempty(aeInfo.record_lists),
	aeInfo.record_lists = {}; aeInfo.visited_dirnames = {};
end;

cd(aeInfo.data_dir);
g = dir;

 % now, look at what data we have

for i=3:length(g),
   if (exist(g(i).name)==7)&~isInList(g(i).name,aeInfo.visited_dirnames),
	isInList(g(i).name,aeInfo.visited_dirnames),
	% explore this dir...
   	aeInfo.visited_dirnames(length(aeInfo.visited_dirnames)+1)= {g(i).name};
	% add it to list
	cd(g(i).name);
	pwd,
	if (exist('acqParams_out')),
		% get records for this directory
		eval('!mac2unix acqParams_out;');
		r = loadStructArray('acqParams_out');
		j = whichRecord(r.name,r.ref,aeInfo.record_lists);
		if j==0,
			k = length(aeInfo.record_lists);
			aeInfo.record_lists(k+1) = ...
			struct('name',r.name,'type',r.type,...
			    'ref',r.ref,'needs_update',1);
		else, aeInfo.record_lists(j).needs_update = 1;
		end;
	end;
	cd(aeInfo.data_dir);
   end;
end;

new_aeInfo = aeInfo;
cd(prev);
%return;

for i=1:length(aeInfo.record_lists),
	l = aeInfo.record_lists(i);
	do_extract = 1;
	if (l.needs_update == 0) | ...
	(strcmp('ALL ',aeInfo.noextract_types)& ...
		(~findstr(aeInfo.extract_types,l.type))) |  ...
	(strcmp('ALL ',aeInfo.noextract_names)& ...
		(~findstr(aeInfo.extract_names,l.name))), do_extract = 0;
	end;
	if do_extract,
		aeInfo.record_lists(i).needs_update = 0;
		% make recparams
		if strcmp(l.type,'singleEC'),
			recparams = struct('ref', l.ref, 'channel', 1);
			name = ['n1s' int2str(l.ref) aeInfo.name_append ];
		end;
		w = 0;
		for k=1:length(aeInfo.extract_params),
			if strcmp(aeInfo.extract_params(k).type,l.type),
				w=k;
			end;
		end;
		if w==0, error(['Error: no extraction parameters for type ' ...
			l.type]); end;
		exP = aeInfo.extract_params(w);
		out_p=structStringReplace(exP.output_p,aeInfo.cellSUB,name);
		out_p.filename_obj,
		name,
		spikedetect(aeInfo.data_dir,l.name,recparams,exP.algor,...
			exP.algor_p,exP.output_type,out_p);
	end;
end;

new_aeInfo = aeInfo;
cd(prev);

function b = isInList(str,listOfStrs),
b = 0;
for i=1:length(listOfStrs),
	if strcmp(str,listOfStrs(i)), b = 1; return; end;
end;

function b = whichRecord(str,ref,record_lists),
b = 0;
for i=1:length(record_lists),
	if strcmp(str,record_lists(i).name)&(ref==record_lists(i).ref),
	  b = i; return;
        end;
end;

function g = structStringReplace(theStruct, fnd, rpl);
  % assumes only one occurance
fldnms = fieldnames(theStruct);
for i=1:length(fldnms),
	h = getfield(theStruct,fldnms{i});
	if ischar(h),
		j = findstr(h,fnd);
		if ~isempty(j),
			h,
			h = [h(1:j-1) rpl h(j+length(fnd):end)],
		end;
		theStruct = setfield(theStruct,fldnms{i},h);
	end;
end;
g = theStruct;
