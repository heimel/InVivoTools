function runexperiment(figureNum, record)
%  RUNEXPERIMENT(FIGURENUM, [RECORD])
%
%  RunExperiment takes over the figure FIGURENUM, and sets up a panel to
%  control our experimental setup.  The panel should be self-explanatory,
%  but maybe we'll actually write more documentatioshn someday.  Note that
%  the
%  figure is totally cleared by this routine.
%
% 2000-2003 Steve VanHooser
% 2004-2014 Alexander Heimel
%

remotecommglobals

if nargin<1
    figureNum = [];
end
if isempty(figureNum)
	% check to see if already open
	g = geteditor('RunExperiment');
	if isempty(g)
		g = figure;
	else
		return
	end
else
	g = figure(figureNum);
end
clf;
set(g,'Name','Run experiment','NumberTitle','off','MenuBar','none');

if nargin<2
    record.mouse = 'test';
    record.test = 't00001';
    record.datatype = 'ec';
    record.date = datestr(now,'yyyy-mm-dd');
    record.setup = host;
end
InVivoDataPathRem =  experimentpath(record,true,true);

InVivoRemoteDirPath = Remote_Comm_dir;

 % convert from the Mac % no longer necessary
%InVivoDataPath(find(InVivoDataPath==':'))='/';
%InVivoDataPath = [ '/home/' InVivoDataPath ];
%InVivoDataPath = InVivoDataPathRem;

SaveDir = 't00001';

% make the datapath folder if it does not exist - not necessary
%if exist(InVivoDataPath)~=7,
%	[thepath,thename]=fileparts(InVivoDataPath);
%	mkdir(thepath, thename);
%end;
%ss = -235+070;
%ds = -120+70;
%as = 0120+70;
%st = 0000+000;
%es = 0000;


figheight = 530;
figwidth = 430;
figleft = 381;
figtop = 217;

set(gcf,'WindowStyle','normal');
set(gcf,'Position',[figleft figtop figwidth figheight]);

panel_top = 0.99;
panel_left = 0.01;
panel_vmargin = 0.01;
panel_width = 0.98;

% define text style
txt.Style = 'text';
txt.FontSize = 12;
txt.FontWeight = 'normal';

% define edit style
edt.Style = 'edit';
edt.FontSize = 12;
edt.FontWeight = 'normal';

% define button style
button.Units = 'pixels';
button.BackgroundColor = [0.8 0.8 0.8];
button.HorizontalAlignment = 'center';
button.Style='pushbutton';

%define list style
listbox = button;
listbox.Style = 'list';

%define checkbox style
cb = txt;
cb.Style = 'Checkbox';
cb.Callback = 'genercallback';

% set up frame for data and analysis directories
panel_height = 0.14;
hpathpanel = uipanel('Title','Data','Position',[panel_left panel_top-panel_height panel_width panel_height ],'Units','pixels','backgroundcolor',[0.8 0.8 0.8]);
panel_top = panel_top - panel_height - panel_vmargin;  

% data path entry
guicreate(txt,'top','top','string','Path:','parent',hpathpanel,'move','right','left','left','top','top');
dp  = guicreate(edt,'String',InVivoDataPathRem,'width',300,...
	'Callback','runexpercallbk datapath','parent',hpathpanel,'move','down','fontsize',9);

% save directory entry
guicreate(txt,'string','Trial:','parent',hpathpanel,'move','right','left','left');
dpt  = guicreate(edt,'String',SaveDir,'width',300,...
	'Tag','SaveDirEdit','parent',hpathpanel,'fontsize',9);

% frame with NewStimGlobals
panel_height = 0.11;
hglobalspanel = uipanel('Title','Screen','Position',[panel_left panel_top-panel_height panel_width panel_height ],'Units','pixels','backgroundcolor',[0.8 0.8 0.8]);
panel_top = panel_top - panel_height - panel_vmargin;  


guicreate(txt,'string','Pixels per cm:','top','top','parent',hglobalspanel,'width','auto','move','right');
edtpixelspercm  = guicreate(edt,'String','','enable','off','width',40, ...
	'parent',hglobalspanel,'move','right');
guicreate(txt,'string','Distance (cm):','parent',hglobalspanel,'width','auto','move','right');
edtviewingdistance  = guicreate(edt,'String','','enable','off','width',40,...
	'parent',hglobalspanel,'move','right');

ap=[];

%%%%
% Acquisition list
panel_height = 0.19;
acq_frame = uipanel('Title','Acquisition list', ...
		'Position',[panel_left panel_top-panel_height panel_width panel_height ],'Units','pixels','backgroundcolor',[0.8 0.8 0.8]);
