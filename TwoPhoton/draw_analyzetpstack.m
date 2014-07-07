function [fig,ud] = draw_analyzetpstack( record, analysis_parameters, process_parameters)
%DRAW_ANALYZETPSTACK creates gui figure for ANALYZETPSTACK
%
%  only to be used by ANALYZETPSTACK
%
% 2011, Alexander Heimel
%

ud.record = record;
ud.channel = 1;
%ud.ds = dirstruct(tpdatapath(ud.record));


ti = tpreadconfig( record );
if isempty(ti)
    fig = [];
    return
end

if isfield(ti,'third_axis_name') && ~isempty(ti.third_axis_name) && lower(ti.third_axis_name(1))=='z'
    ud.zstack = true;
else
    ud.zstack = false;
end

if ~isfield(analysis_parameters,'blind') || ~analysis_parameters.blind
    name = ['Analyze: ' ud.record.mouse ' ' ud.record.stack ' ' ud.record.epoch ' ' ud.record.slice];
else
    name = ['Analyze: record index ' num2str(analysis_parameters.record_index)];
end


figheight = 650;
figwidth = 630;
figleft = 381;
figtop = 217;

% get position from TP database
h_db = get_fighandle('TP database*');
if ~isempty(h_db)
    db_ud = get(h_db,'userdata');
    % move analyzetpstack to snugly find into TP database and record set
    % old_record_units = get(db_ud.record_form,'units');
    set(db_ud.record_form,'units','pixels');
    record_pos = get(db_ud.record_form,'position');
    figleft = record_pos(1)+record_pos(3);
    figtop = record_pos(2) + record_pos(4) - figheight;
end

fig = figure('name',name,'NumberTitle','off','menubar','none',...
    'Tag','analyzetpstack','position',[figleft figtop figwidth figheight]);

% define button style
button.Units = 'pixels';
button.BackgroundColor = [0.8 0.8 0.8];
button.HorizontalAlignment = 'center';
button.Callback = 'genercallback';
button.Style='pushbutton';

% define text style
txt.Units = 'pixels';
txt.BackgroundColor = [0.8 0.8 0.8];
%txt.fontsize = 12;
txt.fontname = 'arial';
txt.fontweight = 'normal';
txt.HorizontalAlignment = 'center';
txt.Style='text';

% define edit style
edit = txt;
edit.BackgroundColor = [ 1 1 1];
edit.Style = 'Edit';
edit.Enable = 'inactive'; % for enable_editclick_notification
%edit.Enable = 'on'; % for normal behavior

%define popup style
popup = txt;
popup.Style = 'popupmenu';

%define list style
listbox = button;
listbox.Style = 'list';

%define checkbox style
cb = txt;
cb.Style = 'Checkbox';
cb.Callback = 'genercallback';
%cb.fontsize = 12;

%define togglebutton style
tb = button;
tb.Style = 'ToggleButton';

%define slider style
slider = txt;
slider.Style = 'Slider';

panel_top = 0.99;
panel_left = 0.01;
panel_vmargin = 0.01;

% Preview panel
% image
if ud.zstack
    panel_width = 0.98;
else
    panel_width = 0.6;
end
panel_height = 0.59;
hi = uipanel('Title','','Position',[panel_left panel_top-panel_height panel_width panel_height],'tag','previewpanel','units','pixels','backgroundcolor',[0.8 0.8 0.8]);
panel_top = panel_top-panel_height-panel_vmargin;
% Zoom:
bgcolor = get(hi,'backgroundColor');
guicreate(tb,'String','','Tag','zoomBt','CData',iconread('zoom-in.png',bgcolor),...
    'Enable','on','left',0,'top','top_nomargin','width',24,'height',24,'parent',hi,'move','right');
guicreate(button,'String','','Tag','zoomOutBt','CData',iconread('zoom-original.png',bgcolor),'Enable','on','width',24,'height',24,'parent',hi,'move','right');

h=guicreate( txt,'Tag','zoomTxt','String','000x','visible','on','width','auto','move','right','parent',hi,'fontsize',8);

% Pan
guicreate(tb,'String','(P)an','Tag','panBt','Enable','on','width','auto','parent',hi,'move','right');

% Project Toggle
guicreate(tb,'String','Pro(j)ect','Tag','ZTProjectTB','value',1,'move','right','width','auto','parent',hi,'Enable','on');

g = get(gcf,'userdata');
left = g.guicreate.left; % to put frameslider at same location

