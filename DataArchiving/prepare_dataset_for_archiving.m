function [datasetPrepared,copyCommands,missingSessions] = prepare_dataset_for_archiving(projectFolder,datasetName)
%PREPARE_DATASET_FOR_ARCHIVING prepares dateset for archiving
%
% prepare_dataset_for_archiving(projectFolder,datasetName)
%
% 2022, Alexander Heimel

datasetPrepared = false;
copyCommands = {};
missingSessions = {};

logmsg(['Preparing dataset ' datasetName])

datacollectionFolder = fullfile(projectFolder,'Data_collection');
databaseFolder = fullfile(datacollectionFolder,'Databases');

d = dir(databaseFolder);
d = d([d.isdir]);
d = d(3:end); % skip '.' and '..';
databaseFolderNames = arrayfun(@(x) [fullfile(x.folder,x.name)],d,'UniformOutput',false);
databaseFolders = databaseFolderNames(contains(databaseFolderNames,[filesep datasetName]));

dbNames = collect_databases( databaseFolders);

nDb = length(dbNames);
logmsg(['   ' 'Found ' num2str(length(dbNames)) ' potential databases.']);

dbj = struct([]);
count = 0;
setupId = '';
dateId = '';
for d=1:nDb
    try
        load(dbNames{d},'db');
    catch me
        logmsg(me.message);
        logmsg('Please fix.')
        return
    end
    if isempty(db) || ~isfield(db,'mouse') || ~isfield(db,'date')
        logmsg([dbNames{d} ' is not a test database.'])
        continue
    end
    % logmsg(['Processing ' dbNames{d}])
    nErrorRecords = 0;
    for i = 1:length(db)
        record = db(i);

        if isempty(record.mouse)
            continue
        end

        if contains(record.experimenter,'yi')
            % no need to move yi's data
            continue
        end

        if contains(record.mouse,'test') || contains(record.mouse,'crumbs')  || contains(record.mouse,'Test') 
            continue
        end

        if contains(record.mouse,'2013.05.') || contains(record.mouse,'agar') 
            continue
        end

        if contains(record.mouse,' 11.51.01.45') && ~contains(datasetName,'11.51')
            continue
        end
        if contains(record.mouse,' 08.52.2.10') && ~contains(datasetName,'08.52')
            continue
        end
        if strcmp(record.mouse,'  ') 
            continue
        end


        [datasetId, subjectId] = getIds(record);
        if isempty(datasetId)
            %logmsg(['No Ids for record ' num2str(i)]);
            nErrorRecords = nErrorRecords + 1;
            datasetId = datasetName;
        elseif ~strcmp(datasetId,datasetName)
            nErrorRecords = nErrorRecords + 1;
            continue
        end

        if isempty(subjectId)
            subjectId = record.mouse;
        end

        if ~isempty(record.setup)
            setupId = record.setup; % otherwise use prev.
        end
        dateId = record.date; 

        crit = ['dataset=' datasetId ',subject=' subjectId ...
            ',setup=' setupId ',date=' dateId];
        if isempty(find_record(dbj,crit))

            count = count+1;
            dbj(count).dataset = datasetId;
            dbj(count).subject = subjectId;
            dbj(count).setup = setupId;
            dbj(count).date = dateId;
            if length(dateId)==10
                dbj(count).year = dbj(count).date(1:4);
                dbj(count).month = dbj(count).date(6:7);
                dbj(count).day = dbj(count).date(9:10);
            else
                dbj(count).year = '';
                dbj(count).month = '';
                dbj(count).day = '';
            end

            dbj(count).isodate = [dbj(count).year '-' dbj(count).month '-' dbj(count).day];

        end
    end % i
    %         if nErrorRecords>0
    %             logmsg(['Errors: ' num2str(nErrorRecords)]);
    %         end

end % d
nDbj = count;
logmsg(['   ' num2str(nDbj) ' sessions found.']);
if nDbj == 0
    return
end

for i=1:nDbj
    [dbj(i).inprojectfolder,dbj(i).sessionfolder] = is_session_in_projectfolder(projectFolder,dbj(i));

%     if ~dbj(i).inprojectfolder
%         dbj(i)
%         keyboard
%     end
end

nNotInProjectFolder = sum(~[dbj.inprojectfolder]);
if nNotInProjectFolder> 0
    logmsg([ '   ' num2str(nNotInProjectFolder) ' sessions are not in project folder.'])
else
    logmsg(['   ' 'Data for all sessions is present in project folder.'])
    datasetPrepared = true;
    return
end

dbj = dbj(~[dbj.inprojectfolder]); % select session records that are not in project folder


for i = 1:length(dbj)
    srcfolder = find_sessiondata_folder(dbj(i));

    if ~isempty(srcfolder)
        dbj(i).srcfolder = srcfolder;
        dbj(i).founddata = true;

        dbj(i).desfolder = fullfile(datacollectionFolder,dbj(i).dataset,dbj(i).subject,dbj(i).isodate,dbj(i).setup);

        
        copyCommands{end+1} = [...
            'disp(''' dbj(i).desfolder ''');' ...
            'copyfile(''' dbj(i).srcfolder ''' , ''' dbj(i).desfolder ''');' ]; %#ok<AGROW>

    else 
        missingSessions{end+1} = [dbj(i).dataset ' \ '...
            dbj(i).subject ' \ '...
            capitalize(dbj(i).setup) ' \ '...
            dbj(i).date  ]; %#ok<AGROW> 
        dbj(i).founddata = false;
    end
end
nNotFoundData = sum(~[dbj.founddata]);

logmsg(['   ' 'Data not found for ' num2str(nNotFoundData) ' sessions.']);

copyCommands = unique(copyCommands);
missingSessions = unique(missingSessions);




end

%%
function [datasetId, subjectId] = getIds( record )
datasetId = [];
subjectId = [];
if ~isfield(record,'mouse')
    return
end
if length(record.mouse)<5 || record.mouse(3)~= '.'
    return
end
subjectId = record.mouse;
datasetId = subjectId(1:5);
end

