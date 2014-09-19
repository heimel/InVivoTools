function stim = figuregroundstim(params, OLDSTIM)

%  NewStim package:  LAMMESTIM
%        based on stimulus described in Lamme J Neurosci 1995
%
%  STIM = LAMMESTIM(PARAMETERS)
%
%  Creates a lammestim object.
%
%  PARAMETERS can either be the string 'graphical' (which will prompt the
%  user to enter all of the parameter values), the string 'default' (which will
%  use default parameter values), or a structure.  When using 'graphical', one
%  may also use
%
%  STIM = LAMMESTIM('graphical',OLDSTIM)
%
%  where OLDSTIM is a previously created hupestim object.  This will
%  set the default parameter values to those of OLDSTIM.
%
%  If passing a structure, the structure should have the following fields:
%  (dimensions of parameters are given as [M N]; fields are case-sensitive):
%
%  LAMMESTIM('help') gives explanation of all parameters and default values
%
%
% typenumber| fig motion  | gnd motion   | fixed aper | figure percept 
% ----------|-------------|--------------|------------------
%   1       | figdir      | no           | yes        | yes
%   2       | no          | gnddir       | irrelevant | yes
%   3       | figdir      | gnddir       | yes        | no
%   4       | figdir      | gnddir + 180 | yes        | yes
%   5       | figdir + 180| gnddir       | yes        | yes
%   6       | figdir + 180| gnddir + 180 | yes        | no
%   7       | figdir      | no           | no         | yes
%   8       | figdir      | gnddir       | no         | no
% ------------------------------------------------------------------
%
%
% 2010, Alexander Heimel
%

if nargin<2
    oldstim=[];
else
    oldstim = OLDSTIM;
end;
if nargin<1
    params='default';
end


fields = {'field', 'default', 'size', 'range', 'explanation'};
paramlist = cell2struct({'rect', '[0 0 640 480]', [1 4],[0 2400],'Location on window [top_x top_y bottom_x bottom_y]'},fields,2);
paramlist(end+1) = cell2struct({'BG', '[255 255 255]/2', [1 3],[1 256],'Background color [r g b]'},fields,2);
paramlist(end+1) = cell2struct({'figcenter', '[320 240]', [1 2],[0 1200],'Figure center location [x y]'},fields,2);
paramlist(end+1) = cell2struct({'figsize', '[80 80]', [1 2],[0 360],'Size of figure [width height] (degrees)'},fields,2);
paramlist(end+1) = cell2struct({'figcontrast', '1', [1 1],[-1 1],'Contrast of figure, (L_fig-L_BG)/L_BG'},fields,2);
paramlist(end+1) = cell2struct({'figbg', '[255 255 255]/2', [1 3],[1 256],'Figure background color [r g b]'},fields,2);
paramlist(end+1) = cell2struct({'figdirection', '45', [1 1],[0 359],'Direction of figure movement (deg)'},fields,2);
paramlist(end+1) = cell2struct({'figspeed', '30', [1 1],[0 100],'Speed of figure (deg/s)'},fields,2);
paramlist(end+1) = cell2struct({'figshape', '0', [1 1],[0 2],'Figure shape, 0=rect, 1=oval, 2=polygon'},fields,2);
paramlist(end+1) = cell2struct({'figorientation', 'NaN', [1 1],[0 359],'Figure orientation (deg) for rect and polygon shape. NaN to match figure direction'},fields,2);
paramlist(end+1) = cell2struct({'figpolygon', '[]', [nan 2],[0 1200],'Polygon point list, only relevant for polygon shape'},fields,2);
paramlist(end+1) = cell2struct({'figtextureparams', '[20 5 0.5 NaN]', [1 4],[0 359],'Figure texture parameters (width length density angle)'},fields,2);
paramlist(end+1) = cell2struct({'fixed_aperture', '1', [1 1],[0 359],'Figure moves within fixed aperture'},fields,2);
paramlist(end+1) = cell2struct({'rf_clearance_radius', '0', [1 1],[0 inf],'Radius around figure center to be free of ground'},fields,2);
paramlist(end+1) = cell2struct({'gndcontrast', '1', [1 1],[-1 1],'Contrast of ground, (L_gnd-L_BG)/L_BG'},fields,2);
paramlist(end+1) = cell2struct({'gndbg', '[255 255 255]/2', [1 3],[1 256],'Ground background color [r g b]'},fields,2);
paramlist(end+1) = cell2struct({'gndspeed', 'NaN', [1 1],[0 100],'Speed of ground (deg/s). Negative would be opposite direction. Use NaN to match figure.'},fields,2);
paramlist(end+1) = cell2struct({'gnddirection', 'NaN', [1 1],[0 359],'Direction of ground movement (deg). Use NaN to match figure.'},fields,2);
paramlist(end+1) = cell2struct({'gndtextureparams', 'NaN', [1 nan],[0 359],'Ground texture parameters. Use NaN to match figure.'},fields,2);
paramlist(end+1) = cell2struct({'figure_onset', '2', [1 1],[0 inf],'Time of figure onset (s)'},fields,2);
paramlist(end+1) = cell2struct({'movement_onset', '2', [1 1],[0 inf],'Time of movement onset (s)'},fields,2);
paramlist(end+1) = cell2struct({'movement_duration', 'NaN', [1 1],[0 inf],'Duration of movement (s). Use NaN to continue until end'},fields,2);
paramlist(end+1) = cell2struct({'duration', '5', [1 1],[0 inf],'Total stimulus duration (stationary plus moving time)'},fields,2);
paramlist(end+1) = cell2struct({'framerate', '15', [1 1],[0 inf],'Framerate (lower than monitor rate to reduce memory load)'},fields,2);
paramlist(end+1) = cell2struct({'randState', '0', [nan 1],[0 1],'State to use as seed for generating random numbers, e.g. rand(''state'')'},fields,2);
paramlist(end+1) = cell2struct({'randsamples', '4', [1 1],[1 inf],'Number of different texture samples, used for scripts only'},fields,2);
%paramlist(end+1) = cell2struct({'randsamples', '2', [1 1],[1 inf],'Number of different texture samples, used for scripts only'},fields,2);
paramlist(end+1) = cell2struct({'displayprefs', '{''BGpretime'',nan,''BGposttime'',nan}', [],[],'Sets displayprefs fields, or use {} for default values'},fields,2);
paramlist(end+1) = cell2struct({'typenumber', '3', [1 1],[1 inf],'Used for decoding, see HELP LAMMESTIM'},fields,2);