guicreate(txt,'String','','width',1,'fontsize',8,'move','right','horizontalalignment','center','Tag','FirstFrameTxt','parent',hi);
    guicreate(edit,'String','1',...
        'horizontalalignment','center','width',20,'Tag',['FirstFrameEdit'],...
        'parent',hi,'callback','genercallback','move','right','fontsize',8,...
        'tooltipstring','First frame in projection');
guicreate(txt,'String',':','width',15,'fontsize',8,'move','right','horizontalalignment','center','Tag','LastFrameTxt','parent',hi);
    guicreate(edit,'String','inf',...
        'horizontalalignment','center','width',20,'Tag',['LastFrameEdit'],...
        'parent',hi,'callback','genercallback','move','right','fontsize',8,...
        'tooltipstring','Last frame in projection');

g = get(gcf,'userdata');
g.guicreate.left = left; % to put frameslider at same location
set(gcf,'userdata',g);

% FrameSlider
guicreate( txt,'Tag','frameTxt','String','000','visible','off','width','auto','move','right','parent',hi,'fontsize',8);
h = guicreate(slider,'Tag','FrameSlid','value',0.5,'visible','off','parent',hi,'callback','genercallback','move','right');
set(h,'Min',1)
set(h,'Max',ti.NumberOfFrames)
set(h,'Value',ceil(ti.NumberOfFrames/2));
set(h,'SliderStep',[1/ti.NumberOfFrames 0.1]);


axes('parent',hi,'position',[0 0.15 1 0.78],'Tag','tpaxes');

guicreate( txt,'String','','top','bottom','width','auto','move','right','parent',hi);

c2r = tp_channel2rgb(ud.record);



for ch = ti.NumberOfChannels:-1:1
    % Channel
%    guicreate( txt,'String','Ch','left','left','width','auto','fontsize',8,'move','right','parent',hi);
    h=guicreate(tb,'String',num2str(ch),'value',1,'left','left',...
        'horizontalalignment','center','callback','genercallback',...
        'Tag',['channel' num2str(ch) 'Tg'],'fontsize',8,'parent',hi,...
        'Enable','on','width',15,'move','right','tooltipstring','Channel toggle');

    bgcolor = [0 0 0];
    if ~isnan(c2r(ch))
        bgcolor(c2r(ch)) = 1;
        set(h,'backgroundcolor',bgcolor);
    end
    
    % Min value:
%    guicreate( txt,'String','Min','width','auto','move','right','fontsize',8,'parent',hi);
    guicreate(edit,'String',num2str(process_parameters.viewing_default_min(ch)),...
        'horizontalalignment','center','width',30,'Tag',['ColorMin' num2str(ch) 'Edit'],...
        'parent',hi,'callback','genercallback','move','right','fontsize',8,...
        'tooltipstring','Minimum value, set to -1 to set mode');
    % Max value:
%    guicreate( txt,'String','Max','width','auto','move','right','fontsize',8,'parent',hi);
    guicreate(edit,'String',num2str(process_parameters.viewing_default_max(ch)),...
        'horizontalalignment','center','width',30,'Tag',['ColorMax' num2str(ch) 'Edit'],...
        'parent',hi,'callback','genercallback','move','right','fontsize',8,...
        'tooltipstring','Maximum value, set to negative number to specify percentage to be saturated');
    % Gamma:
%    h=guicreate( txt,'String','g','width','auto','move','right','fontsize',8,'parent',hi);
%    set(h,'FontName','symbol');
    guicreate(edit,'String',num2str(process_parameters.viewing_default_gamma(ch)),...
        'horizontalalignment','center','width',30,...
        'parent',hi,'Tag',['ColorGamma' num2str(ch) 'Edit'],...
        'callback','genercallback','move','up','fontsize',8,'tooltipstring','Gamma value, set to -1 to bring mode to monitor threshold level');



end
%guicreate(txt,'String','Ch','left','left','width',15,'fontsize',8,'move','right','horizontalalignment','center','parent',hi);
%guicreate(txt,'String','Min','width',30,'fontsize',8,'move','right','horizontalalignment','center','parent',hi);
%guicreate(txt,'String','Max','width',30,'fontsize',8,'move','right','horizontalalignment','center','parent',hi);
%h = guicreate( txt,'String','g','width',25,'move','right','fontsize',8,'horizontalalignment','center','parent',hi);
%set(h,'FontName','symbol');


% ROI labels panel
panel_height = 0.37;
if ud.zstack
    panel_width = 0.6;
