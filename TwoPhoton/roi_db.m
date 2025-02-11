function fig=roi_db( testdbfilename )
%ROI_DB starts roi database
%
%  FIG=ROI_DB
%
% 2013, Alexander Heimel
%

disp('ROI_DB: WORKING HERE');

[roidb,filename]=load_roidb;

if isempty(roidb)
   roidb = generate_roidb;
   filename = save_db(roidb,filename);
end

[dbpath,dbfilename]=fileparts(filename);
dbfile=fullfile(dbpath,dbfilename);

h_fig=control_db(filename,[0.5 0.9 0.5]); % which will load the file again
set(h_fig,'Name','ROI database');

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

h.regenerate = ...
    uicontrol('Parent',h_fig, ...
    'Units','pixels', ...
    'BackgroundColor',0.8*[1 1 1],...
    'Callback','genercallback', ...
    'ListboxTop',0, ...
    'Position',[left top buttonwidth buttonheight], ...
    'String','Regenerate', ...
    'Tag','generate_roidb_callback');
left=left+buttonwidth+colsep;

ud.h=h;
set(h_fig,'UserData',ud);


