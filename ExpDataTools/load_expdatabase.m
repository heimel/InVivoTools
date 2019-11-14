function [db,filename]=load_expdatabase( whichdb,where,create,load_main,verbose)
%LOAD_EXPDATABASE loads local or network copy of a database
%
%  [DB,FILENAME] = LOAD_EXPDATABASE(WHICHDB,WHERE,CREATE,LOAD_MAIN,VERBOSE)
%       If CREATE is true, create new if it doesn't exist
%       If LOAD_MAIN [True], fall back to loading main database
%
% 200X-2017, Alexander Heimel
%

db = [];
filename = '';

if nargin<5 || isempty(verbose)
    verbose = true;
end

if nargin<4 ||  isempty(load_main)
    load_main = true;
end

if nargin<1 ||  isempty(whichdb)
    if verbose
        logmsg('Database is not specified.');
    end
    return
end

if nargin<2 ||  isempty(where)
    where='network';
end

if nargin<3 || isempty(create)
    create = false;
end

% remove .mat to be able to add experiment
if ~isempty(strfind(whichdb,'.mat')) && strcmp(whichdb(end-3:end),'.mat')
    whichdb = whichdb(1:end-4);
end

whichexpdb = whichdb;
if ~isempty(experiment) && ~strcmp(whichexpdb(max(1,end-length(experiment)):end),['_' experiment])
    if ~isempty(whichexpdb) && whichexpdb(end)=='*'
        whichexpdb = [whichexpdb experiment];
    else
        whichexpdb = [whichexpdb '_' experiment];
    end
end

whichexpdb = [whichexpdb '.mat'];

filename = fullfile(expdatabasepath(where),capitalize(experiment),whichexpdb);
if exist(filename,'file')==0
    d = dir(filename);
    if ~isempty(d) % i.e. multiple files
        filepath = fileparts(filename);
        filename = {};
        for i=1:length(d)
            if isfield(d,'folder')
                [sdb,fname] = load_single_expdatabase( fullfile(d(i).folder,d(i).name) );
            else
                [sdb,fname] = load_single_expdatabase( fullfile(filepath,d(i).name) );
            end
            if ~isempty(fname) && ~isempty(sdb)
                filename{end+1} = fname; %#ok<AGROW>
            end
            try
                db = [db structconvert(sdb,db)]; %#ok<AGROW>
            catch
                db = [structconvert(db,sdb) sdb];
            end
        end
    elseif load_main && ~create
        if verbose
            logmsg(['Database ' filename ' does not exist.']);
        end
        exp = experiment;
        experiment('',false);
        [db,filename] = load_expdatabase( whichdb,where,create,false,verbose);
        experiment(exp,false);
    elseif verbose
        logmsg(['Database ' filename ' does not exist.']);
        logmsg('Could not find a database. Set params.networkpathbase and/or params.databasepath_localroot in processparams_local.m');
        logmsg('Type ''clear functions'' at the matlab prompt to reset database search paths.');
        logmsg('If necessary find empty database (e.g. testdb_empty.mat) and copy to one of the searched folders.');
    end
else
    db = load_single_expdatabase( filename);
end


function [db, filename] = load_single_expdatabase( filename)

persistent loaded_db loaded_filename loaded_datenum

if strcmp(loaded_filename,filename)
    d = dir(filename);
    if d.datenum == loaded_datenum
        logmsg(['Reading ' filename ' from cache' ]); 
        db = loaded_db;
        return
    end
end
        
logmsg(['Loading ' filename ]);
file = load(filename);
if isfield(file,'db')
    db = file.db;
    
    loaded_db = db;
    loaded_filename = filename;
    d = dir(filename);
    loaded_datenum = d.datenum;
else
    filename = [];
    db = [];
end


