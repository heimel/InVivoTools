function twophotonbulkload(command, thefig)
% TWOPHOTONBULKLOAD - View/Manage a two-photon bulk loading experiment
%
%  TWOPHOTONBULKLOAD([EXPERDIR])
%
%   Opens a window for managing a
%   two-photon bulk load experiment
%
%   Optional argument EXPERDIR can be the directory of an
%   experiment.
%
% Steve Vanhooser
%

if nargin<2, %
    if nargin==0
        experdir=pwd;
        command = 'NewWindow';
        fig = figure;
    else
        if isa(command,'char'),
            experdir = command;
            command = 'NewWindow';
            fig = figure;
        else % if not a string, then command is a callback object
            command = get(command,'Tag');
            fig = gcbf;
            ud = get(fig,'userdata');
        end;
    end;
elseif nargin==2,  % then is command, and fig as 2nd arg
    fig = thefig;
    ud = get(fig,'userdata');
end;

switch command,
    case 'NewWindow',

        set(fig,'name','Bulkload','Tag','twophotonbulkload',...
            'position',[370   359   620   413],'menubar','none','NumberTitle','off');
        button.Units = 'pixels';
        button.BackgroundColor = [0.8 0.8 0.8];
        button.HorizontalAlignment = 'center';
        mycallback = 'genercallback';
        button.Callback = mycallback;
        txt.Units = 'pixels'; txt.BackgroundColor = [0.8 0.8 0.8];
        txt.fontsize = 12; txt.fontweight = 'normal';
        txt.HorizontalAlignment = 'center';txt.Style='text';
        edit = txt; edit.BackgroundColor = [ 1 1 1]; edit.Style = 'Edit';
        popup = txt; popup.style = 'popupmenu';
        cb = txt; cb.Style = 'Checkbox'; cb.Callback = mycallback;
        cb.fontsize = 12;

        sh=-250;

        uicontrol(txt,'Units','pixels','position',[10 620+sh 300 25],'string','Two-photon bulk load experiment',...
            'fontweight','bold','fontsize',16);
        uicontrol(txt,'position',[10 590+sh-2 65 20],'string','Pathname:');
        uicontrol(edit,'position',[10+65+5 590+sh 400 20],'string',experdir,'Tag','PathnameEdit');
        uicontrol(button,'position',[10+65+5+410 590+sh 60 20],'string','Update','Tag','UpdateBt');
        uicontrol(txt,'position',[10 520+sh 150 40],'string','Stacks:','horizontalalignment','center');
        uicontrol(txt,'position',[160 520+sh 400 40],'string','Workspace variables:','horizontalalignment','center');
        sh = sh + 190;
        uicontrol('Units','pixels','position',[10 100+sh 150 250],...
            'Style','list','BackgroundColor',[1 1 1],'Tag','stacklist',...
            'Callback',mycallback,'Max',2);
        uicontrol('Units','pixels','position',[180 100+sh 400 250],...
            'Style','list','BackgroundColor',[1 1 1],'Tag','varlist',...
            'Callback',mycallback,'Max',2);
        uicontrol(button,'position',[180+50 75+sh 70 20],'String','New','Tag','NewVarBt');
        uicontrol(button,'position',[180+75+5+50 75+sh 70 20],'String','Delete','Tag','DeleteVarBt');
        uicontrol(button,'position',[10 75+sh 70 20],'String','New','Tag','NewStackBt');
        uicontrol(button,'position',[10+70+5 75+sh 70 20],'String','Edit','Tag','EditStackBt');

        ud.ds = dirstruct(experdir);
        %ud.persistent=1;

        set(fig,'userdata',ud);
        twophotonbulkload('UpdateBt',fig);


    case 'UpdateBt',
        pathname = get(ft(fig,'PathnameEdit'),'string');
        try newds = dirstruct(pathname);
        catch
            errordlg(['Error in pathname: ' lasterr '.']);
            newds = [];
        end;
        if ~isempty(newds),
            ud.ds = newds;
            set(fig,'userdata',ud);
            twophotonbulkload('UpdateStackList',fig);
            twophotonbulkload('UpdateVarList',fig);
        end;
    case 'NewVarBt',
        tpassociatelistglobals;
        prompt={'Type (case and spelling must be same across experiments)',...
            'Owner (e.g., ''twophoton'')','data (can be any evaluatable expression)','description'};
        name = 'Enter new variable'; numlines = 1;
        defaultanswer = {'''Dark reared''','''twophoton''','0','''Was the animal dark reared?'''};
        answer = inputdlg(prompt,name,numlines,defaultanswer);
        if ~isempty(answer),
            try
                type = eval(answer{1}); owner = eval(answer{2}); data = eval(answer{3}); desc=eval(answer{4});
                if ~isa(type,'char'), error(['Type must be a string.']); end;
                if ~isa(owner,'char'), error(['Owner must be a string.']); end;
                if ~isa(desc,'char'), error(['Description must be a string.']); end;
                newassoc = struct('type',type,'owner',owner,'data',eval(answer{3}),...
                    'desc',eval(answer{4}));
                tpassociatelist(end+1) = newassoc;
                twophotonbulkload('UpdateVarList',fig);
            catch
                errordlg(['Error in making new variable: ' lasterr '.']);
            end;
        end;
    case 'DeleteVarBt',
        tpassociatelistglobals;
        buttonname = questdlg('Are you sure you want to delete the selected variables?','Are you sure?',...
            'Yes','Cancel','Yes');
        if strcmp(buttonname,'Yes'),
            tpassociatelist;
            v_ = get(ft(fig,'varlist'),'value');
            vars = get(ft(fig,'varlist'),'string');
            bad = 0;
            for i=1:length(v_),  % check to make sure these are still in memory as they were
                if ~strcmp(associate2str(tpassociatelist(v_(i))),vars{v_(i)}),
                    bad = 1;
                end;
            end;
            if ~bad,
                tpassociatelist = tpassociatelist(setdiff(1:length(vars),v_));
                twophotonbulkload('UpdateVarList',fig);
            else
                errordlg(['Could not delete...information has changed in memory.  Try Update first.']);
            end;
        end;
    case 'NewStackBt',
        prompt={'New stack name: '}; name='New stack name'; numlines=1;
        answer = inputdlg(prompt,name,numlines);
        if ~isempty(answer),
            analyzetpstack(getpathname(ud.ds),answer{1});
        end;
    case 'EditStackBt',
        v = get(ft(fig,'stacklist'),'value');
        stacks = get(ft(fig,'stacklist'),'string');
        path = fixpath(getpathname(ud.ds));
        for i=1:length(v),
            analyzetpstack(path,stacks{v(i)});
            drawnow;
            analyzetpstack('loadBt',[],gcf);
        end;
        twophotonbulkload('UpdateBt',fig);
    case 'UpdateStackList',
        scratchname  = fixpath(getscratchdirectory(ud.ds,1));
        thedir = dir([scratchname '*.stack']);
        stackstrs = {};
        for i=1:length(thedir),
            stackstrs{i} = thedir(i).name(1:end-6);
        end;
        if isempty(stackstrs), stackstrs = ''; end;
        set(ft(fig,'stacklist'),'string',stackstrs,'value',[]);
        twophotonbulkload('EnableDisable',fig);
    case 'UpdateVarList',
        tpassociatelistglobals;
        varstr = {};
        for i=1:length(tpassociatelist),
            varstr{i} = associate2str(tpassociatelist(i));
        end;
        if isempty(varstr), varstr = ''; end;
        set(ft(fig,'varlist'),'string',varstr,'value',[]);
        twophotonbulkload('EnableDisable',fig);
    case 'EnableDisable',
        v = get(ft(fig,'stacklist'),'value'); stackstr = get(ft(fig,'stacklist'),'string');
        v_ = get(ft(fig,'varlist'),'value'); varstr = get(ft(fig,'varlist'),'string');
        if length(v)>=1 && isa(stackstr,'cell'),
            set(ft(fig,'EditStackBt'),'enable','on');
        else
            set(ft(fig,'EditStackBt'),'enable','off');
        end;
        if length(v_)>=1 && isa(varstr,'cell'),
            set(ft(fig,'DeleteVarBt'),'enable','on');
        else
            set(ft(fig,'DeleteVarBt'),'enable','off');
        end;
    case 'stacklist',
        twophotonbulkload('EnableDisable',fig);
    case 'varlist',
        twophotonbulkload('EnableDisable',fig);
    otherwise,
        disp(['Unhandled command: ' command '.']);
end;

% speciality functions

function obj = ft(fig, name)
obj = findobj(fig,'Tag',name);

function str = associate2str(assoc)
if isnumeric(assoc),
    datastr = assoc.data;
else
    switch class(assoc.data),
        case {'double', 'int16','int8','int32'},
            datastr = num2str(assoc.data);
        case 'struct',
            datastr = '<structdata>';
        case 'cell',
            datastr = '<celldata>';
        case 'char',
            datastr = assoc.data;
        otherwise,
            datastr = '<cannotdisplaytype>';
    end;
end;
str = [assoc.type ' | ' datastr ];

