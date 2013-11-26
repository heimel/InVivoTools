function runexperiment(figureNum, datapath, analysispath, remotedirpath)
%  RUNEXPERIMENT(FIGURENUM, DATAPATH, ANALYSISPATH, REMOTEDIRPATH)
%
%  Note:  Opens the experiment panel for NelsonLabTools
%
%  RunExperiment takes over the figure FIGURENUM, and sets up a panel to
%  control our experimental setup.  The panel should be self-explanatory,
%  but maybe we'll actually write more documentation someday.  Note that
%  the
%  figure is totally cleared by this routine.
%
%  There are three optional arguments:  DATAPATH, ANALYSISPATH, and
%  REMOTEDIRPATH.  These provide initial values for the data path, analysis
%  path, and REMOTEDIRPATH.  Otherwise, the system default values are chosen.
%
% 2000-2003 Steve VanHooser
% 2004-2012 Alexander Heimel
%


  % add the path of the callback function, platform independent
loc = which('RunExperiment');
li = find(loc==filesep); loc = loc(1:li(end)-1);
addpath([loc filesep 'panelcallbacks' filesep]);

if nargin<1
    figureNum = [];
end
if isempty(figureNum)
	% check to see if already open
	g = geteditor('RunExperiment');
	if isempty(g)
		g=figure;
	else
		return
	end
else
	g = figure(figureNum);
end
clf;
set(g,'Name','Run experiment','NumberTitle','off','MenuBar','none');

global initdatapathNLT initanalysispathNLT initremotedirpathNLT;

if nargin>1,
	InVivoDataPathRem = datapath;
else
	% get current date and create dated folder in dataman/data/Y-M-D
	[Y,M,D] = datevec(date);
    datepartdir=[num2str(Y,'%.4i') filesep num2str(M,'%.2i') filesep ...
        num2str(D,'%.2i') ];
    
	InVivoDataPathRem = [initdatapathNLT datepartdir];
	dummy=1;
	try
        [dummy,str] = dos('whoami');
    end;
end;
if nargin>2
	InVivoAnalysisPath = analysispath;
else
    InVivoAnalysisPath = initanalysispathNLT; % analysis path not used right now anyway
end
if nargin>3
    InVivoRemoteDirPath = remotedirpath;
else
	InVivoRemoteDirPath = initremotedirpathNLT;
end

 % convert from the Mac % no longer necessary
%InVivoDataPath(find(InVivoDataPath==':'))='/';
%InVivoDataPath = [ '/home/' InVivoDataPath ];

InVivoDataPath = InVivoDataPathRem;
SaveDir = 't00001';

% make the datapath folder if it does not exist - not necessary
%if exist(InVivoDataPath)~=7,
%	[thepath,thename]=fileparts(InVivoDataPath);
%	mkdir(thepath, thename);
%end;
ss = -235+070;
ds = -120+70;
as = 0120+70;
st = 0000+000;
es = 0000;


figheight = 530;
figwidth = 430;
figleft = 381;
figtop = 217;

set(gcf,'Position',[figleft figtop figwidth figheight]);

panel_top = 0.99;
panel_left = 0.01;
panel_vmargin = 0.01;
panel_width = 0.98;

% define text style
txt.Style = 'text';
txt.FontSize = 12;
txt.FontWeight = 'normal';
%txt.Units = 'point';

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

% aqe = uicontrol('Style','pushbutton','String','Edit','Units','point',...
% 	'Position',[220 215+as 60 20], 'fontsize',14,'fontweight','bold', ...
% 	'HorizontalAlignment','center','Callback','runexpercallbk edit_aq');

% delete button
aqd = guicreate(button,'string','Delete','parent',acq_frame,'width','auto', ...
    'move','right','Callback','runexpercallbk delete_aq');
% aqd = uicontrol('Style','pushbutton','String','Delete','Units','point',...
% 	'Position',[290 215+as 60 20],'fontsize',14,'fontweight','bold',...
% 	'HorizontalAlignment','center','Callback','runexpercallbk delete_aq');

% open button
aqo = guicreate(button,'string','Open...','parent',acq_frame,'width','auto', ...
    'move','right','Callback','runexpercallbk open_aq');
% aqo = uicontrol('Style','pushbutton','String','Open...','Units','point',...
% 	'Position',[360 215+as 60 20],'fontsize',14,'fontweight','bold',...
% 	'HorizontalAlignment','center','Callback','runexpercallbk open_aq');

