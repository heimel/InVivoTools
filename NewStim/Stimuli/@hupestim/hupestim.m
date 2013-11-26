function [stim] = hupestim(params, OLDSTIM)

%  NewStim package:  HUPESTIM
%        based on stimulus described in Hupe et al. Nature 1998
%
%  STIM = HUPESTIM(PARAMETERS)
%
%  Creates a hupestim object.
%
%  PARAMETERS can either be the string 'graphical' (which will prompt the
%  user to enter all of the parameter values), the string 'default' (which will
%  use default parameter values), or a structure.  When using 'graphical', one
%  may also use
%
%  STIM = HUPESTIM('graphical',OLDSTIM)
%
%  where OLDSTIM is a previously created hupestim object.  This will
%  set the default parameter values to those of OLDSTIM.
%
%  If passing a structure, the structure should have the following fields:
%  (dimensions of parameters are given as [M N]; fields are case-sensitive):
%
%  HUPESTIM('help') gives explanation of all parameters and default values
%
% 2009, Alexander Heimel
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
paramlist(end+1) = cell2struct({'center', '[320 240]', [1 2],[0 1200],'Center location [x y]'},fields,2);
paramlist(end+1) = cell2struct({'BG', '[255 255 255]/3', [1 3],[1 256],'Background color [r g b]'},fields,2);
paramlist(end+1) = cell2struct({'direction', '0', [1 1],[0 359],'Direction of movement. Bar orientation is orthogonal to this.'},fields,2);
paramlist(end+1) = cell2struct({'width', '10', [1 1],[0 360],'Width of figure and ground bars (degrees)'},fields,2);
paramlist(end+1) = cell2struct({'figlength', '30', [1 1],[0 359],'Length of figure bar (degrees)'},fields,2);
paramlist(end+1) = cell2struct({'figcontrast', '1.0', [1 1],[-1 1],'Contrast of figure bar, (L_fig-L_BG)/L_BG'},fields,2);
paramlist(end+1) = cell2struct({'gndcontrast', '1.0', [1 1],[-1 1],'Contrast of ground bars, (L_gnd-L_BG)/L_BG'},fields,2);
paramlist(end+1) = cell2struct({'gndlengthrange', '[0.2 1]', [1 2],[0 100],'Range of ground bar lengths as proportion of figlength'},fields,2);
paramlist(end+1) = cell2struct({'gnddensity', '0.5', [1 1],[0 10],'Filling density of screen by ground bars'},fields,2);
paramlist(end+1) = cell2struct({'figspeed', '20', [1 1],[0 100],'Speed of figure (deg/s)'},fields,2);
paramlist(end+1) = cell2struct({'gndspeed', '20', [1 1],[0 100],'Speed of ground (deg/s). Negative would be opposite direction.'},fields,2);
paramlist(end+1) = cell2struct({'rf_clearance_radius', '20', [1 1],[0 inf],'Radius around center to be free of ground bars'},fields,2);
paramlist(end+1) = cell2struct({'movement_onset', '2', [1 1],[0 inf],'Time of movement onset (s).'},fields,2);
paramlist(end+1) = cell2struct({'duration', '3', [1 1],[0 inf],'Total stimulus duration (stationary plus moving time)'},fields,2);
paramlist(end+1) = cell2struct({'randState', 'rand(''state'')', [35 1],[0 1],'State to use as seed for generating random numbers.'},fields,2);
paramlist(end+1) = cell2struct({'displayprefs', '{''BGpretime'',3}', [],[],'Sets displayprefs fields, or use {} for default values.'},fields,2);
paramlist(end+1) = cell2struct({'typenumber', '3', [1 1],[1 inf],'Used for decoding. 1=A, 2=B, 3=C, 4=D'},fields,2);

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

% make stimulus object from parameters
dp = {'fps', -1, 'rect',params.rect, 'frames',[], params.displayprefs{:}};
s = stimulus(5);
stim = class(struct('params',params),'hupestim',s);
stim.stimulus = setdisplayprefs(stim.stimulus,displayprefs(dp));

%s = moviestim([]);
%stim = class(struct('params',params),'hupestim',s);
%stim = setdisplayprefs(stim,displayprefs(dp));
return


function params = get_graphical_input(paramlist, initial_params)
dy = 25; % in points
height = dy * length(paramlist) + 120; % points

% create figure
h0 = figure('Color',[0.8 0.8 0.8],'menubar','none','units',...
    'points','name','New hupestim object',...
    'numbertitle','off');
set(gcf,'Position',[140 200 500 height]); % separate to use right units
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
    'textbox(''help'',help(''hupestim''));');

edit_handle = zeros( length(paramlist),1);
for i=1:length(paramlist)
    str = var2str( getfield( initial_params, paramlist(i).field )); %#ok<GFLD>
    edit_handle(i) = guicreate( 'text', 'string',paramlist(i).field,'TooltipString',paramlist(i).explanation,'left',10,'move','right');
    edit_handle(i) = guicreate( 'edit', 'string',str,'TooltipString',paramlist(i).explanation);
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


function default_params = get_default_params( paramlist )
default_params=[];
for i=1:length(paramlist)
    default_params = setfield( default_params, paramlist(i).field, eval(paramlist(i).default)); %#ok<SFLD>
end
