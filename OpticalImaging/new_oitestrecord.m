function ud=new_oitestrecord(ud)
%NEW_OITESTRECORD_OD create new testrecord for ocular dominance test
%
%   UD=NEW_OITESTRECORD_OD(UD)
%       stimulus specific parameters are in this file
%
% 2005, Alexander Heimel
%
  tests=get(ud.h.which_test,'String');
  test=tests(get(ud.h.which_test,'Value'),:);
  test=trim(lower(test));
  
  control_db_callback(ud.h.new);
  ud=get(ud.h.fig,'UserData');
  record=ud.db(ud.current_record);
  record=set_record(record,testrecord_defaults);

  record.stim_type=test;
  record.test='mouse_E';
  record.depth=800;
  record.filter=700;

  switch host
   case 'andrew',
    record.scale=8.05; % micron per mm 
    record.setup='andrew';
   case {'daneel','jander'} 
    record.scale=11.04; % micron per mm 
    record.setup=host;
   otherwise
    record.scale=11.04; % micron per mm  (TELIC CAMERA)
  end
  
  
  if ud.current_record>1 
    prev_record=ud.db(ud.current_record-1);
    [y,m,d]=datevec(now);
    datetext=sprintf('%04d-%02d-%02d',y,m,d);
    if isempty(record.date) & ...
	  isempty(record.mouse) & ...
	  strcmp(prev_record.date,datetext)==1
      record.mouse=prev_record.mouse;
      record.date=prev_record.date;
      record.depth=prev_record.depth;
      record.filter=prev_record.filter;
      record.scale=prev_record.scale;
      record.ref_image=prev_record.ref_image;
      record.experimenter=prev_record.experimenter;

      indE=find(prev_record.test=='E');
      if ~isempty(indE)
          prevtest=eval(prev_record.test(indE(end)+1:end));
          newtestnum=prevtest+1;
      else
          newtestnum=1;
      end
      
    else
      record.date=datetext;
      newtestnum=1;
    end
  end
  record.test=[record.test num2str(newtestnum)];
      
      
  switch test
   case 'ks',
    record.test='mouse_ks_E';
    record.stim_tf=0.09987;
    record.stimrect=[0 0 640 480];
    record.stim_contrast=1;
    record.stim_onset=[];
    record.stim_offset=[];
   case 'retinotopy',
    record.stim_parameters=[2 2];
    record.stimrect=[0 0 640 480];
    record.stim_tf=2;
    record.stim_sf=0.05;
    record.stim_contrast=0.9;
    record.eye='both';
   case 'od',
    record.eye='none, ipsi, contra';
    record.stimrect=[0 0 640 240];
    record.stim_onset=0;
    record.stim_offset=3;
    record.stim_sf=0.05;
    record.stim_tf=2;
    record.stim_contrast=0.9;
   case 'sf',
    record.stim_sf=[0.1 0.2 0.3 0.4 0.5];
    record.stimrect=[0 0 640 240];
    record.stim_tf=2;
    record.stim_contrast=0.9;
    record.stim_onset=3;
    record.stim_offset=5;
    record.eye='contra';
   case 'tf',
    record.stimrect=[0 0 640 240];
    record.stim_tf=[5 10 15 20];
    record.stim_sf=0.05;
    record.stim_contrast=0.9;
    record.stim_onset=3;
    record.stim_offset=5;
    record.eye='contra';
   case 'contrast',
    record.stim_contrast=[ 0.1 0.4 0.7 0.9];
    record.stimrect=[0 0 640 240];
    record.stim_sf=0.05;
    record.stim_tf=2; 
    record.stim_onset=3;
    record.stim_offset=5;
    record.eye='contra';
  end
  
  ud.db(ud.current_record)=record;
  
  set(ud.h.fig,'UserData',ud);
  
  
 
  
