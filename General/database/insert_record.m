function newdb=insert_record(db,records,ind)
%INSERT_RECORD insert records at index in struct array
%
%  NEWDB=INSERT_RECORD(DB,RECORDS,IND)
%
%  2005, Alexander Heimel
%
  
  newdb=[db(1:ind-1) records db(ind:end) ];