% save button
% aqs = uicontrol('Style','pushbutton','String','Save...','Units','point',...
% 	'Position',[430 215+as 60 20],'fontsize',14,'fontweight','bold',...
% 	'HorizontalAlignment','center','Callback','runexpercallbk save_aq');
aqs = guicreate(button,'string','Save...','parent',acq_frame,'width','auto', ...
    'move','down','Callback','runexpercallbk save_aq');

% entry field
% aql = uicontrol('Style','listbox','String',{},'Units','point', ...
% 	'Position',[35 135+as 500 75],'fontweight','normal','fontsize',12,...
% 	'HorizontalAlignment','left','BackgroundColor',[1 1 1],'UserData',{});

aql = guicreate(listbox,'string',{},'parent',acq_frame,'left','left','width',410,'height',55,'UserData',{});


% Script editor frame
panel_height = 0.27;
hstimpanel = uipanel('Title','Stimulus', ...
		'Position',[panel_left panel_top-panel_height panel_width panel_height ],'Units','pixels','backgroundcolor',[0.8 0.8 0.8]);
panel_top = panel_top - panel_height - panel_vmargin;  


% scriptframe = uicontrol('Style','frame','Units','point',  ...
% 			'Position', [10 370+ss 550 110]);

% remote directory entry
% rsdl= uicontrol('Style','text','String','Remote Dir', 'Units','point',...
% 	'Position',[220 449+ss 125 20],'fontsize',14,'fontweight','bold', ...
% 	'HorizontalAlignment','left');
rsdl = guicreate(txt,'string','Path:','parent',hstimpanel,...
    'left','left','top','top','width','auto', ...
    'move','right');

% display remote directory
% rsd = uicontrol('Style','edit','String',InVivoRemoteDirPath,'Units','point',...
% 	'Position',[327 452+ss 200 25],'fontsize',14,'fontweight','normal',...
% 	'HorizontalAlignment','left');
rsd = guicreate(edt,'string',InVivoRemoteDirPath,'parent',hstimpanel,'width',300, ...
    'move','down');


% duration
guicreate(txt,'string','Duration:','parent',hstimpanel,...
    'left','left','width','auto', ...
    'move','right');
ctdwn = guicreate(txt,'string','00:00','parent',hstimpanel,'width',100, ...
    'move','down');

% ctdwn=uicontrol('Style','text','String','','Units','points',...
% 	'Position',[240 425+ss 250 20],'HorizontalAlignment','center');



%rsl = uicontrol('Style','text','String','Run Script:','Units','point', ...
%	'Position',[20 418+ss 125 20],'fontsize',14,'fontweight','bold', ...
%	'HorizontalAlignment','left');

rs=[];
%rs  = uicontrol('Style','edit','String','','Units','point', ...
%	'Position',[127 420+ss 350 25],'fontsize',14,'fontweight','normal', ...
%	'HorizontalAlignment','left');

rsb=[];

% stimulus editor button
% rtse= uicontrol('Style','pushbutton','String','StimEditor','Units','point', ...
% 	'Position',[215 407+ss 100 19],'fontweight','bold', ...
% 	'HorizontalAlignment','center','Callback',...
%         'if geteditor(''StimEditor''),figure(geteditor(''StimEditor''));else StimEditor;end;');
rtse = guicreate(button,'string','StimEditor','parent',hstimpanel,'width','auto', ...
    'Callback',...
    'if geteditor(''StimEditor''),figure(geteditor(''StimEditor''));else StimEditor;end;', ...
    'move','right','left','left');


% update button
% rsu = uicontrol('Style','pushbutton','String','Update','Units','point', ...
% 	'Position',[215 387+ss 100 19],'fontweight','bold', ...
% 	'HorizontalAlignment','center','Callback',...
% 	'if geteditor(''RemoteScriptEditor''),RemoteScriptEditor(''UpdateRem'',geteditor(''RemoteScriptEditor''));else, RemoteScriptEditor; end;');
% 

%rssl= uicontrol('Style','text','String','Show StimScript:','Units','point', ...
%	'Position',[20 383+ss 150 20],'fontsize',14,'fontweight','bold', ...
%	'HorizontalAlignment','left');