end
hroilabelspanel = uipanel('Title','ROIs','Position',[panel_left panel_top-panel_height panel_width panel_height],'units','pixels','backgroundcolor',[0.8 0.8 0.8],'Tag','roilabelspanel');

guicreate(tb,'String','(S)how','Tag','DrawROIsCB','left','left','top','top','move','right','width','auto','parent',hroilabelspanel);
guicreate(tb,'String','Nos','Tag','DrawROINosCB','move','right','width','auto','parent',hroilabelspanel);



fr=fields(tp_emptyroirec);
guicreate(txt,'String','Sort','Enable','on','width','auto','parent',hroilabelspanel,'move','right','fontsize',9);
guicreate(popup,'String',{fr{[1:5 7]}},'Tag','sortROIsBt','Enable','on','width',80,'parent',hroilabelspanel,'move','down','fontsize',9,'callback','genercallback');


h=guicreate(listbox,'height',110,'width',200,'left','left','Tag','celllist',...
    'callback','genercallback','move','down','fontname','Monospaced','fontsize',9,'parent',hroilabelspanel,'backgroundcolor',[1 1 1]);
set(h,'Max',2); % multiple ROIs can be selected


guicreate(button,'String','Draw','Tag','drawnewBt','Enable','on','left','left','width','auto','parent',hroilabelspanel,'move','right');
guicreate(button,'String','Auto','Tag','autoDrawCellsBt','Enable','on','width','auto','parent',hroilabelspanel,'move','right');
guicreate(button,'String','(C)ircles','Tag','drawnewballBt','Enable','on','width','auto','parent',hroilabelspanel,'move','right','fontsize',8);
if ud.zstack
    def_radius = 6;
else
    def_radius = 12;
end
guicreate(edit,'String',num2str(def_radius,'%02d'),'Tag','newballdiameterEdit','Enable','on','width','auto','parent',hroilabelspanel,'move','right');
guicreate(txt,'String','px','Enable','on','width','auto','parent',hroilabelspanel,'move','down','fontsize',8);
% draw neurite
guicreate(button,'String','Neurite','Tag','drawNeuriteBt','left','left','tooltipstring','Draw neurite','Enable','on','width','auto','parent',hroilabelspanel,'move','right');
% Snap to
guicreate(txt,'String','Snap','Enable','on','width','auto','parent',hroilabelspanel,'move','right');
if ti.NumberOfChannels>1
    snaptolist = ['no' cellfun(@num2str,num2cell(1:ti.NumberOfChannels,[ti.NumberOfChannels 1]), 'UniformOutput',false)];
else
    snaptolist = {'no','1'};
end
guicreate(popup,'String',snaptolist,...
   'Tag','snaptoPopup','Enable','on','width',35,'parent',hroilabelspanel,'move','right','callback','genercallback');

% Export
guicreate(button,'String','Export','Tag','exportROIsBt','Enable','on','tooltipstring','Export ROIs','width','auto','parent',hroilabelspanel,'move','down');

% link ROIs
guicreate(button,'String','Link all','Tag','linkROIsBt','Enable','on','left','left','tooltipstring','Link all ROIs based on distance','width','auto','parent',hroilabelspanel,'move','right');

% Index
guicreate(txt,'String','Index','Enable','on','width','auto','parent',hroilabelspanel,'move','right');
guicreate(edit,'String',num2str(ud.record.ROIs.new_cell_index,'%03d'),'Tag','newcellindexEdit',...
    'Enable','on','width','auto','parent',hroilabelspanel,'move','right','callback','genercallback');

% Synchronize
guicreate(cb,'String','Sync','value',0,'move','down',...
    'width',60,'Tag','syncCB','callback','genercallback','parent',hroilabelspanel);

% ROI draw panel
hroidrawpanel = uipanel('Title','ROI','Position',[panel_left+panel_width-0.22 panel_top-panel_height 0.22 panel_height],'units','pixels','backgroundcolor',[0.8 0.8 0.8],'tag','roidrawpanel');

guicreate(cb,'String','Present','value',1,'width',80,'left','left','top','top','Tag','presentCB',...
    'callback','genercallback','move','down','parent',hroidrawpanel);
guicreate(popup,'String',tpstacktypes(record),'Tag','cellTypePopup','Enable','on','left','left','width',100,'parent',hroidrawpanel,'move','down','callback','genercallback');
h=guicreate(listbox,'String',tpstacklabels(record),'Tag','labelList','Enable','on','left','left','height',45,'width',100,'parent',hroidrawpanel,'move','down','callback','genercallback','fontsize',9,'backgroundcolor',[1 1 1]);
set(h,'Max',2);

