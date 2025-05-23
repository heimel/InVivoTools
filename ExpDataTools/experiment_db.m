function fig = experiment_db( type, hostname )
%experiment_db. Starts physiology database
%
%   FIG = experiment_db
%   FIG = experiment_db( TYPE )
%   FIG = experiment_db( TYPE, HOSTNAME )
%   FIG = experiment_db( DB );
%   FIG = experiment_db( FILENAME );
%
%     TYPE can be 'oi','ec','tp','wc','nt',etc.
%         if no database is found, then an empty database for the 
%         specific datatype is opened if it exists.
%     FIG returns handle to the database control figure
%
% 2005-2025, Alexander Heimel
%

if nargout==1
    fig = [];
end

color = 0.7*[1 1 1];

if nargin < 1 || isempty(type)
    type = 'oi';
end

if nargin<2
    hostname = host;
    if ~isempty(hostname)
        logmsg(['Working on host ' hostname ]);
    end
end

%defaults
select_all_of_name_enabled = 0;
blind_data_enabled = 0;
reverse_data_enabled = 0;
open_data_enable = 0;
channels_enabled = 0;
average_tests_enabled = 0;
export_tests_enabled = 0;
play_data_enable = 0;
track_data_enable = 0;

if ischar(type)
    [db,filename] = load_testdb(type, hostname);
else
    db = type;
    if ~isempty(db) && isfield(db(1),'datatype') && ~isempty(db(1).datatype)
        type = db(1).datatype;
    else
        type = 'oi';
    end
    filename = {['tempdb_' char(datetime('now','format','yyyyMMdd')) '.mat']}; % making it a cell to avoid later loading
end

if isempty(db)
    emptydb_filename = [type 'testdb_empty.mat'];
    if exist(emptydb_filename,'file')
        load(emptydb_filename,'db');
        if isempty(db)
            return
        end
        logmsg(['Loaded empty database ' emptydb_filename]);
        filename = {};
    else
        return
    end
end

if isfield(db,'datatype') && ~isempty(db(1).datatype)
    type = db(1).datatype;
end

switch type
    case {'ec','neuropixels'}
        channels_enabled = 1;
    case 'tp'
        color = [0.4 0.5 1];
        open_data_enable = 1;
        blind_data_enabled = 1;
        reverse_data_enabled = 1; % for reversing database
    case 'wc'
        color = [1 0.6 0.4];
        play_data_enable = 1;
        track_data_enable = 1;
    case 'hc'
        color = [0.6 1 0.4];
        play_data_enable = 1;
    case 'nt'
        color = [0.6 1 0.4];
        track_data_enable = 1;
end

experimental_pc = is_experimental_pc( hostname);

