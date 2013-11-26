function newud = generate_roidb_callback( ud )
%GENERATE_ROIDB_CALLBACK
%
% 2013, Alexander Heimel

ud.db = generate_roidb;
ud.ind=(1:length(ud.db));
ud.changed=1;
set(ud.h.fig,'userdata',ud);
control_db_callback(ud.h.filter);
control_db_callback(ud.h.current_record);
newud = ud;

