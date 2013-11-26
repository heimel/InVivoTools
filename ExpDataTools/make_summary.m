function newud=make_summary( ud )
%MAKE_SUMMARY
%
%  NEWUD=MAKE_SUMMARY( UD )
%
% 2005, Alexander Heimel
%
global summary


newud=ud;


n=length(ud.ind);

n_total=0;
n_oi=0;
n_su=0;
n_ok=0;
n_perfused=0;

testdb=load_testdb;

summary=[];
for ic=1:n
  i=ud.ind(ic);
  mouse=ud.db(i);
  strain=txt2field(mouse.strain);
  if strcmp(strain,'hybrid')==1 &  ~isempty(mouse.typing_lsl) & ...
	~isempty(mouse.typing_cre) ...
	&  mouse.typing_lsl==1 & mouse.typing_cre==1
    strain=txt2field(mouse.lsl);
  end
  try 
    s=getfield(summary,strain);
  catch
    s=[];
  end
  
  mtype=txt2field(mouse.type);
  if isempty(mtype)
    mtype='empty';
  end
  
  try 
    entry=getfield(s,mtype);
  catch
    entry.mice=[];
    entry.n_total=0;
    entry.n_perfused=0;
    entry.n_ok=0;
    entry.n_oi=0;
    entry.n_su=0;
  end
  entry.mice{end+1}=mouse.mouse;
  entry.n_total=entry.n_total+1;
  used=0;
  if isempty(mouse.alive)
    disp(['Warning: unknown if mouse ' mouse.mouse ' is alive.']);
  else
    if ~isempty(findstr(mouse.actions,'perfusion'))
      entry.n_perfused=entry.n_perfused+1;
    end
    if mouse.alive==0 & ~isempty(findstr(mouse.actions,'oi'))
      entry.n_oi=entry.n_oi+1;
      used=1;
    end
    if mouse.alive==0 & ~isempty(findstr(mouse.actions,'su'))
      % but don't automatically count sutured mice
      if ~eqlen( findstr(mouse.actions,'su'),...
		 findstr(mouse.actions,'sut')) 
	entry.n_su=entry.n_su+1;
	used=1;
      end
    end
  end
  if used==1 & isempty(mouse.usable)  
    % used but not yet given a usability status
    ind_test=find_record(testdb,['mouse=' mouse.mouse ...
		    ', stim_type=od, reliable=1']);
    if ~isempty(ind_test)
      mouse.usable=1;
    else
      ind_test=find_record(testdb,['mouse=' mouse.mouse ...
		    ', stim_type=od']);
      ind_test_un=find_record(testdb(ind_test),['mouse=' mouse.mouse ...
		    ', stim_type=od, reliable=0']);
      if isempty(ind_test) | length(ind_test_un)<length(ind_test)
	disp(['Do not know if mouse ' mouse.mouse ' was useful.']);
      else
	mouse.usable=0;
      end
    end
  end
  if ~isempty(mouse.usable) & mouse.usable==1
    entry.n_ok=entry.n_ok+1;
  end
  s=setfield(s,mtype,entry);
  if isempty(strain)
    disp(['Error: strain empty in mouse ' mouse.mouse ]);
  else
    summary=setfield(summary,strain,s);
  end
  
  
  newud.db(i)=mouse;
end

fields=fieldnames(summary);
[ff,ind]=sort(fields);

disp('Mouse summary');

header='Strain       Type               total oi  su  ok perfused';
linec=0;
for i=ind'
  if mod(linec,12)==0
    disp(header);
  end
  strain=fields{i};
  s=getfield(summary,strain);
  types=fieldnames(s);
  for t=1:length(types)
    type=types{t};
    entry=getfield(s,type);
    
    
    h=sprintf('%-12s %-20s  %-3d %-3d %-3d %-3d %-3d',...
	      strain(1:min(end,12)),type(1:min(end,20)),...
	      entry.n_total,entry.n_oi,...
	      entry.n_su,...
	      entry.n_ok,entry.n_perfused );
    disp(h);
  
    n_total=n_total+entry.n_total;
    n_oi=n_oi+entry.n_oi;
    n_su=n_su+entry.n_su;
    n_ok=n_ok+entry.n_ok;
    n_perfused=n_perfused+entry.n_perfused;

  end
    linec=linec+1;
  
end

disp(header);
h=sprintf('%-12s %-20s  %-3d %-3d %-3d %-3d %-3d',...
	  'Total','',...
	  n_total,n_oi,...
	  n_su,...
	  n_ok,n_perfused );

disp(h);


%%%%%

function f=txt2field(t)
 f=t;
 if ~isempty(f)
   f(find(f=='-'))='_';
   f(find(f==' '))='_';
   f(find(f=='/'))='d';
 end
