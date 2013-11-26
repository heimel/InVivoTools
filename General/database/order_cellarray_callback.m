function order_cellarray_callback(cbo)
  

  cellnr=str2num(get(cbo,'Tag'));
  if cellnr==0
    return
  end
  h_fig=get(cbo,'Parent');
  ud=get(h_fig,'UserData');
  
  i=find(ud.order==cellnr);
  if i>1
    ud.order(i)=ud.order(i-1);
    ud.order(i-1)=cellnr;
  end
  
  for i=1:length(ud.orgcells)
    set(ud.h_cell(i),'String',ud.orgcells{ud.order(i)});
    set(ud.h_cell(i),'Tag',num2str(ud.order(i)));
  end

  set(h_fig,'UserData',ud);
