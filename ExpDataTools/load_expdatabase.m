function [db,filename]=load_expdatabase( whichdb,where,create,load_main,verbose )
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

if nargin<5
    verbose = [];
end
if isempty(verbose)
    verbose = true;
end

if nargin<4
    load_main = [];
end
if isempty(load_main)
    load_main = true;
end

if nargin<1;
    whichdb='';
end
if isempty(whichdb)
    if verbose
        logmsg('Database is not specified.');
    end
    return
end

if nargin<2; where ='';end
if isempty(where)
    where='network';
end

if nargin<3; create = [];end
if isempty(create)
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
    if verbose
        logmsg(['Database ' filename ' does not exist.']);
    end
    if ~isempty(experiment)
        % see if we can load the main one and create a new one
        filenamemain = fullfile(expdatabasepath(where),[whichdb '.mat']);
        if load_main && exist(filenamemain,'file')
            if ~create
                %disp(['LOAD_EXPDATABASE: Loading main database ' filenamemain ' instead.']);
                filename = filenamemain;
            else
                answer = questdlg( ...
                    ['Create new database for experiment ' experiment '?'], ...
                    'New database','Ok','Cancel','Cancel');
                if strcmp(answer,'Ok')
                    logmsg(['Creating empty database ' filename]);
                    file = load(filenamemain,'-mat');
                    db = empty_record( file.db );
                    if ~exist(fullfile(expdatabasepath(where),experiment),'dir')
                        mkdir(fullfile(expdatabasepath(where),experiment));
                    end
                    save(filename,'db');
                else
                    filename = filenamemain;
                end
            end
        end
    end
end

if ~exist(filename,'file') 
    if verbose && load_main
        logmsg(['Database ' filename ' does not exist.']);
    end
    return
end
logmsg(['Loading ' filename ]);
%htemp=figure;
file=load(filename,'-mat');
%close(htemp); % strange, but necessary to remove spuriously appearing graph when load ectestdb
db=file.db;


