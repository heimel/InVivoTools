function b = haspsychtbox
%haspyschtbox. Returns true if the Psychophysics toolbox is installed
% 
% B = HASPSYCHTBOX
%
%  Returns true if the Psychophysics toolbox is installed, and false otherwise.
%
% 200X, Steve Van Hooser
% 2025, Alexander Heimel

if exist('Screen','file')
    b = true;
else
    b = false;
end

% NewStimGlobals;
% 
% b = NS_PTBv;
% 
% if isempty(b)
%     b = 0;
% end
% 
% return;
% 
%  % should superceed what is below
% 
% b = 0;
% cpustr = computer;
% if strcmp(cpustr,'MAC2')&&exist('Screen')&&exist('Serial'), b = 1; end;
% 
