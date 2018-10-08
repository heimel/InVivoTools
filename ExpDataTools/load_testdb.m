function [db,filename]=load_testdb( datatype, hostname, create,load_main,verbose)
%LOAD_TESTDB loads test_db
%
%  [DB,FILENAME] = LOAD_TESTDB( DATATYPE, HOSTNAME )
%      where DATATYPE is one of the 4 main datatypes with different record structures:
%       'ec' - electrophysiology
%       'tp' - two-photon and regular microscopy
%       'wc' - webcam data
%       'oi' - intrinsic signal, flavoprotein and gcamp wide field imaging
%       and HOSTNAME is one of the acquistion computers, e.g. jander, daneel or wall-e.
%
%    FILENAME may be cell array of string
%
% See also SAVE_DB, OPEN_DB
%
% 2005-2015, Alexander Heimel
%

if nargin<1 || isempty(datatype)
    datatype = 'oi';
end
if nargin<2 || isempty(hostname)
    hostname = host;
end
if nargin<5 || isempty(verbose)
    verbose = true;
end
if nargin<3 || isempty(create)
    create = [];
end
if nargin<4 || isempty(load_main)
    load_main = [];
end

whichdb = expdatabases( datatype, hostname);

[db,filename] = load_expdatabase(whichdb,'network',create,load_main,verbose);
if isempty(db)
    hostname = '*';
    whichdb = expdatabases( datatype, hostname);
    [db,filename] = load_expdatabase(whichdb,'network',create,load_main,verbose); % filename may be cell array
    if iscell(filename) && length(filename)==1
        filename = filename{1};
    end
end



% 
% db = [];
% if strcmpi(experiment,'all')
%     logmsg('Loading databases for all experiments');
%     orgexperiment = experiment;
%     experiment('',false);
%     db = load_single_testdb( whichdb,where,db,false,false);
%     d = dir(expdatabasepath(where));
%     d = d([d.isdir]);
%     for i=1:length(d)
%         switch d(i).name
%             case {'.','..','Empty'}
%                 continue
%         end
%         experiment(d(i).name,false);
%         db = load_single_testdb( whichdb,where,db,false,false);
%     end
%     experiment(orgexperiment,false);
%     whichdb = 'ectestdb.mat';
%     filename=fullfile(expdatabasepath(where),whichdb);
% else
%     [db,filename] = load_single_testdb( whichdb,where,db,true,true );
% end

% 
% function [db,filename]=load_single_testdb( whichdb,where,db,load_main,verbose )
% switch whichdb
%     case {'testdb','testdb.mat'} % join oi databases
%         if verbose
%             logmsg('Concatenating all oi test databases. Changes will not be saved to original database!');
%             logmsg('Use e.g. experiment_db(''oi'',''andrew'') to open specific database, or use host(''andrew'')');
%         end
%         % load separate testdatabases and merge
%         db_daneel=load_expdatabase( 'testdb_daneel',where,[],load_main,verbose);
%         db_andrew=load_expdatabase( 'testdb_andrew',where,[],load_main,verbose );
%         db_jander=load_expdatabase( 'testdb_jander',where,[],load_main,verbose );
%         db=[db db_daneel db_andrew db_jander];
%         
%         whichdb='testdb.mat';
%         filename=fullfile(expdatabasepath(where),whichdb);
%     case {'ectestdb','ectestdb.mat'} % join ec databases
%         switch experiment
%             case 'examples'
%                 [db,filename] = load_expdatabase(whichdb,where,[],load_main,verbose);
%                 % matching structure to ectestdb_daneel_empty
%                 emptydbfilename = fullfile(expdatabasepath(where),'Empty', 'ectestdb_daneel_empty');
%                 if exist(emptydbfilename,'file')
%                     db_empty = load(emptydbfilename);
%                     db_empty = db_empty.db;
%                     db = structconvert(db,db_empty);
%                 end
%             otherwise
%                 if verbose
%                     logmsg('Concatenating all experimental databases. Changes will not be saved to original database!');
%                     logmsg('Use e.g. experiment_db(''ec'',''nori001'') to open specific database, or use host(''nori001'')');
%                 end
%                 
%                 % matching structure to ectestdb_daneel_empty
%                 db_empty = load(fullfile(expdatabasepath(where),'Empty', 'ectestdb_empty'));
%                 db_empty = db_empty.db;
%                 
%                 % load separate testdatabases and merge
%                 setups = {'nori001','nin380','daneel','antigua'};
%                 for s = 1:length(setups)
%                     if ~isempty(db)
%                         load_main = false;
%                     end
%                     dbt = load_expdatabase( ['ectestdb_' setups{s}],where,[],load_main,verbose );
%                     dbt = structconvert(dbt,db_empty);
%                     db = [db dbt]; %#ok<AGROW>
%                 end
%                 
%                 whichdb = 'ectestdb.mat';
%                 filename=fullfile(expdatabasepath(where),whichdb);
%         end
%     otherwise
%         [db_single,filename] = load_expdatabase(whichdb,where,[],load_main,verbose);
%         if ~isempty(db_single) &&  isfield(db_single(1),'stack') % i.e. microscopy record
%             % matching structure to tptestdb_olympus_empty
%             if 0
%                 db_empty = load(fullfile(expdatabasepath(where),'Empty', 'tptestdb_olympus_empty'));
%                 db_empty = db_empty.db;
%                 db_single = structconvert(db_single,db_empty);
%             end
%         end
%         db = [db db_single];
% end
% 
% 
