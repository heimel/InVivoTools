function folder = find_sessiondata_folder( session )
%FIND_SESSIONDATA_FOLDER finds raw session data on the network
%
% folder = find_sessiondata_folder( session )
%
% 2022, Alexander Heimel

datasetId = session.dataset;
subjectId = session.subject;
setupId = session.setup;
yearId = session.year;
monthId = session.month;
dayId = session.day;
isoDate = session.isodate;

location = {};
location{1} = '\\vs01\MVP\Shared\InVivo';
location{2} = '\\vs01\CSF_Data\Shared\InVivo';
location{3} = '\\vs03\VS03-CSF-1\Heimel\InVivo';
nLocations = 3;

for i = 1:nLocations
    rootFolder = location{i};
    folder = fullfile(rootFolder,'Electrophys',setupId,yearId,monthId,dayId);
    if folder_exists_and_not_empty( folder)
        return
    end
    folder = fullfile(rootFolder,'Twophoton',setupId,subjectId,isoDate);
    if folder_exists_and_not_empty( folder)
        return
    end
    folder = fullfile(rootFolder,'Imaging',setupId,yearId,monthId,dayId);
    if folder_exists_and_not_empty( folder)
        return
    end
    switch lower(setupId)
        case 'andrew'
            folder = fullfile(rootFolder,'Imaging',setupId,yearId,monthId,[ dayId 'a']);
            if folder_exists_and_not_empty( folder)
                return
            end
        case 'daneel'
            folder = fullfile('\\multivac\daneel',yearId,monthId,dayId );
            if folder_exists_and_not_empty( folder)
                return
            end
    end

end

folder = '';

