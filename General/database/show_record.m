function handle = show_record( record, h_fig, h_control_fig )
%SHOW_RECORD used in database tools to show record figure
%
% 2004-2013, Alexander Heimel

if nargin<2
    h_fig=[];
end
if nargin<3
    h_control_fig = [];
end
if isempty(h_control_fig)
    bc=0.8*[1 1 1];
else
    bc = get(h_control_fig,'Color');
end


if isempty(h_fig)
    screensize=get(0,'ScreenSize');
    
    fields=fieldnames(record);
    
    labelleft=5;
    labelwidth=100;
    labelheight=17;
    
    editheight=labelheight+3;
    editwidth=200;
    
    linesep=1;
    colsep=3;
    lineheight=editheight+linesep;
    colwidth=labelleft+labelwidth+editwidth+3*colsep;
    
    height=(length(fields)+...
        length(strmatch('comment',fields)))*lineheight;
    
    
    
    top=height-editheight-linesep;
    
    
    
    h_fig = figure('Name','Record',...
        'Color',bc,...
        'PaperPosition',[18 180 576 432], ...
        'PaperUnits','points', ...
        'Position',[screensize(3)-colwidth 40 colwidth height], ...
        'Tag','', ...
        'Units','pixels',...
        'ToolBar','none');
    set(h_fig,'MenuBar','none');
    set(h_fig,'NumberTitle','off');
    
    
    
    for i=1:length(fields)
        left=labelleft;
        h_text(i) =...
            uicontrol('Parent',h_fig, ...
            'Units','pixels', ...
            'BackgroundColor',bc,...
            'ListboxTop',0, ...
            'Position',[left top+2 labelwidth labelheight], ...
            'String',fields{i}, ...
            'HorizontalAlignment','right',...
            'Style','text', ...
            'Units','pixels',...
            'Fontname','Times',...
            'Tag',fields{i});
        
        left=left+labelwidth+colsep;
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
                'Callback','genercallback',...
                'Tag',[ fields{i} ]);
            top=top-lineheight;
        else
            top=top-lineheight;
            h_edit(i)= ...
                uicontrol('Parent',h_fig, ...
                'Units','pixels', ...
                'BackgroundColor',[1 1 1],...
                'ListboxTop',0, ...
                'Position',[left top+2 editwidth editheight*2], ...
                'String','', ...
                'HorizontalAlignment','left',...
                'Style','edit', ...
                'Units','pixels','max',2,'min', 0,...
                'Callback','genercallback',...
                'Tag',[ fields{i} ]);
            top=top-1*lineheight;
        end
        
        
        
    end
    ud.h_edit=h_edit;
    set(h_fig,'Userdata',ud);
end

% fill form
fields=fieldnames(record);
for i=1:length(fields)
    ud=get(h_fig,'Userdata');
    h_edit=ud.h_edit;
    content=getfield(record,fields{i});
    
    
    if islogical(content)
        content = double(content);
    end
    if isnumeric(content)
        %content=num2str(content,' %1g');
        if ~isempty(content)
            content=mat2str(content,10);
        else
            content='';
        end
    end
    if ~ischar(content)
        % next line is to recover content when browsing or saving
        set(h_edit(i),'UserData',content);
        set(h_edit(i),'Enable','off');
        content='CANNOT DISPLAY';
    else
        set(h_edit(i),'Enable','on');
    end
    set(h_edit(i),'String',content);
end

ud.persistent=1;
ud.h_edit=h_edit;
ud.orgrecord=record;


switch computer
    case {'PCWIN','PCWIN64'}
        windowvbordersize=26;
        windowhbordersize=6;
    otherwise
        windowvbordersize=20;
        windowhbordersize=6;
end

if isfield(ud,'db_form')
    posdb=get(ud.db_form,'Position');
    posfrm=get(h_fig,'Position');
    if posdb(2)-posfrm(4)>0  % if not too high
        set(h_fig,    'Position',[posdb(1) posdb(2)-posfrm(4)-windowvbordersize posfrm(3) posfrm(4)])
    else
        set(h_fig,    'Position',[posdb(1)+posdb(3)+windowhbordersize posdb(2) posfrm(3) posfrm(4)])
    end
    
    % set color
    set(h_fig,'Color',get(ud.db_form,'Color'));
    
end

set(h_fig,'Userdata',ud);
set(h_fig,'ResizeFcn',@figure_resize);

if nargout==1
    handle=h_fig;
end



function figure_resize(src,evt) %#ok<INUSD>
oldunits = get(gcf,'Units');
set(gcf,'Units','pixels');
fpos = get(gcf,'Position');

ud = get(gcf,'userdata');
for h = ud.h_edit(:)'
    p = get(h,'position');
    p(3) = fpos(3)-p(1);
    set(h,'position',p);
end
set(gcf,'Units',oldunits);
