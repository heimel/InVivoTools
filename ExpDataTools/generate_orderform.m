function newud=generate_orderform( ud )
%GENERATE_ORDERFORM
%
%  NEWUD=GENERATE_ORDERFORM( UD )
%
% 2009, Alexander Heimel
%

disp('generating mouse orderform')

newud=ud;

if length(ud.ind)~=length(ud.db)
  % filter on
  records=ud.db(ud.ind);
else % no filter, thus only take current record
  records=ud.db(ud.current_record);
end

fp=[];
formname='';
var=[];
for i=1:length(records)
  record=records(i);
  if i==1 || strcmp(record.mouse(1:7),records(i-1).mouse(1:7))~=1 || ...
      strcmp(record.arrival,records(i-1).arrival)~=1
    % if i=1 or not same protocol or not same date, then close previous
    % form and open new one
    if i>1
      close_orderform(var,formname,fp);
    end

    var.collectdate=record.arrival;
    var.decnr=['NIN' record.mouse(1:5)];
    var.decgroup=record.mouse(7);
    var.n_mice=0;
    [formname,fp]=open_orderform(var);
    switch var.decnr
      otherwise
        var.experimenter='Alexander Heimel';
        var.decpilot='no';
    end
  end
    var.n_mice=var.n_mice+1;
  add_mouseline(record,fp,var.n_mice);
end
close_orderform(var,formname,fp);
delete(formname);
disp('done');



return


function var=add_mouseline(record,fp,n_mice)
switch record.strain
  case 'hybrid'
    genotype=record.lsl;
    if isempty(genotype)
      genotype=record.koki;
    end
  otherwise
    genotype=record.strain;
end
animal_code=num2str(record.tg_number);
if isempty(animal_code)
    if ~isempty(record.birthdate)
        animal_code=['born on ' datestr(datenumber(record.birthdate),1)];
    else
        animal_code = '';
        disp('GENERATE_ORDERFORM: empty animalcode');
    end
end
number='1';
%acute?
if ~isempty(findstr(record.actions,'suture')) || ...
    ~isempty(findstr(record.actions,'lesion'))
  acute='no';
  housing='NIH';
else
  acute='yes';
  housing='none';
end

ln=num2str(19+n_mice);
head=['$ordersheet->write(' ln ','];

fprintf(fp,[head '1, "' genotype '", $tformat);\n']);
fprintf(fp,[head '2, "' animal_code '", $tformat);\n']);
fprintf(fp,[head '3, "' number '", $tformat);\n']);
fprintf(fp,[head '4, "' housing '", $tformat);\n']);
fprintf(fp,[head '5, "' acute '", $tformat);\n']);
fprintf(fp,[head '6, "", $oformat);\n']);

return


function [formname,fp]=open_orderform(var)
orgformname='org_generate_orderform.pl';
orgformdir=fileparts(which('generate_orderform'));
orgformname=fullfile(orgformdir,orgformname);

datadir=fullfile('~','Documents','Mice',var.decnr) ;
if ~exist(datadir,'dir')
    mkdir(datadir);
end
formname='generate_orderform.pl';
formname=fullfile(datadir,formname);


stat=copyfile(orgformname,formname);
if stat==0
  disp(['Error: could not copy ' orgformname ' to ' ...
    formname ]);
  return
end

% make generating script executable
command = ['!chmod +x ' formname ];
eval(command);

fp=fopen(formname,'a');
return

function close_orderform(var,formname,fp)
fclose(fp);

var.n_mice=num2str(var.n_mice);

collectdate_only=var.collectdate(1:find(var.collectdate==' ',1)-1);
collecttime_only=var.collectdate(find(var.collectdate==' ',1)+1:end);
var.filename=[var.decnr '_' collectdate_only '_' num2str(var.n_mice) 'x.xls'];
var.collectdate=[datestr(datenumber(collectdate_only),1) ', ' collecttime_only];

fields=fieldnames(var);
for i=1:length(fields)
  val=getfield(var,fields{i});
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
%    val(find(val==','))=' ';
    val(find(val==''''))=' ';
    val(find(val=='('))=' ';
    val(find(val==')'))=' ';
  end

  command = [ '!sed -i s/\\\\' fields{i} '/''' val '''/ ' formname  ];
  eval(command);

end
[pathstr,filename]=fileparts(formname);
curdir=pwd;
cd(pathstr);
command=['!' formname];
eval(command);
cd(curdir);
      
return
