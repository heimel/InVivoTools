function fig=group_db
%GROUP_DB starts group database (mainly for graphing purposes)
%
%  FIG=GROUP_DB
%
% 2007-2015, Alexander Heimel
%

[groupdb,filename]=load_groupdb;

h_fig=control_db(filename,[1 0.5 0.5]); % which will load the file again
set(h_fig,'Name','Group database');

if nargout==1
    fig=h_fig;
end

left=10;
buttonwidth=70;
colsep=3;
buttonheight=30;
top=10;

% extra buttons:
ud=get(h_fig,'UserData');
h=ud.h;

h.list_group = ...
    uicontrol('Parent',h_fig, ...
    'Units','pixels', ...
    'BackgroundColor',0.8*[1 1 1],...
    'Callback','genercallback', ...
    'ListboxTop',0, ...
    'Position',[left top buttonwidth buttonheight], ...
    'String','List', ...
    'Tag','list_group');
left=left+buttonwidth+colsep;

ud.h=h;
set(h_fig,'UserData',ud);


