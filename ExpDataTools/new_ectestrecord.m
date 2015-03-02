function ud=new_ectestrecord(ud)
%NEW_ECTESTRECORD create new ectestrecord 
%
%   UD=NEW_ECTESTRECORD(UD)
%       stimulus specific parameters are in this file
%
% 2007, Alexander Heimel
%
  
tests = get(ud.h.which_test,'String');
test = tests(get(ud.h.which_test,'Value'),:);
test = strtrim(lower(test));

% call general new record
control_db_callback(ud.h.new);
ud=get(ud.h.fig,'UserData');
record=ud.db(ud.current_record);

switch test
	case {'pp','io'}
		datatype='lfp';
	otherwise
		datatype='ec';
end


record=set_record(record,ectestrecord_defaults(datatype));
record.stim_type=test;

% if not first test, then we could copy somethings from the previous
if ud.current_record>1
  prev_record=ud.db(ud.current_record-1);
  switch record.stim_type
    case {'pp','io'}
      record.datatype='lfp';
    otherwise
      record.datatype='ec';
  end
  
  
  record.setup=prev_record.setup;
  
  % if on the same day, we good even copy some more
  [y,m,d]=datevec(now);
  datetext=sprintf('%04d-%02d-%02d',y,m,d);
  if isempty(record.date) && ...
      isempty(record.mouse) && ...
      strcmp(prev_record.date,datetext)==1

    record.mouse=prev_record.mouse;
    record.date=prev_record.date;
    record.hemisphere=prev_record.hemisphere;
    record.location=prev_record.location;
    record.monitorpos=prev_record.monitorpos;
    record.eye=prev_record.eye;
    record.surface=prev_record.surface;
    record.experimenter=prev_record.experimenter;
    record.electrode=prev_record.electrode;
    record.filter=prev_record.filter;
    record.amplification=prev_record.amplification;
    record.stim_electrode=prev_record.stim_electrode;

    prevtest=eval(prev_record.test(2:end));
    newtestnum=prevtest+1;
  else
    record.date=datetext;
    newtestnum=1;
  end

end
record.test=['t' num2str(newtestnum,'%05d')];

ud.db(ud.current_record)=record;

set(ud.h.fig,'UserData',ud);



      