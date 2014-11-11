function s = structgui( s,name)
%STRUCTGUI displays struct and allows edit
%
% S = STRUCTGUI( S )
%
% 2014, Alexander Heimel
%

if nargin<2
    name = '';
end

hrec = show_record(s,[],[],name);
p = get(hrec,'position');
p(4) = p(4)+32;
set(hrec,'WindowStyle','modal');
set(hrec,'CloseRequestFcn','closereq');
set(hrec,'position',p)
button.Units = 'pixels';
button.BackgroundColor = [0.8 0.8 0.8];
button.HorizontalAlignment = 'center';
button.Callback = 'genercallback';
button.Style='pushbutton';
guicreate(button,'String','Ok','left','left','top','top_nomargin','width',60,'height',24,'parent',hrec,'move','right','callback','uiresume');
hcancel = guicreate(button,'String','Cancel','width',60,'height',24,'parent',hrec,'move','right','callback','set(gcbo,''userdata'',[1]);uiresume;');

uiwait(hrec);
if ~ishandle(hrec) % i.e. closed
    return
end
if ~isempty(get(hcancel,'userdata')) % i.e. cancelled
    delete(hrec);
    return
end
s = get_record(hrec);
delete(hrec);
