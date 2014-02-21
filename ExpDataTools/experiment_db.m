function fig=experiment_db( type, hostname )
%EXPERIMENT_DB starts physiology database
%
%   FIG=EXPERIMENT_DB
%   FIG=EXPERIMENT_DB( TYPE )
%   FIG=EXPERIMENT_DB( TYPE, HOSTNAME )
%
%     TYPE can be 'oi','ec','tp'
%     FIG returns handle to the database control figure
%
% 2005-2013, Alexander Heimel
%

if nargout==1
    fig=[];
end

color = 0.7*[1 1 1];

if nargin < 1
    type=[];
end
if isempty(type)
    type='oi';
end

if nargin<2
    hostname = host;
    if isempty(hostname)
        % disp(['EXPERIMENT_DB: No hostname set' ]);
    else        
        disp(['EXPERIMENT_DB: Working on host ' hostname ]);
    end
end

switch(user)
    case 'heimel'
        poweruser = true;
    otherwise
        %disp('EXPERIMENT_DB: Temporarily making everybody power user to make test cycling possible');
        poweruser = true;
end

%defaults
select_all_of_name_enabled=0;
blind_data_enabled = 0;
analyse_all_enabled = 0;
reverse_data_enabled = 0;
open_data_enable = 0;
channels_enabled = 0;

