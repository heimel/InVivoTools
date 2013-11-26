function lgnctxcsd_pulsetrain(cbo, fig)

  % if cbo is text, then is command; else, the tag is used as command
  % if fig is given, it is used; otherwise, callback figure is used

if nargin==0, % open new figure and draw it
  z = geteditor('RunExperiment');
  if isempty(z),errordlg('Needs an experiment to run tests.');return;end;
  cksds = getcksds;
  if isempty(cksds), errordlg(['No existing data---make sure you hit '...
                 'return after directory in RunExperiment window']);
                 return;
  end; % now we're sure we've got it or returned
  h1 = drawfig;
  filldefaults(h1,[],[]);
  lgnctxcsd_pulsetrain('UpdateListBt',h1);
else,  % respond to command
  if nargin==2, thefig = fig; else, thefig = gcbf; end;
  if isa(cbo,'char'), thetag=cbo; else, thetag = get(cbo,'Tag'); end;
  ud = get(thefig,'userdata');
  cksds = getcksds;
  if isempty(cksds),
    errordlg('Cannot find directory structure in RunExperiment.');
  end;
  switch thetag,
    case 'UpdateListBt',
		% update record list
		nrfs = getsubnamerefs(cksds,'ctx');
		strs = {};
		for i=1:length(nrfs),
			if strcmp(nrfs(i).name,'ctxF1'),
				strs{end+1}=[nrfs(i).name(1:end-1) ' | ' int2str(nrfs(i).ref)];
			end;
		end;
		val = length(strs);
		set(ft(thefig,'RecordPopup'),'string',strs,'value',val);
	case 'AnalyzeBt',
       ud.mw = cell(1,16);
	   set(thefig,'userdata',ud);
	   lgnctxcsd_pulsetrain('Analyze',thefig);
    case 'Analyze',
	   teststr=get(ft(thefig,'TestEdit'),'String');
	   sts=getstimscripttimestruct(cksds,teststr);
       val=get(ft(thefig,'RecordPopup'),'value');
	   strs=get(ft(thefig,'RecordPopup'),'string');
	   g=load(getexperimentfile(cksds),'*spikes*','-mat');
	   fn=fieldnames(g);
	   nameref=getnamereffromstring(strs{val});
	   [ud.mw,ud.T,ud.pulsetimes]=lgnctxcsd_pulsetrain_field(cksds,teststr,getfield(g,fn{1}),...
	   		nameref.ref,-0.005,0.010,1);
       set(thefig,'userdata',ud);
	   numpulses = length(ud.pulsetimes);
	   str = {};
	   for i=1:numpulses, str{i} = int2str(i); end;
	   if numpulses<5,
	       set(ft(thefig,'BlackPopup'),'String',str,'value',1);
	       set(ft(thefig,'BluePopup'),'String',str,'value',2);
	       set(ft(thefig,'RedPopup'),'String',str,'value',3);
	       set(ft(thefig,'GreenPopup'),'String',str,'value',4);
	   elseif numpulses<11,
	       set(ft(thefig,'BlackPopup'),'String',str,'value',1);
	       set(ft(thefig,'BluePopup'),'String',str,'value',2);
	       set(ft(thefig,'RedPopup'),'String',str,'value',4);
	       set(ft(thefig,'GreenPopup'),'String',str,'value',5);
	   else,
	       set(ft(thefig,'BlackPopup'),'String',str,'value',1);
	       set(ft(thefig,'BluePopup'),'String',str,'value',5);
	       set(ft(thefig,'RedPopup'),'String',str,'value',10);
	       set(ft(thefig,'GreenPopup'),'String',str,'value',15);
	   end;
	   lgnctxcsd_pulsetrain('DrawMW',thefig);
	case {'DrawMW','BlackPopup','BluePopup','RedPopup','GreenPopup'},
	   ahigh = [];
	   alow = [];
	   for i=1:16,
		if ~isempty(ud.mw{i}),
	   		ax=ft(thefig,['Axes' int2str(i)]);
	        axes(ax);
	        hold off;
	        plot(ud.T,ud.mw{i},'color',[0.8 0.8 0.8]);
			hold on;
			v1=get(ft(thefig,'BlackPopup'),'value');
			v2=get(ft(thefig,'BluePopup'),'value');
			v3=get(ft(thefig,'RedPopup'),'value');
			v4=get(ft(thefig,'GreenPopup'),'value');
			plot(ud.T,ud.mw{i}(v1,:),'k');
			plot(ud.T,ud.mw{i}(v2,:),'b');
			plot(ud.T,ud.mw{i}(v3,:),'r');
			plot(ud.T,ud.mw{i}(v4,:),'g');
			if ~(i==4|i==8|i==12|i==16), set(ax,'xtick',[]); end;
	        set(ax,'Tag',['Axes' int2str(i)]);
			a=axis;alow(i)=a(3);ahigh(i)=a(4);
		end;
	   end;
	   ud.scale = [min(alow) max(ahigh)];
	   set(thefig,'userdata',ud);
	   lgnctxcsd_pulsetrain('SetScale',thefig);
	case 'SetScale',
	   for i=1:16,
	   		ax=ft(thefig,['Axes' int2str(i)]);
			axes(ax);
			if ~isempty(ud.T),axis([ud.T(1) ud.T(end) ud.scale]); end;
			set(ax,'Tag',['Axes' int2str(i)]);
	   end;
	case {'MatchV1','MatchV2','MatchV3','MatchV4','MatchV5','MatchV6','MatchV7','MatchV8',...
		 'MatchV9','MatchV10','MatchV11','MatchV12','MatchV13','MatchV14','MatchV15','MatchV16'},
		strlist={'MatchV1','MatchV2','MatchV','MatchV4','MatchV5','MatchV6','MatchV7',...
			'MatchV8','MatchV9','MatchV10','MatchV11','MatchV12','MatchV13','MatchV14',...
				'MatchV15','MatchV16'};
		for i=1:length(strlist), if strcmp(thetag,strlist{i}),b=i; break;end;end;
		ax=ft(thefig,['Axes' int2str(b)]); axes(ax); a=axis;
		ud.scale = a([3 4]);
		set(thefig,'userdata',ud);
		lgnctxcsd_pulsetrain('SetScale',thefig);
	case {'MatchH1','MatchH2','MatchH3','MatchH4','MatchH5','MatchH6',...
		  'MatchH7','MatchH8','MatchH9','MatchH10','MatchH11','MatchH12',...
		  'MatchH13','MatchH14','MatchH15','MatchH16'},
		strlist = {'MatchH1','MatchH2','MatchH3','MatchH4','MatchH5','MatchH6',...
				   'MatchH7','MatchH8','MatchH9','MatchH10','MatchH11','MatchH12',...
				   'MatchH13','MatchH14','MatchH15','MatchH16'};
        for i=1:length(strlist),if strcmp(thetag,strlist{i}),b=i;break;end;end;
		ax=ft(thefig,['Axes' int2str(b)]); axes(ax); A=axis;
	    for i=1:16,
	   		ax=ft(thefig,['Axes' int2str(i)]);
			axes(ax); a = axis;
			if ~isempty(ud.T),axis([A(1) A(2) a(3) a(4)]); end;
			set(ax,'Tag',['Axes' int2str(i)]);
	    end;
	case 'GetPointBt',
		v = get(ft(thefig,'ChannelPopup'),'value');
	   	ax=ft(thefig,['Axes' int2str(v)]);
		axes(ax);
		[x,y]=ginput(1);
		ud.dynpoint = x;
		set(ax,'Tag',['Axes' int2str(v)]);
		set(thefig,'userdata',ud);
		lgnctxcsd_pulsetrain('DrawDyn',thefig);
	case 'DrawDyn',
		ax = ft(thefig,'DynamicAxes');
		v=get(ft(thefig,'ChannelPopup'),'value');
		if (~isempty(ud.dynpoint))&(~isempty(ud.mw{v})),
			axes(ax);
			t = findclosest(ud.T,ud.dynpoint);
			hold off;
			dat = ud.mw{v}(:,t)/ud.mw{v}(1,t);
			plot(ud.pulsetimes,dat,'o');
			hold on;
			plot(ud.pulsetimes,dat,'b');
		end;
		set(ax,'Tag','DynamicAxes');
  otherwise, disp(['unhandled tag ' thetag '.']);
  end;
