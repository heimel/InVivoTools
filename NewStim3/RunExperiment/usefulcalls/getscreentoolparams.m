function [rect,dist,sr] = getscreentoolparams;

%  GETSCREENTOOLPARAMS - returns receptive field parameters
%  Part of NelsonLabTools
%  
%  [RECT,DIST,SR] = GETSCREENTOOLPARAMS
%
%  Returns parameters associated with screentool.
%
%  RECT is the current rect from the text field in screentool.
%  DIST is the monitor distance as read from the text field in screentool.
%  SR   is the monitor bounds (e.g., [0 0 640 480]).
%
%  If these fields are not valid, empty is returned.

z = geteditor('screentool');
if ~isempty(z),
   screentoolstruct = get(z,'userdata');
   rectstr = get(screentoolstruct.currrect,'String');
   try, eval(['rect = ' rectstr ';']);
   catch, rect = [];
   end;
   diststr = get(screentoolstruct.mondist,'String');
   try, eval(['dist = ' diststr ';']);
   catch, dist = [];
   end;
   sr2 = screentoolstruct.screensize;
   if isempty(sr2),sr=[]; else, sr=[0 0 sr2]; end;
else, rect=[]; dist = []; sr = [];
end;
if size(rect)~=[1 4], rect = []; end;
if size(dist)~=[1 1], dist = []; end;
if size(sr)~=[1 4], sr = []; end;