panel_top = panel_top - panel_height - panel_vmargin;  

% add
aqa = guicreate(button,'string','Add','parent',acq_frame,'width','auto', ...
    'move','right','top','top','left','left','Callback','runexpercallbk add_aq');

% edit button
aqe = guicreate(button,'string','Edit','parent',acq_frame,'width','auto', ...
    'move','right','Callback','runexpercallbk edit_aq');

% delete button
aqd = guicreate(button,'string','Delete','parent',acq_frame,'width','auto', ...
    'move','right','Callback','runexpercallbk delete_aq');

% open button
aqo = guicreate(button,'string','Open...','parent',acq_frame,'width','auto', ...
    'move','right','Callback','runexpercallbk open_aq');

% save button
aqs = guicreate(button,'string','Save...','parent',acq_frame,'width','auto', ...
    'move','down','Callback','runexpercallbk save_aq');

% entry field
aql = guicreate(listbox,'string',{},'parent',acq_frame,'left','left','width',410,'height',55,'UserData',{});

% Script editor frame
panel_height = 0.27;
hstimpanel = uipanel('Title','Stimulus', ...
		'Position',[panel_left panel_top-panel_height panel_width panel_height ],'Units','pixels','backgroundcolor',[0.8 0.8 0.8]);
panel_top = panel_top - panel_height - panel_vmargin;  

% remote directory entry
rsdl = guicreate(txt,'string','Path:','parent',hstimpanel,...
    'left','left','top','top','width','auto', ...
    'move','right');

% display remote directory
rsd = guicreate(edt,'string',InVivoRemoteDirPath,'parent',hstimpanel,'width',300, ...
    'move','down');

% duration
guicreate(txt,'string','Duration:','parent',hstimpanel,...
    'left','left','width','auto', ...
    'move','right');
ctdwn = guicreate(txt,'string','00:00','parent',hstimpanel,'width',100, ...
    'move','down');

rs=[];

% stimulus editor button
rtse = guicreate(button,'string','StimEditor','parent',hstimpanel,'width','auto', ...
    'Callback',...
    'if geteditor(''StimEditor''),figure(geteditor(''StimEditor''));else StimEditor;end;', ...
    'move','right','left','left');

% script editor button
rtse = guicreate(button,'string','ScriptEditor','parent',hstimpanel,'width','auto', ...
    'Callback',...
    'if geteditor(''ScriptEditor''),figure(geteditor(''ScriptEditor''));else ScriptEditor;end;',...
    'move','down');

% remote script editor button
rtse = guicreate(button,'string','RemoteScriptEditor','parent',hstimpanel,'width','auto', ...
    'Callback',...
    'if geteditor(''RemoteScriptEditor''),figure(geteditor(''RemoteScriptEditor''));else RemoteScriptEditor;end;', ...
    'move','right','left','left');

rsu = guicreate(button,'string','Update','parent',hstimpanel,'width','auto', ...
    'Callback',...
    'if geteditor(''RemoteScriptEditor''),RemoteScriptEditor(''UpdateRem'',geteditor(''RemoteScriptEditor''));else, RemoteScriptEditor; end;', ...
    'move','down');

% show script button
rssb = guicreate(button,'string','Show script','parent',hstimpanel,'width','auto', ...
    'Callback','runexpercallbk showstim',...
    'move','right','left','left','enable','off');

% acquire data button
swvs = guicreate(cb,'string','Acquire','parent',hstimpanel,'width',80, ...
    'Tag','AcquireDataCB','move','right');

rss=[];

rslb = guicreate(listbox,'string',{},'parent',hstimpanel,'top',100,'left',230,'width',180, ...
    'Callback','runexpercallbk EnDis',...
    'Tag','scriptlist','move','right','backgroundcolor',[1 1 1]);

panel_height = 0.23;
panel_width = panel_width/2 - 0.01;
extdevframe = uipanel('Title','Commands and devices', ...
		'Position',[panel_left panel_top-panel_height panel_width panel_height ],'Units','pixels','backgroundcolor',[0.8 0.8 0.8]);

extdevddbt = guicreate(button,'string','Add','parent',extdevframe,'width','auto', ...
    'callback','runexpercallbk extdevaddbt',...
	'Tag','extdevaddbt','move','right','top','top','left','left');

extdevdelbt = guicreate(button,'string','Del','parent',extdevframe,'width','auto', ...
    'callback','runexpercallbk extdevdelbt',...
	'Tag','extdevdelbt','move','right');

