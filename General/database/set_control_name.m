function set_control_name( h )
%SET_CONTROL_NAME sets database control name
%
%  set_control_name( h )
%
%    h: figure handle of control_db figure
%
% 200X, Alexander Heimel

ud = get(h,'Userdata');

[pth,filename,ext] = fileparts(ud.filename);
set(ud.h.fig,'Name',[capitalize(ud.type) ' database - ' filename]);