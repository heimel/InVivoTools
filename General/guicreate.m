function [handle, pos] = guicreate( arg, varargin )
%GUICREATE creates gui elements using defaults in figure's userdata struct
%
%  [HANDLE, POS] = GUICREATE( ARG, VARARGIN )
%
%  ARG can be a string containing a single uicontrol style property
%  or a struct containing several properties
%
%  GUICREATE by defaults moves the drawing cursor below the
%  created object. If the 'move' argument followed by 'right' this changed
%  to moving the cursor to the right of the created object.
%
%
%  HANDLE contains object handle
%  POS contains object position
%
% 2010, Alexander Heimel
%

string = []; % to overwrite function STRING

% possible varargins with default values
pos_args={...
	'parent',gcf,...
    'fig',gcf,...
    'visible','on', ...
    'units',[],...
    'backgroundcolor',[],...
    'horizontalalignment','left', ...
    'position',[],... % overrules left, top, width, height
    'left',[],... 
    'top',[],...
    'width',[],...
    'height',[],...
    'string','', ...
    'tooltipstring','',...
    'fontname','helvetica',...
    'fontsize',10,...
	'fontweight','normal',...
    'tag','',...
    'callback',[],...
    'enable','on',...
    'move','newline',... % alternative 'right','down'
    'value',[],...
    'cdata',[],... % for icons on buttons
    'userdata',[],...
    };

assign(pos_args{:});

if isstruct(arg)
	f = fieldnames(arg);
	for i=1:length(f)
		assign( lower(f{i}), arg.(f{i}));
	end
	if exist('style','var');
		stylestr = style;
		style = [];
		style.Style = stylestr;
	end
elseif ischar(arg)
	style.Style = arg;
end

%parse varargins
nvarargin=length(varargin);
if nvarargin>0
  if rem(nvarargin,2)==1
    warning('GUICREATE:WRONGVARARG','odd number of varguments');
    return
  end
  for i=1:2:nvarargin
    found_arg=0;
    varargin{i} = lower(varargin{i});
    for j=1:2:length(pos_args)
      if strcmp(varargin{i},pos_args{j})==1
        found_arg=1;
        if ~isempty(varargin{i+1})
          assign(pos_args{j}, varargin{i+1});
        end
      end
    end
    if ~found_arg
      warning('GUICREATE:WRONGVARARG',['could not parse argument ' varargin{i}]);
      return
    end
  end
end

ud = get(fig,'UserData');
if ~isempty(ud) && ~isstruct(ud)
    error('GUICREATE:USERDATA_NOT_STRUCT','Figure userdata is not a struct');
end
if isfield( ud, 'guicreate')
    gcud = ud.('guicreate');
else
    gcud = [];
end

parenttype = get(parent,'type');
parentpos = get(parent,'Position');

% get defaults from figure
if isempty(units) %#ok<NODEF>
    units = get(fig,'Units');
end
if isempty(backgroundcolor) && ~isfield(style,'BackgroundColor') %#ok<NODEF>
	switch parenttype
		case 'figure'
			backgroundcolor = get(parent,'Color');
		case 'uipanel'
			backgroundcolor = get(parent,'BackgroundColor');
	end
end


% initialize gcud if necessary
if isempty(gcud)
    gcud.top = parentpos(4) - 25;
    gcud.vspace = 5;
    gcud.hspace = 5;
    gcud.leftmargin = gcud.hspace;
    gcud.left = gcud.leftmargin;
    gcud.text_width = 100;
    gcud.text_height = 20;
    gcud.edit_width = 100;
    gcud.edit_height = 20;
    gcud.popupmenu_width = 100;
    gcud.popupmenu_height = 20;
    gcud.list_width = 100;
    gcud.list_height = 80;
    gcud.pushbutton_width = 100;
    gcud.pushbutton_height = 20;
    gcud.checkbox_width = 100;
    gcud.checkbox_height = 20;
    gcud.togglebutton_width = 100;
    gcud.togglebutton_height = 20;
    gcud.slider_width = 100;
    gcud.slider_height = 20;
