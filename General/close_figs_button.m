function close_figs_button
%CLOSE_FIGS_BUTTON creates modal figure with close_figs button
%
% 2012, Alexander Heimel
%

monitorpositions = get(0,'MonitorPositions'); % Could also use Screensize, different on two monitors

if isunix
    p = [monitorpositions(3)-110 31 110 30];
else
    p = [monitorpositions(3)-110 40 110 30];
end
    
h = figure('Name','Close figures','NumberTitle','off','Menubar','none','Toolbar','none',...
    'position',p) ;
drawnow
setAlwaysOnTop(h,true);


button.Units = 'pixels';
button.BackgroundColor = [0.8 0.8 0.8];
button.HorizontalAlignment = 'center';
button.Callback = 'genercallback';
button.Style='pushbutton';

ud.persistent = 1;
set(h,'userdata',ud);

b = guicreate(button,'string','Close figures','top','top')

set(b,'callback','close_figs');

get(h)
