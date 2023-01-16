%PREPARE_PROJECT_FOR_ARCHIVING
%
%  Script to prepare project for archiving
%
% 2022, Alexander Heimel

projectId = 'Camillo_2018_Sci_Rep_13.29_14.87'; 

logmsg(['Preparing project ' projectId])

prepRootFolder = '\\vs03\vs03-csf-1\PreparingForSurfArchive';

if ~exist(prepRootFolder,'dir')
    logmsg([prepRootFolder ' does not exist.']);
    return
end

projectFolder = fullfile(prepRootFolder,projectId);
if ~exist(projectFolder,'dir')
    logmsg([projectFolder ' does not exist.']);
    return
end


%% Check Ethics folder
ethicsFolder = fullfile(projectFolder,'Ethics');
d = dir(ethicsFolder);
d = d(3:end);
studyDossiers = {};
if isempty(d)
    msg = {'Nothing in Ethics folder'};
else
    msg = 'Study dossiers';
    for i=1:length(d)
        studyDossiers{i} = getProtocolId(d(i).name); %#ok<SAGROW> 
    end
    for i=1:length(d)
        msg = [msg ' ' studyDossiers{i}]; %#ok<AGROW> 
    end
end
logmsg(msg);
% writelines(msg,checkFilename,WriteMode='append');


%% Check Data_collection folder
datacollectionFolder = fullfile(projectFolder,'Data_collection');
if ~exist(datacollectionFolder,'dir')
    logmsg([datacollectionFolder ' does not exist.']);
    return
end

d = dir(datacollectionFolder);
datasetNames = {};
for i = 1:length(d)
    switch d(i).name
        case {'.','..','Databases'}
            % do nothing
        otherwise
            datasetNames{end+1} = d(i).name; %#ok<SAGROW>
    end
end
datasetNames = sort(datasetNames);

%% Check Databases folder
databasesFolder = fullfile(datacollectionFolder,'Databases');
if ~exist(databasesFolder,'dir')
    logmsg([databasesFolder ' does not exist.']);
    return
end

d = dir(databasesFolder);
databaseFolderNames = {};
databaseFolderNamesShort = {};

for i = 1:length(d)
    if ~d(i).isdir
        continue
    end
    switch d(i).name
        case {'.','..','Databases'}
            % do nothing
        otherwise
            databaseFolderNames{end+1} = fullfile(databasesFolder,d(i).name); %#ok<SAGROW>
            databaseFolderNamesShort{end+1} = getProtocolId(d(i).name); %#ok<SAGROW>
    end
end
databaseFolderNamesShort = unique(databaseFolderNamesShort);
% 

matchingNames = intersect(studyDossiers,databaseFolderNamesShort);
logmsg(['Datasets identified: ' flatten(cellfun(@(x) [x ', '],matchingNames,'UniformOutput',false))'])

nonMatchingNames = setxor(studyDossiers,databaseFolderNamesShort);
if ~isempty(nonMatchingNames)
    logmsg(['Discrepancy for datasets: ' flatten(cellfun(@(x) [x ', '],nonMatchingNames,'UniformOutput',false))'])
    logmsg('Please fix discrepancy by matching folders in Ethics and Data_collection\Databases.')
end

%% Prepare datasets 
batchFilename = fullfile(projectFolder, 'archiving_commands_batch.m');
if exist(batchFilename,'file')
    delete(batchFilename);
end
missingFilename = fullfile(projectFolder, 'missing_sessions.txt');
if exist(missingFilename,'file')
    delete(missingFilename);
end

datasetNames = matchingNames;

for ds = 1:length(datasetNames)
    [datasetPrepared,copyCommands,missingSessions] = prepare_dataset_for_archiving(projectFolder,datasetNames{ds});

    if length(copyCommands)>0
        writelines(copyCommands,batchFilename,WriteMode='append');
        logmsg(['   ' 'Wrote ' num2str(length(copyCommands)) ' commands to ' batchFilename]);
    end
    if length(missingSessions)>0
        writelines(missingSessions,missingFilename,WriteMode='append');
        logmsg(['   ' 'Wrote ' num2str(length(missingSessions)) ' missing sessions to ' missingFilename]);
    end
    if datasetPrepared
        msg = ['Dataset ' datasetNames{ds} ' is prepared.'];
    end
    logmsg(msg);
%     writelines(msg,checkFilename,WriteMode='append');

end % dataset ds


%% End of preparation
logmsg('Succesfully reached end of script.')


%%
function protocolId = getProtocolId( str )
protocolId = firstElement(split(str,{' ','_'}));
end

function y = firstElement(x)
y = x{1};

end