guicreate(button,'String','Redraw','Tag','redrawCellBt','Enable','on','width','auto','left','left','parent',hroidrawpanel,'move','right');
guicreate(button,'String','(M)ove','Tag','moveCellBt','Enable','on','width','auto','parent',hroidrawpanel,'move','down');
guicreate(button,'String','Delete','Tag','deletecellBt','left','left','Enable','on','width','auto','parent',hroidrawpanel,'move','right');
guicreate(button,'String','Renumber','Tag','setROIindexBt','Enable','on','tooltipstring','Set index to selected ROIs','width','auto','parent',hroidrawpanel,'move','down');

guicreate(button,'String','Max Z','Tag','maxzBt','Enable','on','left','left','width','auto','parent',hroidrawpanel,'move','right');
guicreate(txt,'String','chan','Enable','on','width','auto','parent',hroidrawpanel,'move','right');
guicreate(popup,'String',snaptolist,...
   'Tag','maxzPopup','Enable','on','width',35,'parent',hroidrawpanel,'move','down','callback','genercallback');

guicreate(button,'String','Link to idx','Tag','linkOneROIBt','Enable','on','left','left','tooltipstring','Link selected ROI to index','width','auto','parent',hroidrawpanel,'move','down');




% stack info
panel_left = panel_left + panel_width +0.01;
if ud.zstack
%    panel_top = 0.42;
else
    panel_top = 0.99;
end
panel_width = 1 - panel_width -0.02;
panel_height = 0.06;

hstackpanel = uipanel('Title','Stack','Position',[panel_left panel_top-panel_height panel_width panel_height],'units','pixels','backgroundcolor',[0.8 0.8 0.8],'tag','sidepanel');
panel_top = panel_top - panel_height - panel_vmargin;
%guicreate(button,'String','Load','Tag','loadBt','left','left','top','top','width','auto','move','right','parent',hstackpanel,'enable','off');
guicreate(button,'String','Save','Tag','saveBt','left','left','top','top','width','auto','move','right','parent',hstackpanel);
guicreate(button,'String','Clear','Tag','clearScratchBt','Tooltipstring','clear scratch','width','auto','move','right','parent',hstackpanel);
guicreate(button,'string','Info','Tag','infoBt','width','auto','move','right','parent',hstackpanel);
guicreate(button,'string','Help','Tag','HelpBt','width','auto','move','right','parent',hstackpanel);


% Reference panel
panel_height = 0.14;
hrefpanel = uipanel('Title','Reference','Position',[panel_left panel_top-panel_height panel_width panel_height],'units','pixels','backgroundcolor',[0.8 0.8 0.8],'tag','sidepanel');
panel_top = panel_top - panel_height - panel_vmargin;
guicreate(txt,'String','Epoch:','width','auto','left','left','top','top','move','right','parent',hrefpanel);
guicreate(edit,'String',record.ref_epoch,'Tag','ref_epochEdit','width',60,'callback','genercallback','parent',hrefpanel,'move','right');
guicreate(button,'String','Align','Tag','alignRefBt','width','auto','move','down','parent',hrefpanel);
guicreate(button,'String','Match','Tag','matchRefBt','width','auto','left','left','parent',hrefpanel,'move','right');
guicreate(cb,'String','Unique','value',1,'Tag','matchUniqueCB','tooltipstring','Only match ROIs with unmatched indices','parent',hrefpanel,'move','right','width',70);
guicreate(cb,'String','Linked','value',1,'Tag','matchLinkedCB','tooltipstring','Only match ROIs linked to neurites','parent',hrefpanel,'move','down','width',70);
guicreate(button,'String','Import ROIs','Tag','importRefROIsBt','left','left','width','auto','move','right','parent',hrefpanel);
guicreate(cb,'String','Check','Tag','checkMatchBt','value',0,'width',80,'move','right','parent',hrefpanel);

% Slice panel
panel_height=0.06;
hslicepanel = uipanel('Title',['Slice: ' record.slice],'Position',[panel_left panel_top-panel_height panel_width panel_height],'units','pixels','backgroundcolor',[0.8 0.8 0.8],'visible','off');
guicreate(listbox,'String','','height',20,'top','top','Tag','sliceList','callback','genercallback','move','right','parent',hslicepanel,'visible','off');

