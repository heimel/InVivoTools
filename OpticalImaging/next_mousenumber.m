function newud=next_mousenumber( ud )
%NEXT_MOUSENUMBER
%
% NEWUD = NEXT_MOUSENUMBER( UD )
%
% 2005, Alexander Heimel
%

newud=ud;
db=ud.db(ud.ind);
record=ud.db(ud.current_record);

mouse=record.mouse;
pos=find(mouse=='.');
if length(pos)==1
  mouse=[mouse '.0'];
  pos=find(mouse=='.');
end
switch length(pos)
 case 0,
  disp('No dots found in mouse number. (example 05.01.2.15)');
 case 2
  ind=find_record(db,['mouse=' mouse '*']);
  mice={db(ind).mouse};
  mice=sort(mice);
  if ~isempty(mice)
    last=mice{end};
    pos=find(last=='.');
    number=eval(last(pos(end)+1:end))+1;
    fmt=['%0' num2str( length(last)-pos(end) ) 'd'];
    mouse=[ last(1:pos(end)) num2str(number,fmt) ];
  else
    mouse=[mouse '.001'];
  end
  newud.db(ud.current_record).mouse=mouse;
  newud.changed=1;
 case 3
  disp('Mouse number already complete.');
 otherwise
  disp('Faulty mouse number. (example 05.01.2.15)');
end









