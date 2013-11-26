function list=make_declist(cond)
%MAKE_DECLIST produces list of mice used on protocols
%
% 2006, Alexander Heimel
%

if nargin<1
  cond=[];
end


mousedb=load_mousedb;
ind=find_record(mousedb,cond);
mousedb=mousedb(ind);

ind=find_record(mousedb,'alive=0');

mousedb=mousedb(ind);


mline=sprintf('%s  %s   %s       %s    %s',...
	      'DEC','group',...
	      'died', 'arrival','supplier');

list={};
for i=1:length(mousedb)
  
  

  list{end+1}=  mouseline(mousedb(i));
  if isempty(list{end})
    list={list{1:end-1}};
  end
  
end
list=sort(list);
disp(mline);

grplines={};
count=0;
if isempty(list)
  disp('No mice matching criteria');
  return
end

protgroup=list{1}(1:8);
for i=1:length(list)
  if strcmp(protgroup,list{i}(1:8))==0
    disp(['Total for group = ' num2str(count)]);
    grplines{end+1}=write_totals(protgroup,count);
    protgroup=list{i}(1:8);
    count=0;
  end
  disp(list{i});
  count=count+1;
end
grplines{end+1}=write_totals(protgroup,count);
disp(mline);

fprintf('\n\nSUMMARY\n')
for i=1:length(grplines)
  disp(grplines{i})
end


function grpline=write_totals(protgroup,count)
  dec=protgroup(1:5);
  group=eval(protgroup(8:end));
  [n,ed]=dec_numbers(dec,group);
  grpline=['Protocol ' dec ' group ' num2str(group) ...
    ':     used: ' num2str(count,'%03d') ' remain: ' num2str(n-count,'%03d') ...
    ' expires: ' ed];
  disp(grpline);
  return

function mline=mouseline(record)
mline='';

ppos=find(record.mouse=='.');
if length(ppos)<3
  display(['Mouse number incorrect in record ' record.mouse ]);
  
  return;  
end

protocol=record.mouse(1:ppos(2)-1);
group=eval(record.mouse(ppos(2)+1:ppos(3)-1));
if group~=0
  
  sutured=~isempty(findstr(record.actions,'sut'));
  imaged=~isempty(findstr(record.actions,'oi'));
  electro=~isempty(findstr(record.actions,'su'));
  last_action=findstr(record.actions,'200');
  
  if 1
    switch protocol
     case '04.05',
      if ~imaged & ~electro
	disp(['not used? ' record.mouse])
      end
      
      if sutured & group~=2 
	disp(['wrong group? ' record.mouse])
      end
     case '05.13',
      % check nothing
     otherwise
      if ~imaged & ~electro
	disp(['not used? ' record.mouse])
      end
      
      if sutured & group~=2 
	disp(['wrong group? ' record.mouse])
      end
      if ~sutured & group==2 
	disp(['wrong group? ' record.mouse])
      end
    end
  end
    
    
    if isempty(last_action)
      disp(['warning: empty action' record.mouse]);
    else
    last_action=last_action(end);
    last_action=record.actions(last_action:last_action+9);
  end
  
  
  mline=sprintf('%5s  %-2d %10s  %10s  %6s  %s',...
		protocol,group,...
		last_action, record.arrival,record.supplier,record.mouse);
  
end



