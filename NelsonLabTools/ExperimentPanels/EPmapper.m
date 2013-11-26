function lgnctxexperpanel(cbo, fig)

  % if cbo is text, then is command; else, the tag is used as command
  % if fig is given, it is used; otherwise, callback figure is used

if nargin==0, % open new figure and draw it
  z = geteditor('RunExperiment');
  if isempty(z),errordlg('Needs an experiment to run tests.');return;end;
  z2= geteditor('screentool');
  if isempty(z2),errordlg('Needs screentool to run tests.');return;end;
  [cr] = getscreentoolparams;
  if isempty(cr),errordlg('Needs good current rect in screentool.');return;end;
  cksds = getcksds;
  if isempty(cksds), errordlg(['No existing data---make sure you hit '...
                 'return after directory in RunExperiment window']);
                 return;
  end; % now we're sure we've got it or returned
  h1 = drawfig;
  filldefaults(h1,[],[]);
  EPmapper('UpdateListBt',h1);
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
			strs{i} = [ nrfs(i).name ' | ' int2str(nrfs(i).ref) ];
		end;
		val = i;
		set(ft(thefig,'RecordPopup'),'string',strs,'value',val);
    case 'RecalculateBt',
	   tststr=get(ft(thefig,'TestEdit'),'String');
	   sts=getstimscripttimestruct(cksds,tststr);
       val=get(ft(thefig,'RecordPopup'),'value');
	   strs=get(ft(thefig,'RecordPopup'),'string');
	   nameref=getnamereffromstring(strs{val});
	   cksmd=cksmeasureddata(getpathname(cksds),nameref.name,nameref.ref,'','');
	   [x,y,rect]=getgrid(get(sts.stimscript,1));
	   [mw,T]=blink_trigger(cksmd,get(sts.stimscript,1),sts.mti{1},-0.0,0.2,50);
	   ud.mw = mw; ud.T = T; ud.x=x; ud.y=y; ud.rect=rect;
	   ud.W = diff(rect([1 3]))/x; ud.H = diff(rect([2 4]))/y;
       set(thefig,'userdata',ud);
	   EPmapper('DrawMW',thefig);
	case 'DrawMW',
		ax=ft(thefig,'WaveAxes');
		axes(ax);
		hold off;
		plot(ud.T,ud.mw);
		a=axis; axis([ud.T(1) ud.T(end) a(3) a(4)]);
		ud.scale = [a(3) a(4)];
		set(ax,'Tag','WaveAxes');
		set(thefig,'userdata',ud);
	    EPmapper('DrawMap1Loc',thefig);
	    EPmapper('DrawMap2Loc',thefig);
	    EPmapper('DrawMap3Loc',thefig);
	case 'DrawMap1Loc',
		h=ft(thefig,'Map1LocPlot');
		if ~isempty(h), delete(h); end;
		ax = ft(thefig,'WaveAxes');
		axes(ax);
		hold on;
		h=plot([ud.map1loc ud.map1loc],[-1000 1000],'g');
		set(ax,'Tag','WaveAxes');
		set(h,'Tag','Map1LocPlot');
		EPmapper('DrawSpatialMap1',thefig);
	case 'DrawMap2Loc',
		h=ft(thefig,'Map2LocPlot');
		if ~isempty(h), delete(h); end;
		ax = ft(thefig,'WaveAxes');
		axes(ax);
		hold on;
		h=plot([ud.map2loc ud.map2loc],[-1000 1000],'r');
		set(ax,'Tag','WaveAxes');
		set(h,'Tag','Map2LocPlot');
		EPmapper('DrawSpatialMap2',thefig);
	case 'DrawMap3Loc',
		h=ft(thefig,'Map3LocPlot');
		if ~isempty(h), delete(h); end;
		ax = ft(thefig,'WaveAxes');
		axes(ax);
		hold on;
		h=plot([ud.map3loc ud.map3loc],[-1000 1000],'b');
		set(ax,'Tag','WaveAxes');
		set(h,'Tag','Map3LocPlot');
		EPmapper('DrawSpatialMap3',thefig);
	case 'DrawSpatialMap1',
		ax=ft(thefig,'Axes1');
		axes(ax);
		ti = findclosest(ud.T,ud.map1loc);
		plt = reshape(ud.mw(:,ti),[ud.y ud.x]);
		[m,n]=size(plt); plt = [plt zeros(m,1) ; zeros(1,n+1)];
		pcolor([ud.rect(1):ud.W:ud.rect(3)],[ud.rect(2):ud.H:ud.rect(4)],plt);
		colormap(gray(255));
		set(ax,'YDir','reverse');
		caxis(ud.scale);
		set(ax,'tag','Axes1');
		axcb=ft(thefig,'ColorBarAxes');
		colorbar(axcb);
		axes(axcb);a=axis;axis([a(1) a(2) ud.scale]);
		set(axcb,'Tag','ColorBarAxes');
	case 'DrawSpatialMap2',
		ax=ft(thefig,'Axes2');
		axes(ax);
		ti = findclosest(ud.T,ud.map2loc);
		plt = reshape(ud.mw(:,ti),[ud.y ud.x]);
		[m,n]=size(plt); plt = [plt zeros(m,1) ; zeros(1,n+1)];
		pcolor([ud.rect(1):ud.W:ud.rect(3)],[ud.rect(2):ud.H:ud.rect(4)],plt);
		set(ax,'YDir','reverse');
		colormap(gray(255));
		caxis(ud.scale);
		set(ax,'tag','Axes2');
		axcb=ft(thefig,'ColorBarAxes');
		colorbar(axcb);
		axes(axcb);a=axis;axis([a(1) a(2) ud.scale]);
		set(axcb,'Tag','ColorBarAxes');
	case 'DrawSpatialMap3',
		ax=ft(thefig,'Axes3');
		axes(ax);
		ti = findclosest(ud.T,ud.map3loc);
		plt = reshape(ud.mw(:,ti),[ud.y ud.x]);
		[m,n]=size(plt); plt = [plt zeros(m,1) ; zeros(1,n+1)];
		pcolor([ud.rect(1):ud.W:ud.rect(3)],[ud.rect(2):ud.H:ud.rect(4)],plt);
		set(ax,'YDir','reverse');
		colormap(gray(255));
		caxis(ud.scale);
		set(ax,'tag','Axes3');
		axcb=ft(thefig,'ColorBarAxes');
		colorbar(axcb);
		axes(axcb);a=axis;axis([a(1) a(2) ud.scale]);
		set(axcb,'Tag','ColorBarAxes');
    case 'ChangePoint1Bt',
		ax=ft(thefig,'WaveAxes');axes(ax);g=ginput(1);ud.map1loc=g(1);
		set(thefig,'userdata',ud); EPmapper('DrawMap1Loc',thefig);
    case 'ChangePoint2Bt',
		ax=ft(thefig,'WaveAxes');axes(ax);g=ginput(1);ud.map2loc=g(1);
		set(thefig,'userdata',ud); EPmapper('DrawMap2Loc',thefig);
    case 'ChangePoint3Bt',
		ax=ft(thefig,'WaveAxes');axes(ax);g=ginput(1);ud.map3loc=g(1);
		set(thefig,'userdata',ud); EPmapper('DrawMap3Loc',thefig);
	case 'GetPixel1Bt',
		ax=ft(thefig,'Axes1');axes(ax);g=ginput(1);
		set(ft(thefig,'PixelLocEdit'),'String',num2str(g([1 2]),3));
		EPmapper('CalcAbsPos',thefig);
	case 'GetPixel2Bt',
		ax=ft(thefig,'Axes2');axes(ax);g=ginput(1);
		set(ft(thefig,'PixelLocEdit'),'String',num2str(g([1 2]),3));
		EPmapper('CalcAbsPos',thefig);
	case 'GetPixel3Bt',
		ax=ft(thefig,'Axes3');axes(ax);g=ginput(1);
		set(ft(thefig,'PixelLocEdit'),'String',num2str(g([1 2]),3));
		EPmapper('CalcAbsPos',thefig);
	case 'ChangeScaleBt',
		ax=ft(thefig,'WaveAxes'); axes(ax); a=axis;
		ud.scale = a([3 4]);
		axis([ud.T(1) ud.T(end) ud.scale]);
		set(thefig,'userdata',ud);
		EPmapper('DrawSpatialMap1',thefig); EPmapper('DrawSpatialMap2',thefig);
		EPmapper('DrawSpatialMap3',thefig);
	case 'CalcAbsPos',
		mp = getscreentoolmonitorposition;
		p = str2num(get(ft(thefig,'PixelLocEdit'),'String'));
		NewStimGlobals;
		x=mp.MonPosX-18.0975+p(1)/NewStimPixelsPerCm;
		y=mp.MonPosY; z=mp.MonPosZ+32.0675-p(2)/NewStimPixelsPerCm;
		set(ft(thefig,'XYZEdit'),'string',num2str([x y z],3));
    case 'RunBt',
		  p = getparameters(ud.BS);
		  v = get(ft(thefig,'StimPopup'),'value');
		  v2 = get(ft(thefig,'StimShapePopup'),'value');
		  switch v,
			  case 1, p.value=[0 0 0];p.BG=[255 255 255];
			  case 2, p.value=[255 255 255];p.BG=[0 0 0];
		  end;
		  switch v2,
			  case 1, p.pixSize = [42 32];
			  case 2, p.pixSize = [21 60];
			  case 3, p.pixSize = [63 20];
		  end;
		  BSscript = append(stimscript(0),blinkingstim(p));
          b = transferscripts({'BSscript'},{BSscript});
          if b,
               dowait(0.5);
               b=runscriptremote('BSscript');
               if ~b,
                  errordlg('Could not run script--check RunExperiment window.');
               end;
               tn = get(ft(geteditor('RunExperiment'),'SaveDirEdit'),'String');
               set(ft(thefig,'TestEdit'),'String',tn);
          end;
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

h1 = EPmapperfig;

function filldefaults(h1,cksds,cellname)
set(h1,'Tag','EPmapper');

BS = blinkingstim('default');
p=getparameters(BS);
p.rect=[5 0 635 480];
p.pixSize = [ 42 32 ];
p.repeat = 40;
p.BG = [ 255 255 255]*0; p.value = [ 0 0 0 ]+255;
p.fps = 25;
p.random = 1;
p.dispprefs = {'BGpretime',2};
BS = blinkingstim(p);

ud = struct('BS',BS,'scale',[],'map1loc',0.040,'map2loc',0.090,...
            'map3loc',0.137);
set(h1,'userdata',ud);

