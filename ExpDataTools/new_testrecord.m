function ud = new_testrecord(ud)
%NEW_TPTESTRECORD create new tptestrecord 
%
%   UD=NEW_TPTESTRECORD(UD)
%       stimulus specific parameters are in this file
%
% 2010-2012, Alexander Heimel
%
      
record=ud.db(ud.current_record);
switch record.datatype
    case 'ec'
        ud = new_ectestrecord(ud);
    case 'tp'
        ud = new_tptestrecord(ud);
    case 'oi'
        ud = new_oitestrecord(ud);
    case 'wc'
        ud = new_wctestrecord(ud);
end

