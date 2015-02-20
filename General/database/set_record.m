function record=set_record(record,settings)
%SET_RECORD sets some fields of record
%
%  RECORD=SET_RECORD(RECORD,SETTINGS)
%
%  2005, Alexander Heimel
%
  
  if ~iscell(settings)
    settings=split(settings,',');
  end

  for i=1:length(settings)
    setting=settings{i};
    indis=find(setting=='=');
    if length(indis)~=1
      logmsg(['Cannot handle setting ' setting ]);
      return
    end
    fieldname = strtrim(setting(1:indis-1));
    field = record.(fieldname);
    content = strtrim(setting(indis+1:end));
    if isnumeric(field)
      record.(fieldname) = str2num(content);
    else
      record.(fieldname) = content;
    end
    
  end

