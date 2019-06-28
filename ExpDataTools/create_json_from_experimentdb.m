function create_json_from_experimentdb( db, overwrite_existing_jsonfiles, verbose )
%CREATE_JSON_FROM_EXPERIMENTDB creates json files in all data folders from db records
%
%  CREATE_JSON_FROM_EXPERIMENTDB( DB, OVERWRITE_EXISTING_JSONFILES=false, VERBOSE=true)
%
%  2019, Alexander Heimel

delete_all_existing_jsonfiles = false;

if nargin<3 ||isempty(verbose)
    verbose = true;
end
if nargin<2 || isempty(overwrite_existing_jsonfiles)
    overwrite_existing_jsonfiles = false;
end
if nargin<1
    logmsg('Need database to process. Try e.g. db = load_testb(''oi'').');
    return
end
    
count = 0;
for i=1:length(db)
    record = db(i);
    
    % required json fields
    if isfield(record,'experiment')
        json.project = record.experiment;
    else
        json.project = experiment();
    end
    
    json.dataset = json.project; % for new records this should be distinct from project
    json.subject = record.mouse;
    json.date = record.date;
    json.setup = record.setup;
    json.investigator = record.experimenter;
    json.condition = ''; % not used in experimentdb
    json.version = '1.0';
    
    json.session = '0001';
    if isfield(record,'test')
        json.session = record.test;
    elseif isfield(record,'epoch')
        json.session = record.epoch;
    end

    % optional
    json.created_from = recordfilter(record);
    
    if isfield(record,'stack')
        json.stack = record.stack;
    end
    
    % saving
    sessionname = subst_filechars( [ json.subject '_' json.date '_' json.setup '_' json.session ]);
    
    try
        datapath = experimentpath(record);
    catch me
        logmsg([me.message ' for ' recordfilter(record)]);
        continue
    end
    
    
    if ~exist(datapath,'dir')
        if verbose
            datapath = experimentpath( record, [], [], [], [], true );
        end
        logmsg(['Not creating json. Folder ' datapath ' does not exist for ' recordfilter(record)]);
        continue
    end
    
    if delete_all_existing_jsonfiles
        if ~isempty(dir(fullfile(datapath,'*_session.json'))) %#ok<UNRCH>
            delete(fullfile(datapath,'*_session.json'));
        end
    end
    
    jsonfilename = fullfile(datapath,[sessionname '_session.json']);

    if exist(jsonfilename,'file') && ~overwrite_existing_jsonfiles
        if verbose
            logmsg(['Not overwriting existing json file for ' recordfilter(record)]);
        end
        continue
    end
    
    if verbose
        logmsg(['Writing ' jsonfilename ]);
    end
    try
        savejson('', json, jsonfilename);
    catch me
       errormsg([me.message ' for ' recordfilter( record )]);
       keyboard
    end
    count = count + 1;
end
logmsg(['Wrote ' num2str(count) ' json-files.']);

