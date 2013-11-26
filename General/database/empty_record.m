function record=empty_record( db )
%EMPTY_RECORD creates empty record for test database
%
%  RECORD=EMPTY_RECORD( DB )
%
%  2005, Alexander Heimel
%
  
  record=db(1);
  fields=fieldnames(record);
  for i=1:length(fields)
    if isnumeric(getfield(record,fields{i}))
      record=setfield(record,fields{i},[]);
    else
      record=setfield(record,fields{i},'');
      end
  end
  
  