end;

 % handy subfunctions

 % return namerefs matching str (see findstr), not case sensitive
function namerefs = getsubnamerefs(cksds,str)
namerefs =[];
z = geteditor('RunExperiment');
udre = get(z,'userdata');
udre2 = get(udre.list_aq,'userdata');

nrf = getallnamerefs(cksds);
if isempty(udre2)&isempty(nrf),
	errordlg('Needs an aquisition record or recorded data.'); return;
end;
for i=1:length(udre2),
	goodmatch = 0;
	for j=1:length(nrf), if udre2(i)==nrf(j),goodmatch=1; end; end;
	nn.name = udre2(i).name;nn.ref = udre2(i).ref;
	if ~goodmatch, nrf=[nrf nn]; end;
end;

inds = [];
for i=1:length(nrf),
	if ~isempty(findstr(upper(str),upper(nrf(i).name))),inds=[inds i];end;
end;
namerefs = nrf(inds);

function ag = docurve(s,c,data,paramname,tuning,title,lastfig)
inp.st = s; inp.spikes = getfield(data,c{1}); inp.paramname = paramname;
inp.title=title;
where.figure=figure;where.rect=[0 0 1 1]; where.units='normalized';
orient(where.figure,'landscape');
if tuning,
  tc = tuning_curve(inp,'default',where);
  ag = tc;
