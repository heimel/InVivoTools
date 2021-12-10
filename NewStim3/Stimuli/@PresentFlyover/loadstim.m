
function [StimObjOut] = loadstim(StimObj)
% LOADSTIM for PRESENTFLYOVER
%
% Robin Haak, 2021

 clut_bg = round(0.5*255)*[1 1 1];

 clut = repmat(linspace(0,1,256)'*255,1,3); 

CellDisplay = { 'displayType', '', 'displayProc', 'customdraw', ...
         'offscreen', NaN, 'frames', [], 'clut_usage', [], 'depth', 8, ...
'clut_bg', clut_bg, 'clut', clut, 'clipRect', [], 'makeClip', 0,'userfield', []};

sDisplay = displaystruct(CellDisplay);

StimObjOut = setdisplaystruct(StimObj,sDisplay);
StimObjOut.stimulus = loadstim(StimObjOut.stimulus);
end