function [is_type,must_be_unique,must_ask,replace_existing] = fitzlabtestid(type, script, md, nameref, dirname, otherunlabeleddirs,ds)

% FITZLABTESTID - Identifies test directories for Fitzlab
%
%  Conforms to the IDENTIFYTESTDIRGLOBALS standard.
%
%  [IS_TYPE,MUST_BE_UNIQUE,MUST_ASK,REPLACE_EXISTING]=...
%             FITZLABTESTID(TYPE,SCRIPT,MD,NAMEREF,DIRNAME,
%              OTHERUNLABELEDDIRS,DS)
%
%  If called with no arguments then the function attempts to
%  add itself to the IDTestDir list.  If another function
%  already identifies a given stimulus type then a warning is
%  given and the function is replaced.
%
%  Understands the following types:
%
%  'Best orientation test'
%  'orientation test'
%  'Best SF test'
%  'SF test'
%  'Best contrast test'
%  'contrast test'
%  'Best TF test'
%  'TF test'
%  'Best X pos test'
%  'Best Y pos test'
%  'Color exchange test'
%  'DragoiAdaptOri test'
%  'DragoiAdaptPos test'
%  'Color exchange barrage test'
%  'Color exchange Dacey-like test'
%  'Color exchange Dacey expanded test'

types = {'Best orientation test','Best SF test', 'Best TF test', 'Best contrast test', ...
	'orientation test','SF test','TF test','contrast test',...
	'Best phase test','phase test','Best X pos test','Best Y pos test','Color exchange test',...
	'DragoiAdaptOri test','DragoiAdaptPos test','Color exchange barrage test','Color exchange Dacey-like test',...
	'Color exchange Dacey expanded test'};
params = {'angle','sFrequency','tFrequency','contrast',...
		'angle','sFrequency','tFrequency','contrast','sPhaseShift','sPhaseShift'};

if nargin==0,
	identifytestdirglobals;
	for i=1:length(types),
		found = 0;
		for j=1:length(IDTestDir),
			if strcmp(IDTestDir(j).type,types{i}),
				found = 1;
				if ~strcmp(IDTestDir(j).function,'fitzlabtestid'),
					warning(['Replacing test id function ' IDTestDir(j).function ...
						' with fitzlabtestid for type ' types{i} '.']);
					IDTestDir(j).function = 'fitzlabtestid';
				end;
				break;
			end;
		end;
		if ~found, IDTestDir(end+1) = struct('type',types{i},'function','fitzlabtestid'); end;
	end;
	return;
end;

is_type=0; must_ask=0;must_be_unique=0;replace_existing=0;

must_ask_ =             [ 1 0 0 0 0 0 0 0 0 0];
must_be_unique_ =       [ 1 1 1 1 0 0 0 0 1 0];
replace_existing_ =     [ 0 0 0 0 1 1 1 1 0 1];
leave_self_unlabeled_ = [ 0 0 0 0 1 1 1 1 0 1];
leave_others_unlabeled_=[ 1 1 1 1 1 1 1 1 1 1];

for i=1:length(types),
	if strcmp(type,types{i}),
		if i<10,  % a simple parameter variation
			[is_type,must_be_unique,must_ask,replace_existing,leave_self_unlabeled,leave_others_unlabeled]=...
				ismytestdir(sswhatvaries(script),...
				params{i}, must_be_unique_(i),must_ask_(i),replace_existing_(i),leave_self_unlabeled_(i),...
				leave_others_unlabeled_(i));
		else,
			[is_type,must_be_unique,must_ask,replace_existing,leave_self_unlabeled,leave_others_unlabeled]...
				=isother(type,script);
		end;
	end;
end;

function [is_type,mbu,ma,re,lsu,lou] = ismytestdir(desc,param,munique,mustask,replaceexisting,leaveselfunlabeled,leaveothersunlabeled)
is_type=0;mbu=munique;ma=mustask;re=replaceexisting;lsu=leaveselfunlabeled;lou=leaveothersunlabeled;
if length(desc)==1, if strcmp(desc{1},param), is_type=1; end; end;

