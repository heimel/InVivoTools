function newdb=del_record(db,ind)
%DEL_RECORD removes records from database
%
%  NEWDB=DEL_RECORD(DB,IND)
%
%  2005, Alexander Heimel
%
  
  newdb=db( setdiff( (1:length(db)), ind ));
  
  
  
