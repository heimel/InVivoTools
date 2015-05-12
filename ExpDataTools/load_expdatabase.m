function [db,filename]=load_expdatabase( whichdb,where,create,load_main,verbose)
%LOAD_EXPDATABASE loads local or network copy of a database
%
%  [DB,FILENAME] = LOAD_EXPDATABASE(WHICHDB,WHERE,CREATE,LOAD_MAIN,VERBOSE)
%       If CREATE is true, create new if it doesn't exist
%       If LOAD_MAIN [True], fall back to loading main database
%
% 200X-2013, Alexander Heimel
%
db=[];
filename='';

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
    whichexpdb = [whichexpdb '_' experiment];
    
end

whichexpdb=[whichexpdb '.mat'];

filename=fullfile(expdatabasepath(where),capitalize(experiment),whichexpdb);

if exist(filename,'file')==0
    
    
    d= dir(filename);
    if ~isempty(d) % i.e. multiple files
        filename = {};
        for i=1:length(d)
            [sdb,fname] = load_single_expdatabase( fullfile( expdatabasepath(where),capitalize(experiment),d(i).name));
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
        [db,filename]=load_expdatabase( whichdb,where,create,false,verbose);
        experiment(exp,false);

        
        %         if ~isempty(experiment)
        %     % see if we can load the main one and create a new one
        %     filenamemain = fullfile(expdatabasepath(where),[whichdb '.mat']);
        %     if load_main && exist(filenamemain,'file')
        %         if ~create
        %             filename = filenamemain;
        %         else
        %             answer = questdlg( ...
        %                 ['Create new database for experiment ' experiment '?'], ...
        %                 'New database','Ok','Cancel','Cancel');
        %             if strcmp(answer,'Ok')
        %                 logmsg(['Creating empty database ' filename]);
        %                 file = load(filenamemain,'-mat');
        %                 db = empty_record( file.db );
        %                 if ~exist(fullfile(expdatabasepath(where),experiment),'dir')
        %                     mkdir(fullfile(expdatabasepath(where),experiment));
        %                 end
        %                 save(filename,'db');
        %             else
        %                 filename = filenamemain;
        %             end
        %         end
        %     end
        % end
        %
    elseif verbose
        logmsg(['Database ' filename ' does not exist.']);
    end
else
    db = load_single_expdatabase( filename);
end


function [db, filename] = load_single_expdatabase( filename)

logmsg(['Loading ' filename ]);
file = load(filename,'-mat');
if isfield(file,'db')
    db = file.db;
else
    filename = [];
    db = [];
end


