function [db,filename]=load_testdb( whichdb,where )
%LOAD_TESTDB loads test_db
%
%  [DB,FILENAME] = LOAD_TESTDB( WHICHDB, WHERE )
%     WHICHDB contains database filename. Extension '.mat' is optional
%     WHERE defaults to 'network'
%
% 2005-2013, Alexander Heimel
%

if nargin<1; whichdb=''; end
if nargin<2; where ='';end

if isempty(whichdb)
    whichdb = expdatabases( 'oi' );
end

if isempty(findstr(whichdb,'.mat'))
  whichdb=[whichdb '.mat'];
end

if isempty(where)
  where='network';
end

db = [];
if strcmpi(experiment,'all')
    disp('LOAD_TESTDB: Loading databases for all experiments');
    orgexperiment = experiment;
    experiment('',false);
    db = load_single_testdb( whichdb,where,db,false,false);
    d = dir(expdatabasepath(where));
    d = d([d.isdir]);
    for i=1:length(d)
        switch d(i).name
            case {'.','..','Empty'}
                continue
        end
  %      try
            experiment(d(i).name,false);
            db = load_single_testdb( whichdb,where,db,false,false);
%         catch me
%             disp(me.message);
%             experiment(orgexperiment);
%         end
    end
    experiment(orgexperiment,false);
    whichdb = 'ectestdb.mat';
    filename=fullfile(expdatabasepath(where),whichdb);
else
    [db,filename] = load_single_testdb( whichdb,where,db,true,true );
end


function [db,filename]=load_single_testdb( whichdb,where,db,load_main,verbose )
switch whichdb
    case {'testdb','testdb.mat'} % join oi databases        
        if verbose
            disp('LOAD_TESTDB: Concatenating all oi test databases. Changes will not be saved to original database!');
            disp('LOAD_TESTDB: Use e.g. experiment_db(''oi'',''andrew'') to open specific database, or use host(''andrew'')');
        end
        % load separate testdatabases and merge
        db_daneel=load_expdatabase( 'testdb_daneel',where,[],load_main,verbose);
        db_andrew=load_expdatabase( 'testdb_andrew',where,[],load_main,verbose );
        db_jander=load_expdatabase( 'testdb_jander',where,[],load_main,verbose );
        db=[db db_daneel db_andrew db_jander];
        
        whichdb='testdb.mat';
        filename=fullfile(expdatabasepath(where),whichdb);
    case {'ectestdb','ectestdb.mat'} % join ec databases
        switch experiment 
            case 'examples'
                 % matching structure to ectestdb_daneel_empty
                db_empty = load(fullfile(expdatabasepath(where),'Empty', 'ectestdb_daneel_empty'));
                db_empty = db_empty.db;
                
                [db,filename] = load_expdatabase(whichdb,where,[],load_main,verbose);
                db = structconvert(db,db_empty);

            otherwise
                if verbose
                    disp('LOAD_TESTDB: Concatenating all experimental databases. Changes will not be saved to original database!');
                    disp('LOAD_TESTDB: Use e.g. experiment_db(''ec'',''nori001'') to open specific database, or use host(''nori001'')');
                end
                
                % matching structure to ectestdb_daneel_empty
                db_empty = load(fullfile(expdatabasepath(where),'Empty', 'ectestdb_empty'));
                db_empty = db_empty.db;
                
                % load separate testdatabases and merge
                setups = {'nori001','nin380','daneel','antigua'};
                for s = 1:length(setups)
                    if ~isempty(db)
                        load_main = false;
                    end
                    dbt = load_expdatabase( ['ectestdb_' setups{s}],where,[],load_main,verbose );
                    dbt = structconvert(dbt,db_empty);
                    db = [db dbt]; %#ok<AGROW>
                end
                
                whichdb = 'ectestdb.mat';
                filename=fullfile(expdatabasepath(where),whichdb);
        end
    otherwise
        [db_single,filename] = load_expdatabase(whichdb,where,[],load_main,verbose);
        if ~isempty(db_single) &&  isfield(db_single(1),'stack') % i.e. microscopy record
            % matching structure to tptestdb_olympus_empty
           if 0
            db_empty = load(fullfile(expdatabasepath(where),'Empty', 'tptestdb_olympus_empty'));
            db_empty = db_empty.db;
            db_single = structconvert(db_single,db_empty);
           end
%         elseif ~isempty(db_single) &&  isfield(db_single(1),'electrode') % i.e. microscopy record
%             % matching structure to tptestdb_olympus_empty
%             db_empty = load(fullfile(expdatabasepath(where),'Empty', 'ectestdb_daneel_empty'));
%             db_empty = db_empty.db;
%             db_single = structconvert(db_single,db_empty);
        end

        
        db = [db db_single]; 
end


