function newud=make_schedule( ud )
%MAKE_SCHEDULE
%
%  NEWUD=MAKE_SCHEDULE( UD )
%
% 2005, Alexander Heimel
% 2007-03-26, AH: added who column from actions (everything behind colon)

  newud=ud;
  db=ud.db(ud.ind);
  
  
  fromn=now-1;
  untiln=fromn+60;
  
  clc
  disp([ 'Schedule']);
  
  entries={};
  
  header=sprintf( '%-10s %s %-12s %-3s mouse      %3s %-13s %10s   %s',...
	   'date','day',...
	   'action','who',...
	   'cage','strain/tg_num','birthdate','type');
  disp(header);
  disp('_________________________________________________________________________________');
  

  for i=1:length(db)

    
    actions=db(i).actions;
    if iscell(actions)
      actions=actions{1};
    end
    if ~isempty(actions)
      try
	actions=eval(actions);
	for a=1:2:length(actions)
	  date=actions{a};
	  action=actions{a+1};
	  daten=date2num(date);
	  if fromn<=daten & untiln>=daten
	    cage=db(i).cage;
	    if isempty(cage)
	      cage='';
	    else
	      cage=num2str(cage);
	    end
	    strain=db(i).strain;
	    if strcmp(db(i).strain,'hybrid')==1
	      strain=num2str(db(i).tg_number);
	      if ~isempty(db(i).lsl)
		strain=[db(i).lsl(1:min(7,end)) ' ' strain];
	      elseif ~isempty(db(i).koki)
		strain=[db(i).koki(1:min(7,end)) ' ' strain];
	      end
		
      end
	    
      % get actor
      who='';
      p_colon=find(action==':');
      if ~isempty(p_colon)
        who=action(p_colon+1:end);
        action=action(1:p_colon-1);
      end
      
	    datename=datestr(daten,'ddd');
	    entries{end+1}=...
		sprintf( '%s %s %-12s %-3s %-11s %03s %-13s  %10s  %s',...
			 date,datename,...
			 action(1:min(12,end)),who,db(i).mouse,...
		       cage,strain,db(i).birthdate,db(i).type);
	    
	  end
	end
      catch
	disp(['Error in actions entry of mouse ' db(i).mouse]);
      end
      
    end
    
  end
  entries=sort(entries);

  prev_weekday=0;
  for i=1:length(entries)
    switch entries{i}(12:14)
      case 'Mon', cur_weekday=1;
      case 'Tue', cur_weekday=2;
      case 'Wed', cur_weekday=3;
      case 'Thu', cur_weekday=4;
      case 'Fri', cur_weekday=5;
      case 'Sat', cur_weekday=6;
      case 'Sun', cur_weekday=7;
      otherwise
        entries{i}(12:14)
        disp(entries{i})
    end
    if cur_weekday<prev_weekday  
        disp('---------------------------------------------------------------------------------------');
    end
    disp(entries{i});
    prev_weekday=cur_weekday;
  end


disp('__________________________________________________________');

function n=date2num(d)
n=datenum(str2num(d(1:4)),str2num(d(6:7)),...
	  str2num(d(9:10)));

  
  
