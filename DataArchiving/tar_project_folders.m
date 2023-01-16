%TAR_PROJECT_FOLDERS
%
%  Script to tar prepared project folders for archiving
%
% 2022, Alexander Heimel

projectId = 'Vangeneugden_2019_Curr_Biol_11.51_13.13_13.59_14.90'; 

logmsg(['Tarring project ' projectId])

prepRootFolder = '\\vs03\vs03-csf-1\ReadyForSurfArchive';

if ~exist(prepRootFolder,'dir')
    logmsg([prepRootFolder ' does not exist.']);
    return
end

projectFolder = fullfile(prepRootFolder,projectId);
if ~exist(projectFolder,'dir')
    logmsg([projectFolder ' does not exist.']);
    return
end

tarlogFilename = fullfile(projectFolder,'tarlog.txt');

cmds = {};
cmds{1} = ['cd "' projectFolder '"'];


potentialFolders = dir(projectFolder);
i = 1;
while i <= length(potentialFolders)
    switch potentialFolders(i).name
        case {'.','..'}
            % ignore
        case 'Data_collection'
            d = dir(fullfile(potentialFolders(i).folder,'Data_collection'));
            for j=1:length(d)
                switch d(j).name
                    case {'.','..'}
                        % ignore
                    otherwise
                        if d(j).isdir
                            folder = fullfile(d(j).name);
                            cmds{end+1} = ['echo "Data_collection' filesep folder '" >> ' tarlogFilename];
                            cmds{end+1} = ['tar -cvf "Data_collection_' folder '.tar" "Data_collection' filesep folder '"'];
                        end
                end
            end % j
        otherwise
            if potentialFolders(i).isdir
                folder = fullfile(potentialFolders(i).name);
                cmds{end+1} = ['echo "' folder '" >> ' tarlogFilename];
                cmds{end+1} = ['tar -cvf "' folder '.tar" "' folder '"'];
            end
    end
    i = i + 1;
end

cmds{end+1} = ['echo "Done tarrring ' projectFolder '" >> ' tarlogFilename];

tarFilename = fullfile(projectFolder,'tarcommands.bat');
writelines(cmds,tarFilename,WriteMode='overwrite');
logmsg(['Wrote ' tarFilename]);
