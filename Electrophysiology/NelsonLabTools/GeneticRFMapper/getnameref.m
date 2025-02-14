function nameref = getnameref ()
%GETNAMEREF gets selected name reference from RunExperiemnt panel
%
% NAMEREF = GETNAMEREF ()
%
% Alexander Heimel (heimel@brandeis.edu)
%
  nameref=[];
  z = geteditor('RunExperiment');
  udre = get(z,'userdata');
  udre2 = get(udre.list_aq,'userdata');
  if isempty(udre2),
    errordlg('Needs an aquisition record to run tests.'); 
    return;
  elseif length(udre2)==1 % only one entry
    nameref = struct('name',udre2(1).name,'ref',udre2(1).ref); 
  else
    str = {};
    for i=1:length(udre2),
      str = cat(2,str,{[ udre2(i).name ' | ' int2str(udre2(i).ref)]});
    end;
    [s,v] = listdlg('PromptString','Select a name | ref',...
		    'SelectionMode','single','ListString',str);
    if v==0, 
      return;
    else, 
      nameref = struct('name',udre2(s).name,'ref',udre2(s).ref); 
    end;
  end;