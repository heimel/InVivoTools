function b=addtotpdatabase(ds,nameref,listofcells,listofcellnames,varargin)

% ADDTOTPDATABASE - Add cells to experiment database
%
%   B=ADDTOTPDATABSE(MYDIRSTRUCT,NAMEREF,LISTOFCELLS,...
%         LISTOFCELLNAMES,VARARGIN)
%
%   Adds cells to database;
%

datestr = getpathname(ds);
sp = find(datestr=='-');
if length(sp)~=2, error(['Can''t extract date string...too many dashes.']); end;

datestr = [datestr(sp(1)-4:sp(1)-1) '_' datestr(sp(1)+1:sp(2)-1) '_' datestr(sp(2)+1:sp(2)+2)];

types = {}; data = {};

testeddirs = 0;

S = warning('off'); 
oldcells=load(getexperimentfile(ds,1),['cell_tp_' sprintf('%.3d',nameref.ref) '*'],'-mat');
warning(S);
if ~isempty(oldcells), oldcells = fieldnames(oldcells); end;
newcells = {};
for i=1:length(listofcells),
	cellname=[listofcells(i).type '_tp_' sprintf('%.3d',nameref.ref) '_' sprintf('%.3d',listofcells(i).index) '_' datestr];
	assoc = myassoc('',''); assoc = assoc([]); 
	assoc = [assoc myassoc('pixelinds',listofcells(i).pixelinds)];
	assoc = [assoc myassoc('pixellocs',struct('x',listofcells(i).xi,'y',listofcells(i).yi))];
	assoc = [assoc myassoc('analyzetpstack type',listofcells(i).type)];
	assoc = [assoc myassoc('analyzetpstack labels',{listofcells(i).labels})];
	for j=1:2:length(varargin), % assign additional
		assoc = [assoc myassoc(varargin{j},varargin{j+1})];
	end;
	tpassociatelistglobals;
	for j=1:length(tpassociatelist), assoc = [assoc tpassociatelist(j)]; end;
	mymd = measureddata([],'','');
	for j=1:length(assoc), mymd = associate(mymd,assoc(j)); end;
	testlist = sort(gettests(ds,nameref.name,nameref.ref));
	myfirstdir = listofcellnames{i}(findstr(listofcellnames{i},'ref')+4:end);
	myfirstdirloc = [];
	for hj=1:length(testlist), if strcmp(testlist{hj},myfirstdir), myfirstdirloc = hj; break; end; end;
	if ~isempty(myfirstdirloc), unlabeledtests = testlist(myfirstdirloc:end);
	else, error(['Cannot find recorded test directory matching cell name directory ' myfirstdir '.']);
	end;
 	% use first cell as surrogate for all cells in getting test directory names
	% otherwise, the following would be quite slow
	if testeddirs==0,
		newassocs = myassoc('','');
		newassocs = newassocs([]);
		while ~isempty(unlabeledtests),
			[types,data,labeledtests] = identifytestdir(mymd,unlabeledtests{1},ds,nameref,setdiff(unlabeledtests,unlabeledtests{1}));
			for j=1:length(types),
				newassocs = [newassocs myassoc(types{j},data{j})];
			end;
			if isempty(labeledtests), labeledtests = unlabeledtests{1}; end; % if we didn't label it we have to move on
			unlabeledtests = setdiff(unlabeledtests,labeledtests);
		end;
		testeddirs = 1;
		if ~isempty(newassocs)&i==1,
			newerassocs = newassocs([]);
			% combine any associates that are duplicates into a cell list
			alreadyadded = {};
			for j=1:length(newassocs),
                newassocs(j).type,
				if isempty(intersect(alreadyadded,newassocs(j).type)), % haven't yet added it
					newdata = {};
					for jjj=1:length(newassocs),
						if strcmp(newassocs(j).type,newassocs(jjj).type),
							newdata = cat(2,newdata,newassocs(jjj).data);
						end;
					end;
					if length(newdata)>1, newassocs(j).data = newdata; end;
					if i==1, newassocs(j), end;
                    if ~iscell(newassocs(j).type),
        				alreadyadded = cat(2,alreadyadded,{newassocs(j).type});
                    else,
        				alreadyadded = cat(2,alreadyadded,newassocs(j).type);
                    end;
					newerassocs(end+1) = newassocs(j);
				end;
			end;
		end;
	end;
	for j=1:length(newerassocs), mymd=associate(mymd,newerassocs(j)); end;
	saveexpvar(ds,mymd,cellname,1); % save to experiment file preserving previous associates
	newcells{end+1} = cellname;
	cellname,
end;
remainder = setdiff(oldcells,newcells);  % remove any old cells that are no longer present in the stack
%for i=1:length(remainder), deleteexpvar(ds,remainder{i}); end;

function assoc=myassoc(type,data)
if ~iscell(data),
	assoc=struct('type',type,'owner','twophoton','data',data,'desc','');
else,
	assoc=struct('type',type,'owner','twophoton','data',{data},'desc','');
end;

