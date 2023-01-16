function dbnames = collect_databases( pth) 
%COLLECT_DATABASES finds all databases in folder and subfolders
%
% DBNAMES = COLLECT_DATABASES( PTH )
%   DBNAMES = cell list of strings
%
% 2022, Alexander Heimel

if nargin<1 || isempty(pth)
    pth = '.';
end

dbnames = {};

if iscell(pth)
    for i=1:length(pth)
        dbnames = cat(2,dbnames,collect_databases(pth{i}));
    end
    return
end

d = dir(pth);
for i = 1:length(d)
    if strcmp(d(i).name,'.') || strcmp(d(i).name,'..')
        continue;
    end
    if contains(d(i).name,'graphdb')
        continue
    end
    if contains(d(i).name,'groupdb')
        continue
    end
    if contains(d(i).name,'copy')
        continue
    end

    filename = fullfile(pth,d(i).name);
    if d(i).isdir
        dbnames = cat(2,dbnames,collect_databases(filename));
        continue
    end
    if ~contains(d(i).name,'test')
        continue
    end
    if strcmp(d(i).name(max(1,end-3):end),'.mat')


        db = whos('db','-file',filename);
        if ~isempty(db)
            dbnames{1,end+1} = filename; %#ok<AGROW> 
        end
    end
end