else,
  inp.paramnames = {paramname};
  pc = periodic_curve(inp,'default',where);
  p = getparameters(pc);
  p.graphParams(4).whattoplot = lastfig;
  pc = setparameters(pc,p);
  ag = pc;
end;

function [s,c,data] = getstimcellinfo(cksds,nameref,testname)
ng = 0;
try, s = getstimscripttimestruct(cksds,testname);
catch, errordlg('Stimulus data not found.'); ng=1; end;
try, c = getcells(cksds,nameref);
catch, errordlg('Cell data not found.'); ng=1; end;
data = {};
for i=1:length(c),
  try, data{i}=load(getexperimentfile(cksds),c{i},'-mat');
  catch, ng=1;errordlg(['Cell data ' c{i} 'not found in experiment file.']);end;
end;
if ng==1, s = []; c = []; data = []; end;

function [c,data] = getcellinfo(cksds,testname)
ng = 0;
try, refs = getnamerefs(cksds,testname);
catch, errordlg(['Could not find records in directory ' testname '.']);ng=1;end;
c = {};
for i=1:length(refs),
    cn = {};
	try, cn = getcells(cksds,refs(i));
	catch,
		errordlg(['Cell data for ' refs(i).name ' | ' int2str(refs(i).ref) ...
				' not found.']); ng=1;
	end;
    c = cat(2,c,cn);
end;
data = {};
for i=1:length(c),
  try, data{i}=load(getexperimentfile(cksds),c{i},'-mat');
	   data{i}=getfield(data{i},c{i});
  catch, ng=1;errordlg(['Cell data ' c{i} 'not found in experiment file.']);end;
end;
if ng==1, c = []; data = []; end;


function [c,d] = getcurrentcells(thefig,cksds,onlyanalysis)
c = {}; d = {}; ng = 0;
if get(ft(thefig,'AnalyzeCTXCB'),'value')|(~onlyanalysis),
  v = get(ft(thefig,'CTXCellsPopup'),'value');
  str = get(ft(thefig,'CTXCellsPopup'),'string');
  ref = getnamereffromstring(str{v});
  try, c = cat(2,c,getcells(cksds,ref));
  catch, errordlg(['Cell data for ' str{v} ' not found.']); ng=1;
  end;