switch type
    case 'oi'
        average_tests_enabled=0;
        export_tests_enabled=0;
    case 'ec'
        average_tests_enabled=0;
        export_tests_enabled=0;
        channels_enabled = 1;
    case 'tp' % twophoton
        color = [0.4 0.5 1];
        average_tests_enabled=0;
        export_tests_enabled=0;
        %        select_all_of_name_enabled=1;
        analyse_all_enabled = 0;
        open_data_enable = 1;
        blind_data_enabled = 1;
        reverse_data_enabled = 1; % for reversing database
    case 'ls' % linescans
        color = [0.8 0.6 0];
        average_tests_enabled=0;
        export_tests_enabled=0;
    otherwise
        warning('EXPERIMENT_DB:UNKNOWN_TYPE',['Unknown type ''' type '''']);
        return
end


% get which database
[testdb, experimental_pc] = expdatabases( type, hostname );

% load database
[db,filename]=load_testdb(testdb);

if isempty(db)
    return
end

% temporarily adding anesthetic field % 2013-03-18
switch type
    case {'tp','oi','ec'}
        if ~isfield(db,'anesthetic')
            for i=1:length(db)
                db(i).anesthetic = '';
            end
            stat = checklock(filename);
            if stat~=1
                filename = save_db(db,filename,'');
                rmlock(filename);
            end
        end
end
% temporarily adding anesthetic field % 2013-03-18
switch type
    case {'ec'}
        if ~isfield(db,'analysis')
            for i=1:length(db)
                db(i).analysis = '';
            end
            stat = checklock(filename);
            if stat~=1
                filename = save_db(db,filename,'');
                rmlock(filename);
            end
        end
end
% temporarily adding measurement field % 2013-03-22
%  switch type
%      case {'tp'}
%          if ~isfield(db,'measures')
%              for i=1:length(db)
%                  db(i).measures = '';
%              end
%              stat = checklock(filename);
%              if stat~=1
%                  filename = save_db(db,filename,'');
%                  rmlock(filename);
%              end
%          end
%  end


% start control database
switch testdb
    case {'testdb','ectestdb'}
        h_fig=control_db(db,color);
    otherwise
        %h_fig=control_db(db,color);
       h_fig=control_db(filename,color); 
        
end
if isempty(h_fig)
    return
end
ud = get(h_fig,'Userdata');
ud.type = type;

set(h_fig,'Userdata',ud);
set_control_name(h_fig);

if nargout==1
    fig=h_fig;
end

maxleft=0;
left=10;
buttonwidth=65;
colsep=3;
buttonheight=30;
top=10;

ud=get(h_fig,'UserData');
h=ud.h;

% set customize sort to sort button
set(h.sort,'Tag','sort_testrecords');
if poweruser
    set(h.sort,'Enable','on'); % enable sort button
else
    % to avoid people messing up the database by accident
    set(h.sort,'Enable','off');
end


if haspsychtbox || experimental_pc
    runexperiment_enabled = 1;
else
    runexperiment_enabled = 0;
end

if experimental_pc
    % check diskusage
    df=diskusage(eval([type 'datapath']));
    if df.available < 11000000
        disp(['EXPERIMENT_DB: less than 11 Gb available on /home/data. Clean up' ...
            ' disk!']);
    end
end

if strcmp(host,'wall-e')
    h.laser = ...
        uicontrol('Parent',h.fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','control_lasergui', ...
        'ListboxTop',0, ...
        'Position',[left top buttonwidth buttonheight], ...
        'String','Laser', ...
        'Tag','Laser',...
        'Tooltipstring','Close all non-persistent figures');
    left=left+buttonwidth+colsep;
    maxleft=max(maxleft,left);
end


if runexperiment_enabled
    h.runexperiment = ...
        uicontrol('Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'Position',[left top buttonwidth buttonheight], ...
        'Tag','run_callback',...
        'String','Stimulus');
    left=left+buttonwidth+colsep;
    maxleft=max(maxleft,left);
end

if open_data_enable
    h.open = ...
        uicontrol('Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'Position',[left top buttonwidth buttonheight], ...
        'String','Open','Tag','open_tptestrecord_callback');
    left=left+buttonwidth+colsep;
    maxleft=max(maxleft,left);
end

h.analyse = ...
    uicontrol('Parent',h_fig, ...
    'Units','pixels', ...
    'BackgroundColor',0.8*[1 1 1],...
    'Callback','genercallback', ...
    'ListboxTop',0, ...
    'Position',[left top buttonwidth buttonheight], ...
    'String','Analyse' );
left=left+buttonwidth+colsep;
maxleft=max(maxleft,left);

h.results = ...
    uicontrol('Parent',h_fig, ...
    'Units','pixels', ...
    'BackgroundColor',0.8*[1 1 1],...
    'Callback','genercallback', ...
    'ListboxTop',0, ...
    'Position',[left top buttonwidth buttonheight], ...
    'String','Results');
left=left+buttonwidth+colsep;
maxleft=max(maxleft,left);

% h.rois = ...
%     uicontrol('Parent',h_fig, ...
%     'Units','pixels', ...
%     'BackgroundColor',0.8*[1 1 1],...
%     'Callback','genercallback', ...
%     'ListboxTop',0, ...
%     'Position',[left top buttonwidth buttonheight], ...
%     'String','ROIs','Tag','tptestdb_roidb');
% left=left+buttonwidth+colsep;
% maxleft=max(maxleft,left);

h.which_test = ...
    uicontrol('Parent',h_fig, ...
    'Style','popupmenu',...
    'Units','pixels', ...
    'BackgroundColor',0.8*[1 1 1],...
    'Callback','genercallback', ...
    'ListboxTop',0, ...
    'Position',[left top-0.1*buttonheight buttonwidth buttonheight], ...
    'Value',1,...
    'Tag','');
left=left+buttonwidth+colsep;
maxleft=max(maxleft,left);

% h.new_testrecord = ...
%     uicontrol('Parent',h_fig, ...
%     'Units','pixels', ...
%     'BackgroundColor',0.8*[1 1 1],...
%     'Callback','genercallback', ...
%     'ListboxTop',0, ...
%     'Position',[left top buttonwidth buttonheight], ...
%     'String','New test');
% left=left+buttonwidth+colsep;
% maxleft=max(maxleft,left);

if analyse_all_enabled
    h.analyse_all = ...
        uicontrol('Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'Position',[left top buttonwidth buttonheight], ...
        'Tag','analyse_all_testrecord_callback',...
        'String','Analyze all');
    left=left+buttonwidth+colsep;
    maxleft=max(maxleft,left);
    if strcmp(user,'heimel') 
        set(h.analyse_all,'Enable','on');
    else
        set(h.analyse_all,'Enable','off');
    end
end

if average_tests_enabled
    h.average_tests = ...
        uicontrol('Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'Position',[left top buttonwidth buttonheight], ...
        'Tag','average_tests',...
        'String','Average');
    left=left+buttonwidth+colsep;
    maxleft=max(maxleft,left);
end

if export_tests_enabled
    h.export_tests = ...
        uicontrol('Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'Position',[left top buttonwidth buttonheight], ...
        'Tag','export_tests',...
        'String','Export');
    left=left+buttonwidth+colsep;
    maxleft=max(maxleft,left);
end

if select_all_of_name_enabled
    h.selectname = ...
        uicontrol('Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'Position',[left top buttonwidth buttonheight], ...
        'TooltipString','Selects all records of the current mouse',...
        'Tag','tptestdb_selectname',...
        'String','Select'); %#ok<UNRCH>
    left=left+buttonwidth+colsep;
    maxleft=max(maxleft,left);
end

h.close_figs = ...
    uicontrol('Parent',h.fig, ...
    'Units','pixels', ...
    'BackgroundColor',0.8*[1 1 1],...
    'Callback','genercallback', ...
    'ListboxTop',0, ...
    'Position',[left top buttonwidth buttonheight], ...
    'String','Close figs', ...
    'Tag','close figs',...
    'Tooltipstring','Close all non-persistent figures');
left=left+buttonwidth+colsep;
maxleft=max(maxleft,left);


if blind_data_enabled
    h.blind = ...
        uicontrol('Style','toggle','Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'Position',[left top buttonwidth buttonheight], ...
        'TooltipString','Blinds and shuffles database',...
        'Tag','blinding_tpdata',...
        'String','Blind');
    if ~strcmp(host,'wall-e') % i.e. no laser button
        left=left+buttonwidth+colsep;
    else
        top = top + buttonheight + colsep;

    end
    maxleft=max(maxleft,left);
end

if reverse_data_enabled
    h.reverse = ...
        uicontrol('Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',0.8*[1 1 1],...
        'Callback','genercallback', ...
        'ListboxTop',0, ...
        'Position',[left top buttonwidth buttonheight], ...
        'TooltipString','Reverses database',...
        'Tag','reverse',...
        'String','Reverse');
    left=left+buttonwidth+colsep;
    maxleft=max(maxleft,left);
end

if channels_enabled
    h.channels = ...
        uicontrol('Style','edit','Parent',h_fig, ...
        'Units','pixels', ...
        'BackgroundColor',1*[1 1 1],...
        'Callback','', ...
        'ListboxTop',0, ...
        'Position',[left top buttonwidth buttonheight], ...
        'TooltipString','Which channels to analyse',...
        'Tag','channels_edit',...
        'String','        ');
    maxleft=max(maxleft,left);
end





ud.h=h;
set(h_fig,'UserData',ud);

switch computer
    case {'PCWIN','PCWIN64'}
        windowvbordersize=26;
        windowhbordersize=6;
    otherwise
        windowvbordersize=20;
        windowhbordersize=6;
end


set(h.analyse,'Tag','analyse_testrecord_callback');

set(h.results,'Enable','on');
set(h.results,'Tag',['results_' type 'testrecord_callback']);
%set(h.new_testrecord,'Tag',['new_' type 'testrecord']);
set(h.new,'Callback',...
    ['ud=get(gcf,''userdata'');ud=new_' type 'testrecord(ud);' ...
    'set(gcf,''userdata'',ud);control_db_callback(ud.h.current_record);']);
%set(h.new,'Tag',['new_' type 'testrecord']);

avname = ['available_' type 'tests'];
if exist(avname,'file')
    set(h.which_test,'String',eval(['available_' type 'tests']));
else
    set(h.which_test,'String','');
    set(h.which_test,'visible','off');
end

% make figure wide enough
pos=get(h_fig,'Position');
pos(3)=max(maxleft,pos(3));
set(h_fig,'Position',pos);

pos_screen = get(0,'ScreenSize');
pos_control = get(h_fig,'Position');
pos_control(1) = windowhbordersize; 
pos_control(2) = pos_screen(4)-pos_control(4)-windowvbordersize;
set(h_fig,'Position',pos_control);

% set current record
control_db_callback( h.current_record );
control_db_callback( h.current_record );

