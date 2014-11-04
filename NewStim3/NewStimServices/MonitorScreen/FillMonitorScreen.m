function FillMonitorScreen(color)

% function FillMonitorScreen(color)
%
%  FillMonitorScreen fills the monitor screen with the specified color.  'color'
%  can be an entry of the current color table or an [r g b] triplet
%  (see Screen('FillRect?')).  If there is no monitor window presently, the
%  function merely gives a warning to this effect and does nothing.
%
%  Questions?  vanhoosr@brandeis.edu
%

MonitorWindowGlobals

if ~isempty(MonitorWindow),
	Screen(MonitorWindow,'FillRect',color);
else
	warning('FillMonitorScreen could not draw in empty screen.');
end;
