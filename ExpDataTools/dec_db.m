function fig=dec_db
%DEC_DB starts dec protocol database
%
%  FIG=DEC_DB
%
% 20012, Alexander Heimel
%

filename = fullfile( expdatabasepath(), 'decdb.mat');

h_fig=control_db(filename,[1 0 0]); 

set(h_fig,'Name',['DEC database']);

if nargout==1
  fig=h_fig;
end

left=10;
buttonwidth=65;
colsep=3;
buttonheight=30;
top=10;

% extra buttons:
ud=get(h_fig,'UserData');
h=ud.h;


  h.show = ...
   uicontrol('Parent',h_fig, ...
   'Units','pixels', ...
   'BackgroundColor',0.8*[1 1 1],...
   'Callback','genercallback', ...%   'ListboxTop',0, ...
   'Position',[left top buttonwidth buttonheight], ...
   'String','Show', ...
   'Tag','show_protocol');
 left=left+buttonwidth+colsep;

   h.available = ...
   uicontrol('Parent',h_fig, ...
   'Units','pixels', ...
   'BackgroundColor',0.8*[1 1 1],...
   'Callback',[ ...
   'ud=get(gcf,''userdata'');record=ud.db(ud.current_record);'...
   'dec_group_numbers( record.protocol,true )'...
   ]', ...%   'ListboxTop',0, ...
   'Position',[left top buttonwidth buttonheight], ...
   'String','Available', ...
   'Tag','available');
 left=left+buttonwidth+colsep;

 h.cageform = ...
   uicontrol('Parent',h_fig, ...
   'Units','pixels', ...
   'BackgroundColor',0.8*[1 1 1],...
   'Callback','genercallback', ...%   'ListboxTop',0, ...
   'Position',[left top buttonwidth+30 buttonheight], ...
   'String','Welfare form', ...
   'Tag','generate_cageform');
 left=left+buttonwidth+30+colsep;

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
left=left+buttonwidth+colsep; %#ok<NASGU>
 
% h.schedule = ...
%   uicontrol('Parent',h_fig, ...
%   'Units','pixels', ...
%   'BackgroundColor',0.8*[1 1 1],...
%   'Callback','genercallback', ...
%   'ListboxTop',0, ...
%   'Position',[left top buttonwidth buttonheight], ...
%   'String','Schedule', ...
%   'Tag','make_schedule');
% left=left+buttonwidth+colsep;



ud.h=h;
set(h_fig,'UserData',ud);
control_db_callback( h.current_record );





