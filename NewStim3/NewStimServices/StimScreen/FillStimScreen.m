function FillStimScreen(color)

% function FillStimScreen(color)
%
%  FillStimScreen fills the stimulus screen with the specified color.  'color'
%  can be an entry of the current color table or an [r g b] triplet
%  (see screen('FillRect?')).  If there is no stimulus window presently, the
%  function merely gives a warning to this effect and does nothing.
%
%  Questions?  vanhoosr@brandeis.edu
%

StimWindowGlobals

if ~isempty(StimWindow),
	Screen(StimWindow,'FillRect',color);
else,
	warning('FillStimScreen could not draw in empty screen.');
end;
