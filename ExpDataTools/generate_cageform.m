function newud=generate_cageform( ud ) 
%GENERATE_CAGEFORM
%
%  NEWUD=GENERATE_CAGEFORM( UD ) 
%
% 2005-2013, Alexander Heimel
%

  newud=ud;
  record=ud.db(ud.current_record);
  cageform(record);
  return

  
  
  
  
  % old generate cageform
   
  orgformname='org_cageform.html';
  orgformdir=fileparts(which('generate_cageform'));
  orgformname=fullfile(orgformdir,orgformname);
  
   
  formname='cageform.html';
  formname=fullfile(tempdir,formname);
  
  stat=copyfile(orgformname,formname);
  if stat==0
    disp(['Error: could not copy ' orgformname ' to '...
	  formname ]);
    return
  end

  orgblankname=fullfile(orgformdir,'blank.gif');
  blankname=fullfile(tempdir,'blank.gif');
  stat=copyfile(orgblankname,blankname);
  if stat==0
    disp(['Error: could not copy ' orgblankname ' to '...
	  blankname ]);
    return
  end
  
  
  
  fields=fieldnames(record);
  for i=1:length(fields)
    val=getfield(record,fields{i});
    if iscell(val)
      val=val{1};
    end
    if ~isempty(val) 
      if isnumeric(val)
	val=mat2str(val);
      end
      val(find(val=='/'))='d';
      val(find(val=='{'))=' ';      
       val(find(val=='}'))=' ';
      val(find(val==','))=' ';
      val(find(val==''''))=' ';
      val(find(val=='('))=' ';
      val(find(val==')'))=' ';
    end
    
    command = [ '!sed -i s/\\\\' fields{i} '/''' val '''/ ' formname  ];
    eval(command);    
    
  end

  command = [ '!html2ps ' formname ' | lpr '];
  eval(command);
  
  % !oowriter -p formname
  
