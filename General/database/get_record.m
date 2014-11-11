function record=get_record( h_fig )
%GET_RECORD get record from form
%
%   RECORD=GET_RECORD( H_FIG )
%
%   2005-2014, Alexander Heimel
%
  
  ud=get(h_fig,'UserData');
  h_edit=ud.h_edit;
  
  record=[];
  for i=1:length(h_edit)
    field=get(h_edit(i),'Tag');
    switch get(h_edit(i),'Enable')
      case 'on'
        content=get(h_edit(i),'String');
        if isnumeric( ud.orgrecord.(field) )
          content = str2num(content); %#ok<ST2NM>
        end
      case 'off'
        content=get(h_edit(i),'UserData');
    end
    record.(field) = content;
  end