% script editor button
% rtse= uicontrol('Style','pushbutton','String','ScriptEditor','Units','point', ...
% 	'Position',[315 407+ss 100 19],'fontweight','bold', ...
% 	'HorizontalAlignment','center','Callback',...
rtse = guicreate(button,'string','ScriptEditor','parent',hstimpanel,'width','auto', ...
    'Callback',...
    'if geteditor(''ScriptEditor''),figure(geteditor(''ScriptEditor''));else ScriptEditor;end;',...
    'move','down');


% remote script editor button
% rtse= uicontrol('Style','pushbutton','String','RemoteScriptEditor','Units','point', ...
% 	'Position',[420 407+ss 100 19],'fontweight','bold', ...
% 	'HorizontalAlignment','center','Callback',...
%         'if geteditor(''RemoteScriptEditor''),figure(geteditor(''RemoteScriptEditor''));else RemoteScriptEditor;end;');
rtse = guicreate(button,'string','RemoteScriptEditor','parent',hstimpanel,'width','auto', ...
    'Callback',...
        'if geteditor(''RemoteScriptEditor''),figure(geteditor(''RemoteScriptEditor''));else RemoteScriptEditor;end;', ...
        'move','right','left','left');

    rsu = guicreate(button,'string','Update','parent',hstimpanel,'width','auto', ...
    'Callback',...
	'if geteditor(''RemoteScriptEditor''),RemoteScriptEditor(''UpdateRem'',geteditor(''RemoteScriptEditor''));else, RemoteScriptEditor; end;', ...
    'move','down');

    
% show script button
% rssb= uicontrol('Style','pushbutton','String','Show Script','Units','point', ...
% 	'Position',[420 387+ss 100 19],'fontsize',14,'fontweight','bold', ...
% 	'HorizontalAlignment','center','enable','off','Callback','runexpercallbk showstim');
rssb = guicreate(button,'string','Show script','parent',hstimpanel,'width','auto', ...
    'Callback','runexpercallbk showstim',...
    'move','right','left','left','enable','off');


% acquire data button
% swvs= uicontrol('Style','checkbox','String','Acquire Data','Units','point',...
% 	'Position',[315 387+ss 100 19],'fontweight','bold',...
% 	'HorizontalAlignment','left','Tag','AcquireDataCB');
swvs = guicreate(cb,'string','Acquire','parent',hstimpanel,'width',80, ...
    'Tag','AcquireDataCB','move','right');

rss=[];


% rslb=uicontrol('Style','listbox','String',{},'Units','point','Position',...
% 	[420 380+ss 180 90],'Background',[1 1 1],...
%         'Callback','runexpercallbk EnDis','Tag','scriptlist');

rslb = guicreate(listbox,'string',{},'parent',hstimpanel,'top',100,'left',230,'width',180, ...
    'Callback','runexpercallbk EnDis',...
    'Tag','scriptlist','move','right','backgroundcolor',[1 1 1]);
%set(rslb,'Position',[300 100 9 100])


panel_height = 0.23;
panel_width = panel_width/2 - 0.01;
extdevframe = uipanel('Title','Commands and devices', ...
		'Position',[panel_left panel_top-panel_height panel_width panel_height ],'Units','pixels','backgroundcolor',[0.8 0.8 0.8]);

% 
% extdevframe = uicontrol('Style','frame','Units','point',...
% 	'Position',[10 135+es 550 65]);

% extdevlist=uicontrol('Style','listbox','String',{},'Units','point',...
% 	'Position',[20 140+es 180 55],'Background',[1 1 1],'Tag','extdevlist',...
% 	'max',2,'value',[]);


extdevddbt = guicreate(button,'string','Add','parent',extdevframe,'width','auto', ...
    'callback','runexpercallbk extdevaddbt',...
	'Tag','extdevaddbt','move','right','top','top','left','left');

extdevdelbt = guicreate(button,'string','Del','parent',extdevframe,'width','auto', ...
    'callback','runexpercallbk extdevdelbt',...
	'Tag','extdevdelbt','move','right');

% extdevdelbt=uicontrol('Style','pushbutton','String','Delete','fontweight','bold',...
% 	'units','points','position',[300 150+es 70 18],'callback','runexpercallbk extdevdelbt',...
% 	'Tag','extdevdelbt');

extdevaboutbt = guicreate(button,'string','Help','parent',extdevframe,'width','auto', ...
    'callback','runexpercallbk extdevaboutbt',...
	'Tag','extdevaboutbt','move','right');

% extdevaboutbt=uicontrol('Style','pushbutton','String','Help','fontweight','bold',...
% 	'units','points','position',[375 150+es 70 18],'callback','runexpercallbk extdevaboutbt',...
% 	'Tag','extdevaboutbt');
% extdevcb=uicontrol('Style','checkbox','String','Enable EC/Ds','fontweight','bold',...
% 	'units','points','position',[450 150+es 90 18],'Tag','extdevcb','value',1);

extdevcb = guicreate(cb,'string','Enable','parent',extdevframe,'width',80, ...
	'Tag','extdevcb','value',0,'move','down');


extdevlist = guicreate(listbox,'string',{},'parent',extdevframe,'left','left','width',200, ...
    'Tag','extdevlist','move','down','backgroundcolor',[1 1 1]);
set(extdevlist,'string',{});
set(extdevlist,'max',2);
set(extdevlist,'value',[]);


%extdevlist=uicontrol('Style','listbox','String',{},'Units','point',...
%	'Position',[20 140+es 180 55],'Background',[1 1 1],'Tag','extdevlist',...
%	'max',2,'value',[]);


% extdevlab=uicontrol('Style','text','String','Extra commands/devices',...
% 	'units','points','position',[200 175+es 200 20],'fontsize',14,'fontweight','bold');
% extdevaddbt=uicontrol('Style','pushbutton','String','Add','fontweight','bold',...
% 	'units','points','position',[225 150+es 70 18],'callback','runexpercallbk extdevaddbt',...
% 	'Tag','extdevaddbt');

  % special tools

toolsframe = uipanel('Title','Tools', ...
		'Position',[panel_left+panel_width+0.02 panel_top-panel_height panel_width panel_height ],'Units','pixels','backgroundcolor',[0.8 0.8 0.8]);
panel_top = panel_top - panel_height - panel_vmargin;  

%   
% toolsframe = uicontrol('Style','frame','Units','point', ...
% 	'Position',[10 18+st 550 110]);

% stlab= uicontrol('Style','text','String','Useful tools:', 'Units','point',...
% 	'Position',[18 100+st 125 20],'fontsize',14,'fontweight','bold', ...
% 	'HorizontalAlignment','left');

screentool_ctl = guicreate(button,'string','Screentool','parent',toolsframe,'width','auto', ...
    'Callback', 'if geteditor(''screentool''),figure(geteditor(''screentool''));else, screentool(figure); end;',...
    'move','right','left','left','top','top');
% 
% screentool_ctl = uicontrol('Style','pushbutton','String','Screen Tool',...
% 	'Position',[30 75 90 20],'fontweight','bold', ...
% 	'Callback', 'if geteditor(''screentool''),figure(geteditor(''screentool''));else, screentool(figure); end;');

% simplevisassess= uicontrol('Style','pushbutton','String','SimpleVisAssess',...
% 	'Position',[130 75 120 20],'fontweight','bold',...
% 	'Callback','simplevisassesstool(figure)');

simplevisassess = guicreate(button,'string','VisAssess','parent',toolsframe,'width','auto', ...
    'Callback','simplevisassesstool(figure)',...
    'move','down');



scriptstxt = guicreate(txt,'string','Scripts','parent',toolsframe,'width','auto', ...
    'move','right','left','left');

newpsstim = guicreate(button,'string','PS','parent',toolsframe,'width','auto', ...
    'Callback',...
	'if ~exist(''PS'')|isempty(PS),PS=periodicscript(''default'');end;[rr,dd,sr]=getscreentoolparams;if ~isempty(rr),PS=recenterstim(PS,{''rect'',rr,''screenrect'',sr,''params'',1});end;PS=periodicscript(''graphical'',PS);UpdateNewStimEditors;',...
    'move','right');

% newpsstim = uicontrol('Style','pushbutton','String','New PS','Position',...
% 	[260 75 60 20],'fontweight','bold','Callback',...
% 	'if ~exist(''PS'')|isempty(PS),PS=periodicscript(''default'');end;[rr,dd,sr]=getscreentoolparams;if ~isempty(rr),PS=recenterstim(PS,{''rect'',rr,''screenrect'',sr,''params'',1});end;PS=periodicscript(''graphical'',PS);UpdateNewStimEditors;');
% 
% newsgstim = uicontrol('Style','pushbutton','String','New SG','Position',...
% 	[330 75 60 20],'fontweight','bold','Callback',...
% 	'if ~exist(''sg'')|isempty(sg),sg=stochasticgridstim(''default'');end;[rr,dd,sr]=getscreentoolparams;if ~isempty(rr),sg=recenterstim(sg,{''rect'',rr,''screenrect'',sr,''params'',1});end;sg=stochasticgridstim(''graphical'',sg);if ~isempty(sg),SG=stimscript(1);SG=append(SG,sg);else, clear SG; end;UpdateNewStimEditors;');


newsgstim = guicreate(button,'string','SG','parent',toolsframe,'width','auto', ...
    'Callback',...
	'if ~exist(''sg'')|isempty(sg),sg=stochasticgridstim(''default'');end;[rr,dd,sr]=getscreentoolparams;if ~isempty(rr),sg=recenterstim(sg,{''rect'',rr,''screenrect'',sr,''params'',1});end;sg=stochasticgridstim(''graphical'',sg);if ~isempty(sg),SG=stimscript(1);SG=append(SG,sg);else, clear SG; end;UpdateNewStimEditors;',...
    'move','right');

% 
% censur = uicontrol('Style','pushbutton','String','centsurr','Position',...
% 	[470 75 60 20],'fontweight','bold','Callback',...
% 	'if ~exist(''css'')|isempty(css),css=centersurroundstim(''default'');end;[rr,dd,sr]=getscreentoolparams;if ~isempty(rr),cssp=getparameters(css);cssp.center=0.5*[rr(3)+rr(1) rr(2)+rr(4)];css=centersurroundstim(cssp);end;centersurrounds;');

censur = guicreate(button,'string','CentSurr','parent',toolsframe,'width','auto', ...
    'Callback',...
	'if ~exist(''css'')|isempty(css),css=centersurroundstim(''default'');end;[rr,dd,sr]=getscreentoolparams;if ~isempty(rr),cssp=getparameters(css);cssp.center=0.5*[rr(3)+rr(1) rr(2)+rr(4)];css=centersurroundstim(cssp);end;centersurrounds;',...
    'move','down');


panelstxt = guicreate(txt,'string','Panels','parent',toolsframe,'width','auto', ...
    'move','right','left','left');

lgnex = guicreate(button,'string','LGN','parent',toolsframe,'width','auto', ...
    'Callback','lgnexperpanel','move','right');

% lgnex=uicontrol('Style','pushbutton','String','LGN panel',...
%     'Position',[30 50 90 20],'fontweight','bold','callback','lgnexperpanel');

ctxex = guicreate(button,'string','Cortex','parent',toolsframe,'width','auto', ...
    'Callback','ctxexperpanel','move','down');

% ctxex=uicontrol('Style','pushbutton','String','Cortex panel',...
%     'Position',[130 50 90 20],'fontweight','bold','callback','ctxexperpanel');

% mlex=uicontrol('Style','pushbutton','String','ML panel',...
%     'Position',[230 50 90 20],'fontweight','bold','callback','mlexperpanel');

% lgnctxex=uicontrol('Style','pushbutton','String','LGN/CTX panel',...
%    'Position',[330 50 90 20],'fontweight','bold','callback','lgnctxexperpanel');

% fast sloppy analysis popper-upper button
% fsapu = uicontrol('Style','pushbutton','String','FSAPU','Position',...
% 	[400 75 60 20],'fontweight','bold','Callback','runexpercallbk datapath;fsapu');

fsapu = guicreate(button,'string','Quick analyse','parent',toolsframe,'width','auto', ...
    'Callback','runexpercallbk datapath;fsapu',...
    'move','right','left','left');


closefigs = guicreate(button,'string','Close figs','parent',toolsframe,'width','auto', ...
    'Callback','close_figs','move','right');

% closefigs=uicontrol('Style','pushbutton','String','Close figs',...
%    'Position',[430 50 90 20],'fontweight','bold','callback',...
%    ['close_figs']);


data = struct('datapath',dp,'savedir',dpt,'analpath',ap,'runscript',rs, ...
	'remotepath',rsd,'showstim',rss,'savestims',swvs, 'list_aq',aql,...
	'add_aq',aqa,'edit_aq',aqe,'delete_aq',aqd,'open_aq',aqo,...,
	'edtpixelspercm',edtpixelspercm,'edtviewingdistance',edtviewingdistance,...
	'save_aq',aqs,'rslb',rslb,'rssb',rssb,'ctdwn',ctdwn,'tag','RunExperiment',...
	'cksds',[],'persistent',1);
set(gcf,'UserData',data);

% default acquistion list
setrunexperiment_default_acquisition( aql );

fig = gcf;
runexpercallbk('datapath',fig);  % don't do this, let user do it by hitting return
