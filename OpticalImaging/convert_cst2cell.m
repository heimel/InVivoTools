function list=convert_cst2cell( txt)
%CONVERT_CST2CELL converts comma separated string to cell list
%
%  LIST=CONVERT_CST2CELL( TXT)
%
% 2006, Alexander Heimel

  list=[];
  pos=[0 find(txt==',') length(txt)+1];
  while length(pos)>1
    list{end+1}=trim(txt(pos(1)+1:pos(2)-1));
    pos=pos(2:end);
  end
  
