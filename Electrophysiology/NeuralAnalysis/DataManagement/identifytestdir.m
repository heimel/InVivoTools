function [types,data,labeleddirs] = identifytestdir(md,t,ds,nameref,unlabeleddirs)

%  IDENTIFYTESTDIR - Identifies stimulus type in test directory
%
%  [TYPES,DATA,LABELEDDIRS] = IDENTIFYTESTDIR(MD,DIR,DS,NAMEREF,UNLABELEDDIRS)
%
%  IDENTIFTYTESTDIR provides a framework for linking recorded 
%  stimulus scripts with appropriate analyses.  It attempts to
%  identify stimulus scripts present in test directories and
%  provide a label that analysis software can find.
%
%  
%
%  This function first checks for the existence of any
%  user-defined identifytestdir functions.  See
%  IDENTIFYTESTDIRGLOBALS for help in creating such a function.
%  
%  If no user-defined functions can identify the stimulus,
%  then the 
%  
%  
%  This function has been defined to be augmented by user .m files.
%  The global 
%
%  
  
types= {}; data = {}; labeleddirs = {};

theassoc = findassociate(md,'','','');

try,
	stims = load([fixpath(getpathname(ds)) t filesep 'stims.mat'],'-mat');
	script = stims.saveScript;
catch,
	return;  % no stims to label here
end;

%desc = sswhatvaries(script);

identifytestdirglobals;

is_type=0;must_be_unique=1;must_ask=0;

for i=1:length(IDTestDir),
	[is_type,must_be_unique,must_ask,replaceexist] = feval(IDTestDir(i).function,...
		IDTestDir(i).type,script,md,nameref,t,unlabeleddirs,ds);
	if is_type, break; end;
end;

candidate_dirs = {};

if is_type,
	candidate_dirs = {t}; scriptlist = {script};
	ind=i; type=IDTestDir(ind).type;
	% if the measureddata object already has a label then let's not relabel it unless we have to
	if ~isempty(findassociate(md,type,'',''))&~IDreplace&~replaceexist,
		labeleddirs = {t};
		return;
	end;
	for i=1:length(unlabeleddirs), % are there any other candidate directories for this test label?
		otherscript = '';
		try,
			otherstims=load([fixpath(getpathname(ds)) unlabeleddirs{i} filesep 'stims.mat'],'-mat');
			otherscript=otherstims.saveScript;
		catch,

		end;
		if ~isempty(otherscript),
			[is_type2,mbu2,ma2]=feval(IDTestDir(ind).function,type,otherscript,md,nameref,...
				unlabeleddirs{i},setdiff(unlabeleddirs,unlabeleddirs{i}));
			if is_type2,
				candidate_dirs = cat(1,candidate_dirs,{unlabeleddirs{i}});
				scriptlist = cat(1,scriptlist,{otherscript});
			end;
		end;
	end;
	% are there any other test labels appropriate for these candidate directories?
	canstruct=struct('type',type,'candidate_dirs',{candidate_dirs},'must_be_unique',must_be_unique,...
			'must_ask',must_ask,'replaceexist',replaceexist);
	for j=1:length(IDTestDir),
		for i=1:length(candidate_dirs),
			if j~=ind,
				[is_type,mbu2,ma2,re2] = feval(IDTestDir(j).function,...
					IDTestDir(j).type,scriptlist{i},md,nameref,candidate_dirs{i},unlabeleddirs,ds);
				if is_type,
					if strcmp(canstruct(end).type,IDTestDir(j).type),
						canstruct(end).candidate_dirs{end+1}=candidate_dirs{i};
					else,
						canstruct(end+1)=struct('type',IDTestDir(j).type,...
							'candidate_dirs',{candidate_dirs(i)},'must_be_unique',mbu2,'must_ask',ma2,...
							'replaceexist',re2);
					end;
				end;
			end;
		end;
	end;
	for j=1:length(canstruct),
		if ( ((length(canstruct(j).candidate_dirs)>1)&canstruct(j).must_be_unique) | canstruct(j).must_ask | IDmustask),
			if canstruct(j).must_be_unique,
				[s,o]=listdlg('ListString',canstruct(j).candidate_dirs,'name',...
					['Select ' canstruct(j).type],'SelectionMode','single',...
					'PromptString',['Unique ' canstruct(j).type],...
					'CancelString','None');
			else,
				[s,o]=listdlg('ListString',canstruct(j).candidate_dirs,'name',...
					['Select directories for ' canstruct(j).type],'SelectionMode','multiple',...
					'PromptString',['' canstruct(j).type],...
					'CancelString','None');
			end;
			if isempty(s),
				types{end+1} = canstruct(j).type; data{end+1} = '';
			else,
				for i=1:length(s),
					types{end+1}=canstruct(j).type,data{end+1}=canstruct(j).candidate_dirs{s(i)};% s will exist but it might be empty
				end;
			end;
			labeleddirs = union(labeleddirs,canstruct(j).candidate_dirs);
		else,
			types{end+1}=canstruct(j).type;
			if length(canstruct(j).candidate_dirs)>1, data{end+1} = canstruct(j).candidate_dirs;
			else, data{end+1} = canstruct(j).candidate_dirs{1};
			end;
			labeleddirs = union(labeleddirs,canstruct(j).candidate_dirs);
		end;
	end;
end;


