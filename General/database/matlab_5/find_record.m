function ind=find_record(db,crit)
%FIND_RECORD finds records matching criteria in database
%
%   IND=FIND_RECORD(DB,CRIT)
%     special characters in criterium:
%        |    logical or
%        ,    logical and
%        =    equal to
%        !    unequal to
% 
%
%  criterium examples:
%          lsl=TLT 817, typing_lsl>0, cre=Kazu*
%          cre=Kazu | cre=Kazu-X
%          typing_lsl!0      
%
%   implemented comparisons for strings:
%           = (equal) and ! (unequal), <, >
%   implemented comparisons for numbers:
%           =, !, <, >
%
%   2005, Alexander Heimel
%

  if isempty(crit)
    ind=(1:length(db));
    return
  end

  % if criterium is a cell list, than apply 'and' to all individual
  % conditions
  if iscell(crit)
    if length(crit)>1
      ind=(1:length(db));
      for i=1:length(crit)
        ind=ind( find_record( db(ind), crit{i} ) );
      end
      return
    else
      crit=crit{1};
    end
  end
  
  % at this point crit is certainly a non-empty string
  crit=strtrim(crit);
  
  ind=[];
  if crit(1)=='('
    br_open=1;
    p=1;
    while br_open>0 & p<length(crit)
      p=p+1;
      switch crit(p)
        case ')', % bracket closed
          br_open=br_open-1;
        case '(', % bracket opened
          br_open=br_open+1;
      end
    end
    if br_open>0
      disp(['Unclosed bracket in criterium: ' crit]);
      return
    end
    
    
    
    
    if p==length(crit)
      ind=find_record(db,{crit(2:p-1)});
    else
      head=crit(2:p-1);
      tail=crit(p+1:end);
      tail=strtrim(tail);
      switch tail(1)
        case ',' % AND
          ind=find_record(db,{head,tail(2:end)});
        case '|' % OR
            ind=uniq(sort([find_record(db,head)...
              find_record(db,tail(2:end))]));
        otherwise
          disp(['Unexpected character after ) in criterium: ' crit]);
      end
    end
    return
  end

  p=find(crit==','|crit=='|');
  if ~isempty(p)
    head=crit(1:p(1)-1);
    tail=crit(p(1)+1:end);
    switch crit(p(1))
      case ',' % AND
        ind=find_record(db,{head,tail});
      case '|' % OR
        ind=uniq(sort( [find_record(db,head) ...
          find_record(db,tail)] ));
    end
    return
  end
  
  
  % apply criteria
  ind=[];
  pos=[findstr(crit,'=') findstr(crit,'!') ...
    findstr(crit,'>') findstr(crit,'<')];
  if length(pos)>1
    disp(['Warning: FIND_RECORD only uses first comparison in ' crit ]);
    pos=pos(1);
  end
  if ~isempty(pos)
    comp=crit( pos ); % get which comparison
    field=strtrim( crit(1:pos-1) );
    expr=strtrim( crit(pos+1:end) );
    expn=str2num(expr);
    for i=1:length(db)
      try
	
	content=getfield(db(i),field);
      catch
	if ~isfield(db,field)
	  disp(['Error: ''' field ''' is not a valid field name']);
	else
	  disp(['Error: cannot get ''' field ''' in record ' num2str(i)]);
	end	  
	ind=[];
	return
	
      end
      
	
	if isnumeric(content) & ~isempty(content)
        switch comp
          case '=',
            if content==expn
              ind(end+1)=i;
            end
          case '!',
            if content~=expn
              ind(end+1)=i;
            end
          case '>',
            if content>expn
              ind(end+1)=i;
            end
          case '<',
            if content<expn
              ind(end+1)=i;
            end
            
          otherwise
            disp(['comparison type ' comp ...
              ' is not implemented for numbers.'])
        end
      else
        switch comp
          case '=',
            if streq( content, expr)==1
              ind(end+1)=i;
            end
          case '!',
            if streq( content, expr)==0
              ind(end+1)=i;
            end
          case {'>','<'},
            if ~isempty(content)
              
              nlen=max(length(content),length(expr))+1;
              pcontent=padarray( double(content)', ...
                nlen-length(content),'post');
              pexpr=padarray( double(expr)', ...
                nlen-length(expr),'post');
              diff=pcontent-pexpr;
              first_nz=find(diff~=0);
              if ~isempty(first_nz)
                first_nz=first_nz(1);
                switch comp
                  case '>',
                    if diff(first_nz)>0
                      ind(end+1)=i;
                    end
                  case '<',
                    if diff(first_nz)<0
                      ind(end+1)=i;
                    end
                end
              end
            end
          otherwise
            disp(['comparison type ' comp ...
              ' is not implemented for strings.'])
        end
      end
    end
  end
