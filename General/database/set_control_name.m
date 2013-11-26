function set_control_name( h )
%SET_CONTROL_NAME sets database control name

ud = get(h,'Userdata');

[pth,filename,ext] = fileparts(ud.filename);
set(ud.h.fig,'Name',[capitalize(ud.type) ' database - ' filename]);