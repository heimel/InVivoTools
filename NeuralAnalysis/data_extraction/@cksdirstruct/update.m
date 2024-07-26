function newcksds = update(cksds)
% NEWCKSDS = UPDATE(MYCKSDIRSTRUCT)
%
%  Examines the path of the CKS directory and updates all of the structures.

if exist(cksds.pathname)~=7, 
  error(['''' pathname ''' does not exist.']); 
end

dse = length(cksds.dir_str);
nse = length(cksds.nameref_str);
d = dir(cksds.pathname);
[y,I]=sort({d.name});
d = d(I);
for i=1:length(d),
    if ~(strcmp(d(i).name,'.')||strcmp(d(i).name,'..')), % ignore these
        fname = [cksds.pathname fixpath(d(i).name) 'acqParams_out'];
        if exist(fname)&&(isempty(intersect(d(i).name,cksds.dir_list))),
            % add directory to list, add namerefs to other list
            %eval(['!mac2unix -q ' fname]); %fname,
            a = loadStructArray(fname);
            %disp(['Loaded ' d(i).name filesep 'acqParams_out']);
            n = { a(:).name }; 
            r = { a(:).ref }; 
            t = { a(:).type };
            namerefs = cell2struct(cat(1,n,r)',{'name','ref'},2);
            cksds.dir_str(dse+1) = struct('dirname',d(i).name,...
                'listofnamerefs',namerefs);
            cksds.dir_list = cat(1,cksds.dir_list,{d(i).name});
            cksds.active_dir_list = cat(1,cksds.dir_list,{d(i).name});
            dse = dse + 1;
            for j=1:length(namerefs),
                ind = namerefind(cksds.nameref_str,...
                    namerefs(j).name,namerefs(j).ref);
                if ind>-1 % append to existing record
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
                    ind2 = typefind(cksds.autoextractor_list,t{j});
                    if ind2>0
                        tmpstr.extractor1=...
                            cksds.autoextractor_list(ind2).extractor1;
                        tmpstr.extractor2=...
                            cksds.autoextractor_list(ind2).extractor2;
                    else
                        tmpstr.extractor1='';
                        tmpstr.extractor2=''; 
                    end
                    tmpstr = rmfield(tmpstr,'listofdirs');
                    cksds.extractor_list(end+1) = tmpstr;
                    % inc counter
                    nse = nse + 1;
                end
            end
        end
    end
end

newcksds = cksds;