if isfield(db,'comment')
    % Temp removal for multiline comments
    multiline = false;
    for i=1:length(db)
        if size(db(i).comment,1)>1 && ischar(db(i).comment)% i.e. multiline
            db(i).comment = flatten(db(i).comment')';
            multiline = true;
        end
    end
    if multiline && ~iscell(filename)
        logmsg('Flattened multiline comments');
        if ~iscell(filename)
            stat = checklock(filename);
            if stat~=1
                filename = save_db(db,filename,'');
                rmlock(filename);
            end
        end
    end
end

% start control database
if ~iscell(filename)
    h_fig = control_db(filename,color);
else
    h_fig = control_db(db,color);
end
if isempty(h_fig)
    return
end
ud = get(h_fig,'Userdata');
ud.type = type;

set(h_fig,'Userdata',ud);
set_control_name(h_fig);

if nargout==1
    fig = h_fig;
end


ud = get(h_fig,'UserData');
h = ud.h;

maxleft = ud.maxleft;
left = ud.leftmargin;
colsep = ud.colsep;
top = ud.colsep;

% set customize sort to sort button
set(h.sort,'Tag','sort_testrecords');
set(h.sort,'Enable','on'); % enable sort button

if haspsychtbox || experimental_pc
    runexperiment_enabled = 1;
else
    runexperiment_enabled = 0;
end

if experimental_pc
    % check diskusage
    pth = eval([type 'datapath(db(1))']);
    df = diskusage(pth);
    if df.available < 11000000
        errormsg(['Less than 11 Gb available on ' pth '. Clean up disk!']);
    end
end

if strcmp(host,'wall-e')
    h.laser = ...
        uicontrol('Parent',h.fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','control_lasergui', ...
        'ListboxTop',0, ...
        'Position',[left top ud.buttonwidth ud.buttonheight], ...
        'String','Laser', ...
        'FontSize',ud.basefontsize,...
        'Tag','Laser',...
        'Tooltipstring','Close all non-persistent figures');
    left = left+ud.buttonwidth+colsep;
    maxleft = max(maxleft,left);
end

if runexperiment_enabled
    h.runexperiment = ...
        uicontrol('Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'Position',[left top ud.buttonwidth ud.buttonheight], ...
        'Tag','run_callback',...
        'FontSize',ud.basefontsize,...
        'String','Stimulus');
    left = left+ud.buttonwidth+colsep;
    maxleft = max(maxleft,left);
end

if open_data_enable
    h.open = ...
        uicontrol('Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'Position',[left top ud.buttonwidth ud.buttonheight], ...
        'FontSize',ud.basefontsize,...
        'String','Open','Tag','open_tptestrecord_callback');
    left = left+ud.buttonwidth+colsep;
    maxleft = max(maxleft,left);
end

if play_data_enable
    h.play = ...
        uicontrol('Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'Position',[left top ud.buttonwidth ud.buttonheight], ...
        'FontSize',ud.basefontsize,...
        'String','Play',...
        'Tag','play_testrecord_callback');
    left = left+ud.buttonwidth+colsep;
    maxleft = max(maxleft,left);
end

if track_data_enable
    switch type
        case 'nt'
            fcn_name = 'nt_track_behavior_callback';
        case 'wc'
            fcn_name = 'track_wctestrecord_callback';
    end
    h.track = ...
        uicontrol('Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'FontSize',ud.basefontsize,...
        'Position',[left top ud.buttonwidth ud.buttonheight], ...
        'String','Track','Tag',fcn_name);
    left = left+ud.buttonwidth+colsep;
    maxleft=max(maxleft,left);
end

h.analyse = ...
    uicontrol('Parent',h_fig, ...
    'Units','pixels', ...
    'BackgroundColor',0.8*[1 1 1],...
    'Callback','genercallback', ...
    'ListboxTop',0, ...
    'Position',[left top ud.buttonwidth ud.buttonheight], ...
    'FontSize',ud.basefontsize,...
    'String','Analyse' );
left = left+ud.buttonwidth+colsep;
maxleft = max(maxleft,left);

h.results = ...
    uicontrol('Parent',h_fig, ...
    'Units','pixels', ...
    'BackgroundColor',0.8*[1 1 1],...
    'Callback','genercallback', ...
    'ListboxTop',0, ...
    'Position',[left top ud.buttonwidth ud.buttonheight], ...
    'FontSize',ud.basefontsize,...
    'String','Results');
left = left+ud.buttonwidth+colsep;
maxleft = max(maxleft,left);

h.which_test = ...
    uicontrol('Parent',h_fig, ...
    'Style','popupmenu',...
    'Units','pixels', ...
    'BackgroundColor',0.8*[1 1 1],...
    'Callback','genercallback', ...
    'ListboxTop',0, ...
    'FontSize',ud.basefontsize,...
    'Position',[left top-0.1*ud.buttonheight ud.buttonwidth ud.buttonheight], ...
    'Value',1,...
    'Tag','');
left = left+ud.buttonwidth+colsep;
maxleft = max(maxleft,left);

if average_tests_enabled
    h.average_tests = ...
        uicontrol('Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'Position',[left top ud.buttonwidth ud.buttonheight], ...
        'Tag','average_tests',...
        'FontSize',ud.basefontsize,...
        'String','Average'); %#ok<UNRCH>
    left=left+ud.buttonwidth+colsep;
    maxleft=max(maxleft,left);
end

if export_tests_enabled
    h.export_tests = ...
        uicontrol('Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'Position',[left top ud.buttonwidth ud.buttonheight], ...
        'Tag','export_tests',...
        'FontSize',ud.basefontsize,...
        'String','Export'); %#ok<UNRCH>
    left=left+ud.buttonwidth+colsep;
    maxleft=max(maxleft,left);
end

if select_all_of_name_enabled
    h.selectname = ...
        uicontrol('Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'Position',[left top ud.buttonwidth ud.buttonheight], ...
        'TooltipString','Selects all records of the current mouse',...
        'FontSize',ud.basefontsize,...
        'Tag','tptestdb_selectname',...
        'String','Select'); %#ok<UNRCH>
    left=left+ud.buttonwidth+colsep;
    maxleft=max(maxleft,left);
end

h.close_figs = ...
    uicontrol('Parent',h.fig, ...
    'Units','pixels', ...
    'BackgroundColor',0.8*[1 1 1],...
    'Callback','genercallback', ...
    'ListboxTop',0, ...
    'Position',[left top ud.buttonwidth ud.buttonheight], ...
    'String','Close figs', ...
    'FontSize',ud.basefontsize,...
    'Tag','close figs',...
    'Tooltipstring','Close all non-persistent figures');
left=left+ud.buttonwidth+colsep;
maxleft=max(maxleft,left);

if blind_data_enabled
    h.blind = ...
        uicontrol('Style','toggle','Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'Position',[left top ud.buttonwidth ud.buttonheight], ...
        'TooltipString','Blinds and shuffles database',...
        'Tag','blinding_tpdata',...
        'FontSize',ud.basefontsize,...
        'String','Blind');
    if ~strcmp(host,'wall-e') % i.e. no laser button
        left=left+ud.buttonwidth+colsep;
    else
        top = top + ud.buttonheight + colsep;
        
    end
    maxleft = max(maxleft,left);
end

if reverse_data_enabled
    h.reverse = ...
        uicontrol('Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'Position',[left top ud.buttonwidth ud.buttonheight], ...
        'TooltipString','Reverses database',...
        'Tag','reverse',...
        'FontSize',ud.basefontsize,...
        'String','Reverse');
    left=left+ud.buttonwidth+colsep;
    maxleft = max(maxleft,left);
end

if channels_enabled
    h.channels = ...
        uicontrol('Style','edit','Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',1*[1 1 1],...
        'Callback','', ...
        'ListboxTop',0, ...
        'Position',[left top ud.buttonwidth ud.buttonheight], ...
        'TooltipString','Which channels to analyse',...
        'FontSize',ud.basefontsize,...
        'Tag','channels_edit',...
        'String','        ');
    maxleft = max(maxleft,left);
end

ud.h = h;
set(h_fig,'UserData',ud);

set(h.analyse,'Tag','analyse_testrecord_callback');

set(h.results,'Enable','on');
set(h.results,'Tag','results_testrecord_callback');

new_record_functionname = ['new_' type ' testrecord'];
if exist(new_record_functionname,'file')
    set(h.new,'Callback',...
        ['ud=get(gcf,''userdata'');ud=new_' type 'testrecord(ud);' ...
        'set(gcf,''userdata'',ud);control_db_callback(ud.h.current_record);']);
end


avname = ['available_' type 'tests'];
if exist(avname,'file')
    set(h.which_test,'String',eval(['available_' type 'tests']));
else
    set(h.which_test,'String','');
    set(h.which_test,'visible','off');
end

% make figure wide enough
pos = get(h_fig,'Position');
pos(3) = max(maxleft,pos(3));
set(h_fig,'Position',pos);

% set current record
control_db_callback( h.current_record );
control_db_callback( h.current_record );

