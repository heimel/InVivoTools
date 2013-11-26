function newud=show_mouseinfo( ud )
%SHOW_MOUSEINFO
%
% NEWUD = SHOW_MOUSEINFO( UD )
%
% 2006, Alexander Heimel
%

newud=ud;
db=ud.db(ud.ind);
record=ud.db(ud.current_record);

if ~isempty(record.tg_number)
  micefrommdb(record.tg_number)
end

if ~isempty(record.iue)
  iueinfo=get_iue_info(record.iue);
  iueinfo.raw
  iueinfo
end










