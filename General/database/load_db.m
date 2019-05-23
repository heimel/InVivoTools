function db = load_db(filename,recursive)
%LOAD_DB loads specified databases from folders
%
% DB = LOAD_DB(FILENAME,RECURSIVE)
%
%  This function does not lock the database. Often OPEN_DB should be
%  used for this reason.
%
% 2019, Alexander Heimel

db = [];

if nargin<1
    filename = [];
end

if nargin<2 || isempty(recursive)
    recursive = false;
end

if isempty(filename)
    filename = 'V:\Shared\InVivo\Experiments\1820.test';
end

if isempty(filename)
    pathname = uigetdir('','Select a folder');
    if isequal(pathname,0)
        return
    end
    filename = '*.mat';
else
    [pathname,filename,ext] =  fileparts(filename);
    filename = [filename ext];
end
logmsg(['Scanning ' pathname]);

d = dir(fullfile(pathname,filename));
if isempty(d)
    return
end

for i=1:length(d)
    if ~d(i).isdir
        [~,~,ext] = fileparts(fullfile(d(i).folder,d(i).name));
        if ~strcmp(ext,'.mat')
            continue
        end
        logmsg(['Loading ' fullfile(d(i).folder,d(i).name)]);
        g = load(fullfile(d(i).folder,d(i).name));
        if isfield(g,'db')
            db = [db g.db];
        elseif isfield(g,'record')
            db = [db g.record];
        else
            logmsg(['Unknown type in ' fullfile(pathname,filename)]);
        end
    elseif recursive  && ~strcmp(d(i).name,'.') && ~strcmp(d(i).name,'..')
        logmsg(['Going into ' fullfile(d(i).folder,d(i).name)]);
        
        db = [db load_db(fullfile(d(i).folder,d(i).name),recursive)];
        logmsg(['Currently '  num2str(length(db)) ' records']);
    end
    
end