extdevaboutbt = guicreate(button,'string','Help','parent',extdevframe,'width','auto', ...
    'callback','runexpercallbk extdevaboutbt',...
	'Tag','extdevaboutbt','move','right');

extdevcb = guicreate(cb,'string','Enable','parent',extdevframe,'width',80, ...
	'Tag','extdevcb','value',0,'move','down');

extdevlist = guicreate(listbox,'string',{},'parent',extdevframe,'left','left','width',200, ...
    'Tag','extdevlist','move','down','backgroundcolor',[1 1 1]);
set(extdevlist,'string',{});
set(extdevlist,'max',2);
set(extdevlist,'value',[]);

  % special tools

toolsframe = uipanel('Title','Tools', ...
		'Position',[panel_left+panel_width+0.02 panel_top-panel_height panel_width panel_height ],'Units','pixels','backgroundcolor',[0.8 0.8 0.8]);
panel_top = panel_top - panel_height - panel_vmargin;  

screentool_ctl = guicreate(button,'string','Screentool','parent',toolsframe,'width','auto', ...
    'Callback', 'if geteditor(''screentool''),figure(geteditor(''screentool''));else, screentool(figure); end;',...
    'move','right','left','left','top','top');

simplevisassess = guicreate(button,'string','VisAssess','parent',toolsframe,'width','auto', ...
    'Callback','simplevisassesstool(figure)',...
    'move','down');

scriptstxt = guicreate(txt,'string','Scripts','parent',toolsframe,'width','auto', ...
    'move','right','left','left');

newpsstim = guicreate(button,'string','PS','parent',toolsframe,'width','auto', ...
    'Callback',...
	'if ~exist(''PS'')|isempty(PS),PS=periodicscript(''default'');end;[rr,dd,sr]=getscreentoolparams;if ~isempty(rr),PS=recenterstim(PS,{''rect'',rr,''screenrect'',sr,''params'',1});end;PS=periodicscript(''graphical'',PS);UpdateNewStimEditors;',...
    'move','right');

newsgstim = guicreate(button,'string','SG','parent',toolsframe,'width','auto', ...
    'Callback',...
	'if ~exist(''sg'')|isempty(sg),sg=stochasticgridstim(''default'');end;[rr,dd,sr]=getscreentoolparams;if ~isempty(rr),sg=recenterstim(sg,{''rect'',rr,''screenrect'',sr,''params'',1});end;sg=stochasticgridstim(''graphical'',sg);if ~isempty(sg),SG=stimscript(1);SG=append(SG,sg);else, clear SG; end;UpdateNewStimEditors;',...
    'move','right');

censur = guicreate(button,'string','CentSurr','parent',toolsframe,'width','auto', ...
    'Callback',...
	'if ~exist(''css'')|isempty(css),css=centersurroundstim(''default'');end;[rr,dd,sr]=getscreentoolparams;if ~isempty(rr),cssp=getparameters(css);cssp.center=0.5*[rr(3)+rr(1) rr(2)+rr(4)];css=centersurroundstim(cssp);end;centersurrounds;',...
    'move','down');

panelstxt = guicreate(txt,'string','Panels','parent',toolsframe,'width','auto', ...
    'move','right','left','left');

lgnex = guicreate(button,'string','LGN','parent',toolsframe,'width','auto', ...
    'Callback','lgnexperpanel','move','right');

ctxex = guicreate(button,'string','Cortex','parent',toolsframe,'width','auto', ...
    'Callback','ctxexperpanel','move','down');

guicreate(button,'string','Quick analyse','parent',toolsframe,'width','auto', ...
    'Callback','runexpercallbk datapath;fsapu',...
    'move','right','left','left');

guicreate(button,'string','Close figs','parent',toolsframe,'width','auto', ...
    'Callback','close_figs','move','right');

data = struct('datapath',dp,'savedir',dpt,'analpath',ap,'runscript',rs, ...
	'remotepath',rsd,'showstim',rss,'savestims',swvs, 'list_aq',aql,...
	'add_aq',aqa,'edit_aq',aqe,'delete_aq',aqd,'open_aq',aqo,...,
	'edtpixelspercm',edtpixelspercm,'edtviewingdistance',edtviewingdistance,...
	'save_aq',aqs,'rslb',rslb,'rssb',rssb,'ctdwn',ctdwn,'tag','RunExperiment',...
	'cksds',[],'persistent',1);
set(gcf,'UserData',data);

% default acquistion list
setrunexperiment_default_acquisition( aql,record);

fig = gcf;
runexpercallbk('datapath',fig);  
