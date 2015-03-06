function ud = new_wctestrecord(ud)
%NEW_WCTESTRECORD create new tptestrecord 
%
%   UD=NEW_WCTESTRECORD(UD)
%       stimulus specific parameters are in this file
%
% 2014, Alexander Heimel
%
  
% call general new record
control_db_callback(ud.h.new);
ud=get(ud.h.fig,'UserData');
record = ud.db(ud.current_record);

record.datatype = 'wc';
record.setup = host;

% if not first test, then we could copy somethings from the previous
if ud.current_record>1
  prev_record=ud.db(ud.current_record-1);
  
  % if on the same day, we could even copy some more
  [y,m,d]=datevec(now);
  datetext=sprintf('%04d-%02d-%02d',y,m,d);
  if isempty(record.date) && ...
      isempty(record.mouse) && ...
      strcmp(prev_record.date,datetext)==1

    record.mouse=prev_record.mouse;
    record.experiment = prev_record.experiment;
    record.date=prev_record.date;
    record.experimenter=prev_record.experimenter;
    if isempty(prev_record.epoch)
        newtestnum = 1;
    else
        prevtest=eval(prev_record.epoch(2:end));
        newtestnum=prevtest+1;
    end
  else
    record.date=datetext;
    newtestnum=1;
  end

end
record.epoch=['t' num2str(newtestnum,'%05d')];

ud.db(ud.current_record)=record;

set(ud.h.fig,'UserData',ud);



      