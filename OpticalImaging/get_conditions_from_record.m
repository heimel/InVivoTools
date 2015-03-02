function [conditions,condnames]=get_conditions_from_record( record )
%GET_CONDITIONS_FROM_RECORD
%
%  [CONDITIONS,CONDNAMES]=GET_CONDITIONS_FROM_RECORD( RECORD )
%
%  2005, Alexander Heimel
%
conditions=[];
condnames=[];
switch record.stim_type
 case 'ledtest'
  conditions=[0 1 ];

 case {'sf_contrast','contrast_sf'}
  conditions=zeros(2,length(record.stim_contrast)*length(record.stim_sf));
  conditions(1,:)=repmat(record.stim_sf,1,length(record.stim_contrast));
  conditions(2,:)=flatten(repmat(record.stim_contrast, ...
				 length(record.stim_sf),1))';
  
 case {'sf','sf_temporal','sf_low_tf'}
    conditions=record.stim_sf;
  case 'tf',
    conditions=record.stim_tf;
  case {'retinotopy','rt_response'}
    try
      dimensions=record.stim_parameters;
      conditions=(0: dimensions(1)*dimensions(2));
    catch
      disp(['Warning could not get stim_parameters of record for ' ...
        record.date ' test ' record.test]);
      conditions=[];
    end



  case 'contrast',
    conditions=record.stim_contrast;
  case {'od','od_bin','od_mon'}
    delimiter = ',';
    eyes = [delimiter record.eye delimiter];
    pos = strfind(eyes,delimiter);
    conditions=[];
    for i=1:length(pos)-1
      eye = eyes(pos(i)+1:pos(i+1)-1);
      eye = strtrim(eye);
      switch eye
        case 'none',
          conditions(end+1)=-2;
          condnames(end+1,:)=' none ';
        case 'ipsi',
          conditions(end+1)=-1;
          condnames(end+1,:)=' ipsi ';
        case 'blank',
          conditions(end+1)=0;
          condnames(end+1,:)=' blank';
        case 'contra',
          conditions(end+1)=1;
          condnames(end+1,:)='contra';
        case 'both',
          conditions(end+1)=2;
          condnames(end+1,:)=' both ';

      end
    end
    condnames=char(condnames);

  otherwise
    disp([ 'Error in get_conditions_from_record: stimulus type ' record.stim_type ...
      ' is not yet implemented']);
end


if isempty(conditions)
  disp('Warning: conditions is empty');
  return
end

if isempty(condnames)
  num_condnames=num2str( conditions','%6g');
  condnames=char(32*ones( length(conditions),6*size(conditions,2)));
  condnames(:,1:size(num_condnames,2))=num_condnames;
  blank=find(conditions==0);
  if ~isempty(blank)
    condnames(blank,1:5)='blank';
  end
end
