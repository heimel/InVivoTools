function set_screentool_cr(cr)
%SET_SCREENTOOL_CR sets screentool rectangle and opens one if necessary
%
%  SET_SCREENTOOL_CR(CR)
%
%  Alexander Heimel (heimel@brandeis.edu)
%

  z2= geteditor('screentool');
  if isempty(z2),
    z2=figure;
    screentool(z2);
  end;
  udz = get(z2,'userdata');
  set(udz.currrect,'String',mat2str(cr));
  screentool('plotcurr',z2);

