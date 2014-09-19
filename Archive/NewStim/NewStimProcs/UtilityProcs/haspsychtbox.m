function b = haspsychtbox

% Part of the NewStim package
%
% B = HASPSYCHTBOX
%
%  Returns 1 if the Psychophysics toolbox is installed, and 0 otherwise.
%
%                             Questions to vanhoosr@brandeis.edu
% 2004-04-07 AH: Removed MAC2 check and changed serial to psychserial
% 2007-03-26 AH: Removed everything but check for 'screen'

b = 0;
if exist('screen')
  b = 1; 
end