% Drift correction
panel_height=0.10;
if ud.zstack
    vis = 'off';
else
    panel_top = panel_top - panel_height - panel_vmargin;
    vis = 'on';
end
hdriftpanel = uipanel('Title','Drift','Position',[panel_left panel_top+panel_vmargin panel_width panel_height],'units','pixels','backgroundcolor',[0.8 0.8 0.8],'visible',vis,'tag','sidepanel');
if strcmp(vis,'on') % to counter strange visibility bug
 guicreate(txt,'String','Offset:','width','auto','move','right','left','left','top','top','parent',hdriftpanel,'visible',vis);
end
guicreate(edit,'String','[0 0]','Tag','sliceOffsetEdit','width','auto','move','right','callback','genercallback','parent',hdriftpanel,'visible',vis);
guicreate(popup, 'String',tpdriftcheck([],[],[],'?'),'Tag','driftcheckmethodPopup','width','auto','callback','genercallback','parent',hdriftpanel,'visible',vis);
guicreate(button,'String','Correct','Tag','correctDriftBt','width','auto','Enable','on','move','right','parent',hdriftpanel,'visible',vis);
guicreate(button,'String','Check','Tag','checkDriftBt','width','auto','Enable','on','parent',hdriftpanel,'visible',vis);

% Image process panel
if ud.zstack
    panel_height=0.10;
    himpro = uipanel('Title','Processing and analysis','Position',[panel_left panel_top-panel_height panel_width panel_height],'units','pixels','backgroundcolor',[0.8 0.8 0.8],'tag','sidepanel');
    panel_top = panel_top - panel_height - panel_vmargin;
    guicreate(tb,'String','Filter','Tag','spatialFilterBt','Value',double( process_parameters.spatial_filter),'left','left','top','top','width','auto','move','right','parent',himpro);
    guicreate(tb,'String','Unmix','Tag','unmixingBt','Value',double( process_parameters.unmixing) ,'width','auto','move','down','parent',himpro);
    guicreate(button,'String','Histogram','Tag','histogramBt','Value',0,'width','auto','left','left','move','right','parent',himpro);
    guicreate(button,'String','Analyse','move','right',...
        'width','auto','Tag','analyseBt','callback','genercallback',...
        'tooltipstring','Compute ROI measures','parent',himpro);
    guicreate(button,'String','Measures','move','right',...
        'width','auto','Tag','measuresBt','callback','genercallback',...
        'tooltipstring','Show ROI measures','parent',himpro);

    % guicreate(button,'String','Puncta','Tag','punctaBt','Value',0,'left','left','width','auto','move','right','parent',himpro);
end

% analysis
if ~ud.zstack
    panel_height=0.49;
    ha = uipanel('Title','Analysis','Position',[panel_left panel_top-panel_height panel_width panel_height],'Tag','sidepanel','units','pixels','backgroundcolor',[0.8 0.8 0.8]);
    panel_top = panel_top - panel_height - panel_vmargin; 
    guicreate(txt,'string','Channel:','width','auto','top','top','left','left','move','right','parent',ha);
    guicreate(edit,'string',num2str(ud.channel),'width',40,'Tag','stimChannelEdit','callback','genercallback','move','down','parent',ha);
    guicreate(txt,'string','Trials:','width','auto','left','left','move','right','parent',ha);
guicreate(edit,'string','','Tag','trialsEdit','width',50,'tooltipstring','blank for default','parent',ha,'move','right');
    guicreate(txt,'string','Epochs:','width','auto','move','right','parent',ha);
    guicreate(edit,'string','','Tag','epochsEdit','width',45,'tooltipstring','blank for default','parent',ha,'move','down');

guicreate(txt,'string','Intervals:','left','left','width','auto','move','right','parent',ha);
    guicreate(edit,'string','     ','Tag','timeintEdit','tooltipstring','[time int]','width','auto','move','right','parent',ha);
    guicreate(edit,'string','     ','Tag','sptimeintEdit','tooltipstring','[spont int]','width','auto','move','right','parent',ha);
    guicreate(txt,'string','Blank:','width','auto','move','right','parent',ha);
    guicreate(edit,'string','   ','Tag','BlankIDEdit','tooltipstring','empty for default','width','auto','parent',ha);
    guicreate(txt,'string','Process:','width','auto','move','right','parent',ha);
    guicreate(popup, 'String',tpsignalprocess('?'),'Tag','signalprocessPopup','width',100,'callback','genercallback','parent',ha);