default_params = get_default_params( paramlist );

if ischar(params)
    switch lower(params)
        case 'help'
            for i=1:length(paramlist)
                disp([paramlist(i).field  ' - ' paramlist(i).explanation ' = ' paramlist(i).default ]);
            end
            stim = [];
            return
        case 'graphical'
            % load parameters graphically, check values
            if ~isempty(oldstim)
                initial_params = getparameters( oldstim);
            else
                initial_params = default_params;
            end
            params = get_graphical_input(paramlist, initial_params);
            if isempty(params)
                stim = [];
                return
            end
        case 'default'
            params = default_params;
        otherwise
            error('Unknown string input to stim.');
    end;
else  % params are just parameters
    [good, err] = verifystim(params,paramlist);
    if ~good
        error(['Could not create stim: ' err]);
    end;
end;
% now params contains parameter struct

% interpret typenumber
switch params.typenumber
    case 1 % | figdirection    | no              | yes
        params.figure_moves = 1;    params.reverse_figdirection = 0;
        params.ground_moves = 0;   params.reverse_gnddirection = 0;
        params.fixed_aperture = 1;
    case 2 % | no              | gnddirection    | yes
        params.figure_moves = 0;   params.reverse_gnddirection = 0;
        params.ground_moves = 1;    params.reverse_figdirection = 0;
        params.fixed_aperture = 1;
    case 3 % | figdirection    | gnddirection    | no
        params.figure_moves = 1;    params.reverse_figdirection = 0;
        params.ground_moves = 1;    params.reverse_gnddirection = 0;
        params.fixed_aperture = 1;
    case 4 % | figdirection    | gnddirection+180| yes
        params.figure_moves = 1;    params.reverse_figdirection = 0;
        params.ground_moves = 1;    params.reverse_gnddirection = 1;
        params.fixed_aperture = 1;
    case 5 % | figdirection+180| gnddirection    | yes
        params.figure_moves = 1;    params.reverse_figdirection = 1;
        params.ground_moves = 1;    params.reverse_gnddirection = 0;
        params.fixed_aperture = 1;
    case 6 % | figdirection+180| gndirection+180 | no
        params.figure_moves = 1;    params.reverse_figdirection = 1;
        params.ground_moves = 1;    params.reverse_gnddirection = 1;
        params.fixed_aperture = 1;
	case 7 % | both figure and ground static (Joris)
        params.figure_moves = 0;    params.reverse_figdirection = 0;
        params.ground_moves = 0;   params.reverse_gnddirection = 0;
        params.fixed_aperture = 0;