end

if isempty(left) %#ok<NODEF>
    left = gcud.left;
end
if isempty(top) %#ok<NODEF>
    top = gcud.top ;
end
if isempty(height)
    eval( ['height = gcud.' lower(style.Style) '_height;']);
end
if isempty(width)
    eval( ['width = gcud.' lower(style.Style) '_width;']);
end
if ischar(width)
    switch width
        case 'auto'
            autowidth = 1;
            width = 0.1;
        otherwise
            error('GUICREATE:Unknown width option');
    end
end
if ischar(top)
    switch top
        case 'top_nomargin'
            top = parentpos(4)-4;
        case 'top'
            switch parenttype
                case 'uipanel'
                    top = parentpos(4) - gcud.vspace*3 ;
                otherwise
                    top = parentpos(4) - gcud.vspace ;
            end
        case 'bottom'
            top = gcud.vspace + gcud.text_height;
        otherwise
            error('GUICREATE:Unknown top option');
    end
end


if ischar(left)
    switch left
        case 'right'
            left = parentpos(3) - gcud.hspace;
        case 'left'
            left =  gcud.leftmargin;
        otherwise
            error('GUICREATE:Unknown left option');
    end
end


if isempty(position) %#ok<NODEF>
    position = [left top width height];
end

if ~isempty(callback)
    style.Callback = callback;
end
if ~isempty(enable)
    style.Enable = enable;
end
if ~isempty(fontname)
    style.FontName = fontname;
end
if ~isempty(fontsize)
    style.FontSize = fontsize;
end
if ~isempty(fontweight)
	style.FontWeight = fontweight;
end
if ~isempty(backgroundcolor)
    style.BackgroundColor = backgroundcolor;
end
if ~isempty(value)
    style.value = value;
end
if ~isempty(visible)
    style.visible = visible;
end
if ~isempty(cdata)
    style.cdata = cdata;
end

if strcmpi(style.Style,'popupmenu')
    position = position + [ 0 2 0 0];
end

    


%handle = uicontrol(fig,style,...
%    'Parent',fig, ... % first arg has to be parent for octave
%    'Units',units, ...
%    'HorizontalAlignment',horizontalalignment, ...
%    'Position',position - [ 0 height  0 0], ...
%    'String',string, ... 
%	'Parent',parent,...
%    'TooltipString',tooltipstring,...
%    'Tag',tag);

cmd = 'handle=uicontrol(fig';
flds = fieldnames(style);
for i=1:length(flds)
    cmd = [cmd ',flds{' num2str(i) '},style.(flds{' num2str(i) '})' ]; %#ok<AGROW>
end
cmd = [cmd  ...
',''Parent'',fig' ...
',''Units'',units' ...
',''HorizontalAlignment'',horizontalalignment' ...
',''Position'',position - [ 0 height  0 0]' ...
',''String'',string' ... 
',''Parent'',parent' ...
',''TooltipString'',tooltipstring' ...
',''Tag'',tag'];

cmd = [cmd ');'];
eval(cmd);





if exist('autowidth','var')
    ext = get(handle,'extent');
    width = ext(3)*1.2; % add 20% 
    pos = get(handle,'position');
    pos(3) = width;
    set( handle,'position',pos);
end

pos = get(handle,'Position');

switch move
    case 'down'
        gcud.left = left;
        gcud.top = top - height - gcud.vspace;
    case 'up'
        gcud.left = left;
        gcud.top = top + height + gcud.vspace;
    case 'newline'
        gcud.left = gcud.leftmargin;
        gcud.top = top - height - gcud.vspace;
    case 'right'
        gcud.top   = top ;
        gcud.left  = left + width + gcud.hspace;
end
        
% upload new guicreate userdata to figure userdata
ud.('guicreate') = gcud;
set(fig,'UserData',ud);