end;
if get(ft(thefig,'AnalyzeLGNCB'),'value')|(~onlyanalysis),
  str=get(ft(thefig,'LGNCellList'),'string');
  sel=get(ft(thefig,'LGNCellList'),'value');
  if isempty(c), c = c'; end;
  c = cat(2,c,str(sel)');
end;
for i=1:length(c),
  try, d{i}=load(getexperimentfile(cksds),c{i},'-mat');
	d{i}=getfield(d{i},c{i});
  catch, ng=1;errordlg(['Cell data ' c{i} 'not found in experiment file.']);end;
end;
if ng, c = {}; d = {}; end;

function [s,c,data] = getcurrentstimcellinfo(thefig,cksds,testname)
ng = 0;
try, s = getstimscripttimestruct(cksds,testname);
catch, errordlg('Stimulus data not found.'); ng=1; end;
c = {};
if get(ft(thefig,'AnalyzeCTXCB'),'value'),
  v = get(ft(thefig,'CTXCellsPopup'),'value');
  str = get(ft(thefig,'CTXCellsPopup'),'string');
  ref = getnamereffromstring(str{v});
  try, c = cat(2,c,getcells(cksds,ref));
  catch, errordlg(['Cell data for ' str{v} ' not found.']); ng=1;
  end;
end;
if get(ft(thefig,'AnalyzeLGNCB'),'value'),
  str=get(ft(thefig,'LGNCellList'),'string');
  sel=get(ft(thefig,'LGNCellList'),'value');
  c = cat(2,c,str(sel)');
end;
data = {};
for i=1:length(c),
  try, data{i}=load(getexperimentfile(cksds),c{i},'-mat');
  catch, ng=1;errordlg(['Cell data ' c{i} 'not found in experiment file.']);end;
end;
if ng==1, s = []; c = []; data = []; end;

function refs = getcurrentrefs(thefig)
refs.name='test';refs.ref = 1; refs = refs([]); % make empty struct
if get(ft(thefig,'AnalyzeCTXCB'),'value'),
	v = get(ft(thefig,'CTXCellsPopup'),'value');
	str = get(ft(thefig,'CTXCellsPopup'),'string');
	refs(end+1) = getnamereffromstring(str{v});
end;
if get(ft(thefig,'AnalyzeLGNCB'),'value'),
	vals = get(ft(thefig,'LGNCellList'),'value');
	str = get(ft(thefig,'LGNCellList'),'String');
	for i=1:length(vals),
		refs(end+1) = getnamereffromstring(str{vals(i)});
	end;
end;

function nref = getnamereffromstring(str)
i = findstr(str,' | ');
if isempty(i), nref = []; return; end;
nref.name=str(1:i-1);
nref.ref=str2num(str(i+3:end));

 % get test number
function t = gtn(h1,tag)
t = [];
str = get(ft(h1,tag),'String');
cksds = getcksds;
tn = getalltests(cksds);
if isempty(intersect(tn,str)),
  errordlg(['No such test ' str '.']);
else, t = str;
end;


function b = islistfilledin(h1,taglist)
b=1; str='';
for i=1:length(taglist),
   b=b&(~istse(h1,taglist{i}));
   str = [str ', ' taglist{i}];
end;
if length(taglist)>1, str = str(3:end); end;
str = ['Error: ' str ' must be filled in before you can do that.'];
if ~b,
  errordlg(str);
end;

function b = istse(h1,tag) % is string field of element with tag 'tag' empty?
b = isempty(get(ft(h1,tag),'String'));

function h = ft(h1,st)  % shorthand
h = findobj(h1,'Tag',st);

function l = findinfoinlist(thefig,name)
l = []; ud = get(thefig,'userdata');
for i=1:length(ud.infolist),
   if strcmp(ud.infolist{i}.name,name),l=[l i];end;
end;


function cksds = getcksds (doup)
cksds = [];
z = geteditor('RunExperiment');
if ~isempty(z),
   if nargin==1, if doup, runexpercallbk('datapath',z); end; end;
   udre = get(z,'userdata');
   cksds = udre.cksds;
end;

function h1 = drawfig

h1 = pulsetrainanalysisfig;

function filldefaults(h1,cksds,cellname)
set(h1,'Tag','lgnctxcsd_pulsetrain');

ud = struct('scale',[],...
			'probechanlist',[1 9 2 10 5 13 4 12 7 15 8 16 7 14 3 11],...
			'mw',{cell(1,16)},'T',[],'dynpoint',[],'pulsetimes',[]);
set(h1,'userdata',ud);