%    guicreate(txt,'string','Filter:','left','left','width','auto','move','right','parent',ha);
%    guicreate(edit,'string',' 0 ','Tag','filterEdit','tooltipstring','number of frames to average, 0 for no filtering','width','auto','move','right','parent',ha);
%    guicreate(txt,'string','f ','width','auto','move','right','parent',ha);
    guicreate(cb,'string','Recompute','Tag','recomputeCB','left','left','width','auto','value',0,'parent',ha);
    guicreate(button,'string','Raw','Tag','AnalyzeRawBt','move','right','width','auto','parent',ha);
    guicreate(button,'string','Export','Tag','ExportRawBt','move','right','width','auto','parent',ha);
    guicreate(button,'string','Analyse','Tag','AnalyzeParamBt','width','auto','move','right','parent',ha);
    guicreate(button,'string','Results','Tag','ResultsBt','width','auto','move','down','parent',ha);
    guicreate(txt,'string','Variable','Tag','variableTxt','width','auto','left','left','move','right','parent',ha);
    guicreate(edit,'string','     ','Tag','stimparamnameEdit','tooltipstring','Variable to analyse, e.g. angle. Empty for default','width','auto','parent',ha,'move','right');
    guicreate(txt,'string','PSTH','Tag','QuickPSTHBt','width','auto','move','right','parent',ha);
%    guicreate(button,'string','PSTH','Tag','QuickPSTHBt','width','auto','left','left','move','right','parent',ha);
    guicreate(edit,'string','  1','Tag','QuickPSTHEdit','tooltipstring','Bin width (s)','width','auto','move','right','parent',ha);
    guicreate(txt,'string','s ','width','auto','move','down','parent',ha);
%    guicreate(cb,'string','Traces   ','Tag','QuickPSTHCB','width','auto','value',0,'parent',ha);
    guicreate(button,'string','ImageMath','Tag','ImageMathBt','left','left','width','auto','move','right','parent',ha);
    guicreate(edit,'string','1 - 5','Tag','ImageMathEdit','width','auto','parent',ha);
    guicreate(button,'string','Single conditions','Tag','singleCondBt','width','auto','left','left','move','right','parent',ha);
    guicreate(button,'string','Map','Tag','QuickMapBt','width','auto','move','right','tooltipstring','Color map based on tuning curve output','parent',ha);
    guicreate(edit,'string','0.05','Tag','mapthreshEdit','width','auto','tooltipstring','Map threshold','parent',ha);
    guicreate(button,'string','Movie','Tag','movieBt','width','auto','left','left','move','right','parent',ha);
    guicreate(edit,'string','     ','Tag','movieStimsEdit','width','auto','tooltipstring','Stims','move','right','parent',ha);
    guicreate(edit,'string','movie.avi','Tag','movieFileEdit','width','auto','tooltipstring','Movie filename','move','right','parent',ha);
    guicreate(cb,'string','dF','Tag','moviedFCB','tooltipstring','Show delta F','width','auto','value',0,'move','right','parent',ha);
    guicreate(cb,'string','Sort','Tag','movieSortCB','tooltipstring','Sorted','width','auto','value',0,'parent',ha);
    guicreate(button,'string','Analysis','Tag','AnalyzePatternsBt','width','auto','left','left','move','right','parent',ha);
    guicreate(popup, 'String',analyze_tppatterns('?'),'Tag','patternanalysisPopup','width',100,'callback','genercallback','parent',ha,'move','down');
    guicreate(button,'string','Stimulus','Tag','StimulusBt','width','auto','left','left','move','right','parent',ha);
end


% debug

panel_height=0.10;
hd = uipanel('Title','Output','Position',[panel_left panel_top-panel_height panel_width panel_height],'Tag','sidepanel','units','pixels','backgroundcolor',[0.8 0.8 0.8]);
panel_top = panel_top - panel_height - panel_vmargin; %#ok<NASGU>

% Verbose
guicreate(button,'String','Close figs','Tag','closeFiguresBt','left','left','top','top','width','auto','parent',hd,'move','right');

guicreate(cb,'String','Verbose','value',0,...
    'Tag','verboseCB','callback','genercallback','parent',hd,'move','right');



ud.persistent=1;
set_normalized_units( hi );
%set_normalized_units( fig );



function icon = iconread(fname,bgcolor)
icon = imread( fname );
icon(icon==0) = fix(mean(bgcolor)*255); % to change alpha channel to background


