function textbox(title, str)

%  Part of the NewStim package
%
%  TEXTBOX(TITLE,STR)
%
%  Displays the text in the string STR in a new window with title TITLE.
%  The only button is an OK button to dismiss the window.
%
%  Questions to vanhoosr@brandeis.edu


h0 = figure('Color',[0.8 0.8 0.8], ...
        'PaperUnits','points', ...
        'Position',[200 200 650 590], ...
        'Tag','Fig1', ...
        'ToolBar','none', ...
	'MenuBar','none','Name',title);
lb = uicontrol('Parent',h0, ...
        'Units','points', ...
        'BackgroundColor',[1 1 1], ...
        'Position',[0.4 68.8 500 400.4], ...
        'String',' ', ...
        'Style','listbox', ...
        'Tag','Listbox1', ...
        'Value',[],'Max',2,'FontName','Courier');
ok = uicontrol('Parent',h0, ...
        'Units','points', ...
        'BackgroundColor',[0.7 0.7 0.7], ...
        'ListboxTop',0, ...
        'Position',[192.8 28 67.2 24.8], ...
        'String','OK', ...
        'Tag','Pushbutton1', ...
	'Callback', 'close(gcbf)');

g = textwrap(lb,{str});
set(lb,'String',g);
