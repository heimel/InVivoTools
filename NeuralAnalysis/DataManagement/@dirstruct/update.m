function newcksds = update(cksds)

% NEWDS = UPDATE(MYDIRSTRUCT)
%
%  Examines the path of the DIRSTRUCT and updates all of the structures.

if exist(cksds.pathname)~=7, error(['''' pathname ''' does not exist.']); end;

dse = length(cksds.dir_str);
nse = length(cksds.nameref_str);
d = dir(fullfile(cksds.pathname,'t0*')); % added 2011-03-11 by Alexander
[y,I]=sort({d.name});
d = d(I);
for i=1:length(d),
  if d(i).isdir==0
    continue
  end
  if ~(strcmp(d(i).name,'.')|strcmp(d(i).name,'..')|strcmp(d(i).name,'analysis')), % ignore these
    fname = [cksds.pathname fixpath(d(i).name) 'reference.txt'];
    if exist(fname)
      a= loadStructArray(fname);
    else
      disp([fname ' does not exist']);
      a.name=input('name [tp]:','s');
      if isempty(a.name)
        a.name='tp';
      end
      a.ref=input('ref [1]:');
      if isempty(a.ref)
        a.ref=1;
      end
      a.type=input('type [unknown]:','s');
      if isempty(a.type)
        a.type='unknown';
      end
      saveStructArray(fname,a,1);
    end
    if (isempty(intersect(d(i).name,cksds.dir_list))),
      % add directory to list, add namerefs to other list
      %eval(['!mac2unix -q ' fname]); %fname,
      %disp(['Loaded ' d(i).name filesep 'acqParams_out']);
      n = { a(:).name }; r = { a(:).ref }; t = { a(:).type };
      if ~isempty(n),
        namerefs = cell2struct(cat(1,n,r)',{'name','ref'},2);
      else,
        namerefs = struct('name','','ref',''); namerefs = namerefs([]);
      end;
      cksds.dir_str(dse+1) = struct('dirname',d(i).name,...
        'listofnamerefs',namerefs);
      cksds.dir_list = cat(1,cksds.dir_list,{d(i).name});
      cksds.active_dir_list = cat(1,cksds.dir_list,{d(i).name});
      dse = dse + 1;
      for j=1:length(namerefs),
        ind = namerefind(cksds.nameref_str,...
          namerefs(j).name,namerefs(j).ref);
        if ind>-1, % append to existing record
          cksds.nameref_str(ind).listofdirs = ...
            cat(1,cksds.nameref_str(ind).listofdirs,...
            {d(i).name});
        else, % add new record
          tmpstr = struct('name',namerefs(j).name,...
            'ref',namerefs(j).ref);
          tmpstr.listofdirs = {d(i).name};
          cksds.nameref_str(nse+1) = tmpstr;
          cksds.nameref_list(nse+1)  = struct('name',...
            namerefs(j).name,'ref',namerefs(j).ref);
          % also add new extractor record
          ind2=typefind(cksds.autoextractor_list,t{j});
          if ind2>0,
            tmpstr.extractor1=...
              cksds.autoextractor_list(ind2).extractor1;
            tmpstr.extractor2=...
              cksds.autoextractor_list(ind2).extractor2;
          else, tmpstr.extractor1='';tmpstr.extractor2=''; end;
          tmpstr = rmfield(tmpstr,'listofdirs');
          cksds.extractor_list(end+1) = tmpstr;
          % inc counter
          nse = nse + 1;
        end;
      end;
    end;
  end;
end;

newcksds = cksds;
