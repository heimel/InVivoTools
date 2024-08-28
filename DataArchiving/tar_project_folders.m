%TAR_PROJECT_FOLDERS
%
%  Script to tar prepared project folders for archiving
%
%  For storage at Surf Data Archive the tar-files should be between 1GB and
%  200GB in size and average file size should not fall below 1GB.
%  Make sure that folders in Data_collection folder do not exceed 200 GB. 
%  Distribute over multiple folders if necessary
%
%  For data archiving check out: https://github.com/heimel/InVivoTools/blob/master/DataArchiving/archiving_checklist.md 
%  in particular run prepare_project_for_archiving to check presence of raw
%  data.
%
%  More guidelines at https://servicedesk.surf.nl/wiki/display/WIKI/Data+Archive#DataArchive-Guidelines
%
% 2022-2024, Alexander Heimel

projectId = 'Ahmadlou_Unpublished_Widefield_center_surround_13.14'; 
%prepRootFolder = '\\vs03\vs03-csf-1\PreparingForSurfArchive';
%prepRootFolder = '\\vs01\CSF_Data\Heimel';
prepRootFolder = '\\vs03\vs03-csf-1\Ahmadlou';

logmsg(['Tarring project ' projectId])
logmsg('Make sure Data_collections folder only contains folders and no files!')


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
