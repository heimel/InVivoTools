%
% StimWindowGlobals
%
% This script declares all of the StimWindow global variables
%
%
%  StimWindow        - The window pointer of the stimulus window, which covers
%                      the full screen.  If it does not exist, this variable is
%                      empty.
%  StimWindowDepth   - The pixel depth of the stimulus window.  The only
%                      supported depth at present is 8.
%  StimWindowRefresh - The refresh rate for the stimulus window.  Only
%                      computed _after_ the window is open.

global StimWindow StimWindowDepth StimWindowRefresh StimWindowRect