function [is_type,mbu,ma,ra,lsu,lou] = isother(type,script);
is_type = 0; mbu = 0; ma = 0; ra = 0; lsu = 0; lou = 1;
switch type,
	case {'Best X pos test', 'Best Y pos test'},
		testgood = 1;
		rects = [];
		for i=1:numStims(script),
			if ~isfield(getparameters(get(script,i)),'isblank'),
				testgood=testgood*strcmp('periodicstim',class(get(script,i)));
			end;
		end;
		if numStims(script)<3, testgood = 0; end;
		if testgood,
			for i=1:numStims(script),
				if ~isfield(getparameters(get(script,i)),'isblank'),
					rects = [rects; getfield(getparameters(get(script,i)),'rect')];
				end;
			end;
			rs = max(diff(rects));
			if strcmp(type,'Best X pos test')&rs(2)==rs(4)&rs(4)==0&rs(1)>0&rs(3)>0&rs(1)<70&rs(3)<70,
				is_type=1;mbu=1;ma=0;ra=1;lsu=0;lou=1;
			elseif strcmp(type,'Best Y pos test')&rs(1)==rs(3)&rs(1)==0&rs(2)>0&rs(4)>0&rs(2)<70&rs(4)<70,
				is_type=1;mbu=1;ma=0;ra=1;lsu=0;lou=1;
			end;
		end;
	case 'Color exchange test',
		testgood = 1;
		chromhigh = [ ]; chromlow = [];
		for i=1:numStims(script), testgood=testgood*strcmp('periodicstim',class(get(script,i))); end;
		if numStims(script)~=11, testgood = 0; end;
		if testgood,
			for i=1:numStims(script),
				p = getparameters(get(script,i));
				if ~eqlen(p.chromhigh,p.chromlow),
					chromhigh = [chromhigh ; p.chromhigh];
					chromlow = [chromlow ; p.chromlow];
				end;
			end;
			chs = std(chromhigh); cls = std(chromlow);
			if eqlen([chs([1 3]) cls([1 3])],[0 0 0 0])&chs(2)>0&cls(2)>0,
				is_type=1; mbu=0; ma=0; ra=1;lsu=1;lou=1;
			end;
		end;
	case 'Color exchange barrage test',
		testgood = 1;
		chromhigh = [ ]; chromlow = [];
		for i=1:numStims(script), testgood=testgood*strcmp('periodicstim',class(get(script,i))); end;
		if numStims(script)~=17, testgood = 0; end;
		if testgood,
			for i=1:numStims(script),
				p = getparameters(get(script,i));
				if ~eqlen(p.chromhigh,p.chromlow),
					chromhigh = [chromhigh ; p.chromhigh];
					chromlow = [chromlow ; p.chromlow];
				end;
			end;
			chs = std(chromhigh); cls = std(chromlow);
			if chs(2)>0&cls(2)>0&(sum(abs((chromhigh(1,:)-[127.5000 114.6353 243.4103])))<5),
				is_type=1; mbu=0; ma=0; ra=1;lsu=1;lou=1;
			end;
		end;
	case 'Color exchange Dacey expanded test',
		testgood = 1;
		chromhigh = [ ]; chromlow = [];
		for i=1:numStims(script), testgood=testgood*strcmp('periodicstim',class(get(script,i))); end;
		if numStims(script)~=17, testgood = 0; end;
		if testgood,
			for i=1:numStims(script),
				p = getparameters(get(script,i));
				if ~eqlen(p.chromhigh,p.chromlow),
					chromhigh = [chromhigh ; p.chromhigh];
					chromlow = [chromlow ; p.chromlow];
				end;
			end;
			chs = std(chromhigh); cls = std(chromlow);
			if chs(2)>0&cls(2)>0&(sum(abs((chromhigh(1,:)-[127.5000 189.4522 176.3707])))<5),
				is_type=1; mbu=0; ma=0; ra=1;lsu=1;lou=1;
			end;
		end;
	case 'Color exchange Dacey-like test',
		testgood = 1;
		chromhigh = [ ]; chromlow = [];
		for i=1:numStims(script), testgood=testgood*strcmp('periodicstim',class(get(script,i))); end;
		if numStims(script)~=14, testgood = 0; end;
		if testgood,
			for i=1:numStims(script),
				p = getparameters(get(script,i));
				if ~eqlen(p.chromhigh,p.chromlow),
					chromhigh = [chromhigh ; p.chromhigh];
					chromlow = [chromlow ; p.chromlow];
				end;
			end;
			chs = std(chromhigh); cls = std(chromlow);
			if chs(2)>0&cls(2)>0,
				is_type=1; mbu=0; ma=0; ra=1;lsu=1;lou=1;
			end;
		end;		
	case 'DragoiAdaptOri test',
		testgood = 1;
		if numStims(script)<4, testgood = 0; end;
		if testgood,
			testgood = 0;
			do=getDisplayOrder(script);
			dummyscript=script;
			dummyscript = remove(remove(dummyscript,1),1); 
			WV = sswhatvaries(dummyscript);
			if length(WV)==0, WV = {'test'}; end;
			if length(intersect(WV,{'angle'}))==1,
				if do(1)==1&all(do(3:2:end)==2)&all(do(2:2:end)>2),
					testgood = 1;
					is_type=1; mbu=1; ma=0; ra=1;lsu=0;lou=0;
				end;
			end;
		end;
	case 'DragoiAdaptPos test',
		testgood = 1;
		if numStims(script)<4, testgood = 0; end;
		if testgood,
			testgood = 0;
			do=getDisplayOrder(script);
			dummyscript=script;
			dummyscript = remove(remove(dummyscript,1),1); 
			WV = sswhatvaries(dummyscript);
			if length(intersect(WV,{'rect'}))==1&length(intersect(WV,{'angle'}))==0,
				if do(1)==1&all(do(3:2:end)==2)&all(do(2:2:end)>2),
					testgood = 1;
					is_type=1; mbu=1; ma=0; ra=1;lsu=0;lou=0;
				end;
			end;
		end;
end;

