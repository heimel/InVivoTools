function newud=export_tests( ud )
%EXPORT_TESTS saves test results to csv file
%
%   NEWUD=EXPORT_TESTS( UD )
%
%  2005, Alexander Heimel
%

if isempty(ud.ind)
  disp('Warning: No filtered records');
  return
end
newud=ud;

records=ud.db(ud.ind);

n_records=length(records);

filename='/home/data/export.csv';
fid=fopen(filename,'w');

mousedb=load('/home/data/mousedb.mat','-mat');


sep=',';

fprintf(fid,'mouse,');
fprintf(fid,'date,');
fprintf(fid,'test,');
fprintf(fid,'strain,');
fprintf(fid,'type,');
fprintf(fid,'lsl,');
fprintf(fid,'t_lsl,');
fprintf(fid,'koki,');
fprintf(fid,'t_koki,');
fprintf(fid,'cre,');
fprintf(fid,'t_cre,');
fprintf(fid,'t_icre,');
fprintf(fid,'age,');
fprintf(fid,'stim_type,');
fprintf(fid,'eye,');
fprintf(fid,'comment,');
fprintf(fid,'measure,');
fprintf(fid,'val,');
fprintf(fid,'sem,');
fprintf(fid,'\n');

fprintf('Exporting record:    ');
for i=1:n_records
  fprintf('\b\b\b%03d',i);

  l='';
  record=records(i);
  if isempty(record.reliable)
    record.reliable=1;
    % default is include test
  end
  if record.reliable==1
    ind=find_record(mousedb.db,['mouse=' record.mouse]);
    if isempty(ind)
      disp(['Error: cannot find mouse ' record.mouse ' in mouse database.']);
      return
    end
    mouse=mousedb.db(ind);
    l=[record.mouse];
    l=[l sep record.date(1:10)];
    l=[l sep record.test];
    l=[l sep mouse.strain];
    l=[l sep mouse.type];
    l=[l sep mouse.lsl];
    l=[l sep typing2str(mouse.typing_lsl)];
    l=[l sep mouse.koki];
    l=[l sep typing2str(mouse.typing_koki)];
    l=[l sep mouse.cre];
    l=[l sep typing2str(mouse.typing_cre)];
    l=[l sep typing2str(mouse.typing_icre)];
    if ~strcmp(mouse.birthdate,'unknown')
      age=num2str(datenumber(record.date)-datenumber(mouse.birthdate(1:10)));
    else
      age='';
    end
    l=[l sep age];
    l=[l sep record.stim_type];

    if isempty(record.eye)
      disp(['Warning: eye is empty in ' record.date ' test ' ...
        record.test]);
      eye=[];
    elseif isempty(find(record.eye==','))
      eye=record.eye;
    else
      eye=[];
    end
    l=[l sep eye];

    l=[l sep '"' record.comment '"'];


    y=record.response;
    dy=record.response_sem;
    val=[];
    val_sem=[];
    measure='';

    conditions=[];
    if ~isempty(record)
      [conditions,condnames]=get_conditions_from_record(record);
    end


    switch record.stim_type
      case 'retinotopy',
        measure='screen_center_ml';
        if isempty(record.response)
          disp(['Warning response is empty for ' record.date ...
            'test ' record.test]);
        else
          val=record.response(1);
          writeln(fid,l,measure,val,val_sem,sep);
          measure='screen_center_ap';
          val=record.response(2);
          writeln(fid,l,measure,val,val_sem,sep);
        end
      case 'contrast',
        x=conditions;
        blank=find(x==0);
        condind=setdiff( (1:length(x)),blank);
        measure='contrast_threshold';
        val=cutoff_thresholdlinear([0 x(condind)*100],[0 y(condind)]);
        writeln(fid,l,measure,val,val_sem,sep);
      case 'tf',
        x=conditions;
        blank=find(x==0);
        condind=setdiff( (1:length(x)),blank);
        measure='tf_cutoff';
        val=cutoff_thresholdlinear([ x(condind) 100],[y(condind) 0]);
        writeln(fid,l,measure,val,val_sem,sep);
      case 'sf',
        x=record.stim_sf;
        blank=find(x==0);
        condind=setdiff( (1:length(x)),blank);
        measure='sf_cutoff';
        val=cutoff_thresholdlinear(x(condind) ,y(condind));
        writeln(fid,l,measure,val,val_sem,sep);
      case 'od',
        ind_contra=find(conditions==1);
        ind_ipsi=find(conditions==-1);
        measure='contra';
        val=y(ind_contra);
        val_sem=dy(ind_contra);
        writeln(fid,l,measure,val,val_sem,sep);

        measure='ipsi';
        val=y(ind_ipsi);
        val_sem=dy(ind_ipsi);
        writeln(fid,l,measure,val,val_sem,sep);

        measure='c/i';
        val=abs(y(ind_contra)/y(ind_ipsi));
        val_sem=val*...
          sqrt( (dy(ind_contra)/y(ind_contra))^2+...
          (dy(ind_ipsi)/y(ind_ipsi))^2);
        writeln(fid,l,measure,val,val_sem,sep);


      otherwise
    end
  end
end


fclose(fid);
fprintf('Finished exporting\n');
return

%%%%%%%%%%%%%%%%%


function writeln(fid,l,measure,val,val_sem,sep)
l=[l sep measure];
l=[l sep num2str(val,2)];
l=[l sep num2str(val_sem,2)];

fprintf(fid,l);
fprintf(fid,'\n');
return
