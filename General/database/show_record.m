function handle = show_record( record, h_fig, h_control_fig, name )
%SHOW_RECORD used in database tools to show record figure
%
% HANDLE = SHOW_RECORD( RECORD,H_FIG,H_CONTROL_FIG,NAME)
%
% 2004-2024, Alexander Heimel

if nargin<4 || isempty(name)
    name = 'Record';
end

if nargin<2
    h_fig = [];
end
if nargin<3 || isempty(h_control_fig)
    bc = 0.8*[1 1 1];
    h_control_fig = [];
else
    bc = get(h_control_fig,'Color');
end

comment_lines = 3;

if isempty(h_fig)
    screensize = get(0,'ScreenSize');
    fields = fieldnames(record);

    params = db_default_parameters(record);

    if ~isempty(h_control_fig)
        udc = get(h_control_fig,'userdata');
        if isfield(udc,'basefontsize') && ~isempty(udc.basefontsize)
            fontsize = udc.basefontsize;
            colsep = udc.colsep;
        end
    else
        fontsize = 12; % pt
        colsep = 3;
    end

    labelleft = 2 * params.db_colsep; % pxl
    labelwidth = min(params.db_max_labelwidth,10*1.33*fontsize); % pxl
    editwidth = min(params.db_max_editwidth,20*1.33*fontsize); % pxl

    editheight = round(fontsize * 1.33 + 2*colsep); % pxl
    labelheight = editheight - colsep; % pxl
    linesep = 1; % pxl
    lineheight = editheight + linesep;
    colwidth = labelleft + labelwidth + editwidth + 3*colsep;
    
    height = (length(fields)+...
        (comment_lines-1)*sum(strncmp('comment',fields,6)))*lineheight + colsep;
    
    top = height-editheight-linesep-colsep;
    
    h_fig = figure('Name',name,...
        'WindowStyle','normal',...
        'Color',bc,...
        'PaperPosition',[18 180 576 432], ...
        'PaperUnits','points', ...
        'Position',[(screensize(3)-colwidth)/2 (screensize(4)-height)/2 colwidth height], ...
        'Tag','', ...
        'Units','pixels',...
        'ToolBar','none');
    set(h_fig,'MenuBar','none');
    set(h_fig,'NumberTitle','off');
    if ~isempty(h_control_fig)
        set(h_fig,'CloseRequestFcn','udl=get(gcf,''userdata'');ud=get(udl.db_form,''UserData'');control_db_callback(ud.h.close)');
    end
    
    for i=1:length(fields)
        left = labelleft;
        h_text(i) =...
            uicontrol('Parent',h_fig, ...
            'Units','pixels', ...
            'BackgroundColor',bc,...
            'ListboxTop',0, ...
            'Position',[left top+ceil(fontsize*0.4) labelwidth labelheight], ... % top+2
            'String',fields{i}, ...
            'HorizontalAlignment','right',...
            'Style','text', ...
            'Units','pixels',...
            'Fontname','SansSerif',...
            'FontSize',fontsize,...
            'Tag',fields{i}); %#ok<AGROW,NASGU>
        
        left = left+labelwidth+colsep;
        if ~strcmp(fields{i},'comment')
            h_edit(i)= ...
                uicontrol('Parent',h_fig, ...
                'Units','pixels', ...
                'BackgroundColor',[1 1 1],...
                'ListboxTop',0, ...
                'Position',[left top+2 editwidth editheight], ...
                'String','', ...
                'HorizontalAlignment','left',...
                'Style','edit', ...
                'Units','pixels',...
                'FontSize',fontsize,...
                'Callback','genercallback',...
                'Tag',[ fields{i} ]); %#ok<AGROW>
            top = top-lineheight;
        else
            top = top-(comment_lines-1)*lineheight-linesep;
            h_edit(i)= ...
                uicontrol('Parent',h_fig, ...
                'Units','pixels', ...
                'BackgroundColor',[1 1 1],...
                'ListboxTop',0, ...
                'Position',[left top+2 editwidth lineheight*comment_lines], ...
                'String','', ...
                'HorizontalAlignment','left',...
                'Style','edit', ...
                'FontSize',fontsize,...
                'Units','pixels',...
                'max',comment_lines,...
                'min', 0,...
                'Callback','genercallback',...
                'Tag',[ fields{i} ]); %#ok<AGROW>
            top = top - lineheight;
        end
    end % fields i
    ud.h_edit = h_edit;
    set(h_fig,'Userdata',ud);
end

% fill form
fields=fieldnames(record);
for i=1:length(fields)
    ud = get(h_fig,'Userdata');
    h_edit = ud.h_edit;
    content = record.(fields{i});
    if islogical(content)
        content = double(content);
    end
    if isnumeric(content)
        if ~isempty(content) && ismatrix(content)
            content = mat2str(content,10);
        else
            content = '';
        end
    end
    if iscell(content)
        content = wimpcell2str(content);
    end
    if ~ischar(content)
            % next line is to recover content when browsing or saving
            set(h_edit(i),'UserData',content);
            set(h_edit(i),'Enable','off');
            content = 'CANNOT DISPLAY';
    else
        set(h_edit(i),'Enable','on');
    end
    set(h_edit(i),'String',content);
end

ud.persistent = 1;
ud.h_edit = h_edit;
ud.orgrecord = record;

p = get(h_fig,'position');
op = get(h_fig,'outerposition');
windowvbordersize = op(4)-p(4);

if isoctave
    windowvbordersize = 44;
end    

if isfield(ud,'db_form')
    posdb = get(ud.db_form,'Position');
    posfrm = get(h_fig,'Position');
    set(h_fig,'Position',[posdb(1) posdb(2)-posfrm(4)-windowvbordersize posfrm(3) posfrm(4)])
    set(h_fig,'Color',get(ud.db_form,'Color'));
end

set(h_fig,'Userdata',ud);
set(h_fig,'ResizeFcn',@figure_resize);

if nargout==1
    handle = h_fig;
end

function figure_resize(src,evt) %#ok<INUSD>
fig = src;
ud = get(fig,'userdata');
if isfield(ud,'record_form')
    fig = ud.record_form;
end
ud = get(fig,'userdata');

oldunits = get(fig,'Units');
set(fig,'Units','pixels');
fpos = get(fig,'Position');

for h = ud.h_edit(:)'
    p = get(h,'position');
    p(3) = fpos(3)-p(1);
    set(h,'position',p);
end
set(fig,'Units',oldunits);

function str = wimpcell2str(theCell)
%1-dim cells only, only chars and matricies
str = '{  ';
for i = 1:length(theCell)
    if ischar(theCell{i})
        str = [str '''' theCell{i} ''', ']; %#ok<AGROW>
    elseif isnumeric(theCell{i})
        str = [str mat2str(theCell{i}) ', ']; %#ok<AGROW>
    end
end
str = [str(1:end-2) '}'];