function cellname = getcellname( cksds )
%GETCELLNAME asks user to select cellname, returns directly if no choice
%
%  CELLNAME = GETCELLNAME( CKSDS )   
%
%   2003, Alexander Heimel (heimel@brandeis.edu)
%
  
  cellnames=getcells(cksds);
  if length(cellnames)==0
    errordlg('No cells found');
    cellname=[];
    return;
  end
  if length(cellnames)==1
    cellname=cellnames{1};
  else
    str = {};
    for i=1:length(cellnames),
      str = cat(2,str,{cellnames{i}});
    end;
    [s,v] = listdlg('PromptString','Select a nameref',...
		    'SelectionMode','single','ListString',str);
    if v==0, 
      return;
    else, 
      cellname=cellnames{s};
    end;
  end
  
