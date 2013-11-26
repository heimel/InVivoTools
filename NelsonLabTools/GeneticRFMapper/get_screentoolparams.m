function [cr,dist,sr]=get_screentoolparams()
%GET_SCREENTOOLPARAMS calls getscreentoolparams, but opens screentool if necessary

%   [CR,DIST,SR]=GET_SCREENTOOLPARAMS()
%     Also it sets a rectangle if none is set yet
%
%  Alexander Heimel (heimel@brandeis.edu)
%

  z2= geteditor('screentool');
  if isempty(z2),
    z2=figure;
    screentool(z2);
  end;
  [cr,dist,sr] = getscreentoolparams;
  if isempty(cr),
    udz = get(z2,'userdata');
    set(udz.currrect,'String',mat2str(round(20*[-1 -1 1 1]+...
					    [sr(3)/2 sr(4)/2 sr(3)/2 sr(4)/2] )));
    screentool('plotcurr',z2);
  end;
  [cr,dist,sr]=getscreentoolparams;
