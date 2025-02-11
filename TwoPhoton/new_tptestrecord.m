function ud = new_tptestrecord(ud)
%NEW_TPTESTRECORD create new tptestrecord 
%
%   UD=NEW_TPTESTRECORD(UD)
%       stimulus specific parameters are in this file
%
% 2010-2012, Alexander Heimel
%
  
tests = get(ud.h.which_test,'String');
test = tests(get(ud.h.which_test,'Value'),:);
test = strtrim(lower(test));

% call general new record
control_db_callback(ud.h.new);
ud=get(ud.h.fig,'UserData');
record=ud.db(ud.current_record);

switch test
	case {'fura','ogb','gfp'}
		datatype='tp';
        record.channels = [531 593]; 
	otherwise
		datatype='tp';
		warning('NEW_TPTESTRECORD:unknown test');
end


record=set_record(record,tptestrecord_defaults(datatype));

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
    record.stack = prev_record.stack;
    record.date=prev_record.date;
    record.hemisphere=prev_record.hemisphere;
    record.location=prev_record.location;
    record.experimenter=prev_record.experimenter;
    %record.filterset=prev_record.filterset;
    record.ref_epoch = prev_record.ref_epoch;
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

laserglobals
record.laser = [num2str(GlobalLaserWavelength) ' nm, ' ...
    num2str(GlobalLaserIncidentPower,2),' W'];

ud.db(ud.current_record)=record;

set(ud.h.fig,'UserData',ud);



      