%     case 7 % | figdirection    | no              | yes
%         params.figure_moves = 1;    params.reverse_figdirection = 0;
%         params.ground_moves = 0;   params.reverse_gnddirection = 0;
%         params.fixed_aperture = 0;
    case 8 % | figdirection    | gnddirection    | no
        params.figure_moves = 1;    params.reverse_figdirection = 0;
        params.ground_moves = 1;    params.reverse_gnddirection = 0;
        params.fixed_aperture = 0;
    otherwise
        params.figure_moves = 1;
        params.reverse_figdirection = 0;
        params.ground_moves = 0;
        params.reverse_gnddirection = 0;
        % change nothing

end

% make stimulus object from parameters
dp = {'fps', -1, 'rect',params.rect, 'frames',[], params.displayprefs{:}};

s = stimulus(5);
stim = class(struct('params',params),'figuregroundstim',s);
stim.stimulus = setdisplayprefs(stim.stimulus,displayprefs(dp));
return

%%
function params = get_graphical_input(paramlist, initial_params)
dy = 25; % in points
height = dy * round(length(paramlist)/2) + 120; % points

% create figure
h0 = figure('Color',[0.8 0.8 0.8],'menubar','none','units',...
    'points','name','New lammestim object',...
    'numbertitle','off');
set(gcf,'Position',[140 40 500 height]); % separate to use right units
rect = get(gcf,'Position');
settoolbar(h0,'none');

ok_ctl = uicontrol('Parent',h0, 'Units','points',  ...
    'BackgroundColor',[0.7 0.7 0.7], 'FontWeight','bold', ...
    'Position',[36 22 71 27], 'String','OK', 'Tag','Pushbutton1',...
    'Callback', 'set(gcbo,''userdata'',[1]);uiresume(gcf);', ...
    'userdata',0);
cancel_ctl = uicontrol('Parent',h0, 'Units','points', ...
    'BackgroundColor',[0.7 0.7 0.7], 'FontWeight','bold', ...
    'Position',[173 24 71 27], 'String','Cancel', 'Tag','Pushbutton1', ...
    'Callback', 'set(gcbo,''userdata'',[1]);uiresume(gcf);', ...
    'userdata',0);
uicontrol('Parent',h0, 'Units','points', ...
    'BackgroundColor',[0.7 0.7 0.7], ...
    'FontWeight','bold', 'Position',[304 25 71 27], 'String','Help', ...
    'Tag','Pushbutton1',...
    'Callback', ...
    'textbox(''help'',help(''lammestim''));');

edit_handle = zeros( length(paramlist),1);
left = 10;
		guicreate( 'text', 'string','','left',left,'top','top','move','down');
for i=1:length(paramlist)
    str = var2str( getfield( initial_params, paramlist(i).field )); %#ok<GFLD>
    edit_handle(i) = guicreate( 'text', 'string',paramlist(i).field,'left',left,'TooltipString',paramlist(i).explanation,'move','right');
    edit_handle(i) = guicreate( 'edit', 'string',str,'TooltipString',paramlist(i).explanation);
	
	if i==round(length(paramlist)/2)
		left = rect(3)/2 + 20;
		guicreate( 'text', 'string','','left',left,'top','top','move','down');
	end
end

error_free = 0;
params = [];
while ~error_free,
    drawnow;
    uiwait(h0);

    if get(cancel_ctl,'userdata')==1,
        error_free = 1;
    else % it was OK
        good = 1;
        for i = 1:length(paramlist)
            try
                if iscell( getfield( initial_params, paramlist(i).field)) %#ok<GFLD>
                    params = setfield(params,paramlist(i).field,eval(get(edit_handle(i),'string'))); %#ok<SFLD>
                elseif ischar( getfield( initial_params, paramlist(i).field)) %#ok<GFLD>
                    params = setfield(params,paramlist(i).field,get(edit_handle(i),'string')); %#ok<SFLD>
                else
                    params = setfield(params,paramlist(i).field,eval(get(edit_handle(i),'string'))); %#ok<SFLD>
                end
            catch  %#ok<CTCH>
                good = 0;
                disp(['Invalid input for parameter ' paramlist(i).field ]);
            end
        end

        if good
            [good, err] = verifystim(params, paramlist);
            if ~good
                errordlg(['Parameter value invalid: ' err]);
                set(ok_ctl,'userdata',0);
            else
                error_free = 1;
            end;
        else
            set(ok_ctl,'userdata',0);
        end;
    end;
end;

if get(ok_ctl,'userdata')~=1
    params = [];
end;
delete(h0);

%%
function default_params = get_default_params( paramlist )
default_params=[];
for i=1:length(paramlist)
    default_params = setfield( default_params, paramlist(i).field, eval(paramlist(i).default)); %#ok<SFLD>
end
