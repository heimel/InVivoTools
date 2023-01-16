function [present,sessionFolder] = is_session_in_project(projectFolder,session)
%IS_SESSION_IN_PROJECT returns true if session data is in Data_collection
%
% [present,sessionFolder] = is_session_in_project(projectFolder,session)
%
%    session is struct with fields datasetId, subjectId, setupId, dateId;
%
%
% 2022, Alexander Heimel

present = false;

datasetId = session.dataset;
subjectId = session.subject;
setupId = capitalize(session.setup);
if length(session.date)==10
    yearId = session.date(1:4);
    monthId = session.date(6:7);
    dayId = session.date(9:10);
else
    yearId = '';
    monthId = '';
    dayId = '';
end
isoDate = [yearId '-' monthId '-' dayId];

datacollectionFolder = fullfile(projectFolder,'Data_collection');

sessionFolder = fullfile(datacollectionFolder,datasetId,subjectId,isoDate,setupId);
if folder_exists_and_not_empty( sessionFolder)
    present = true;
    return
end
sessionFolder = fullfile(datacollectionFolder,'TwoPhoton',datasetId,'Data',subjectId,isoDate);
if folder_exists_and_not_empty( sessionFolder)
    present = true;
    return
end
sessionFolder = fullfile(datacollectionFolder,'TwoPhoton',datasetId,subjectId,isoDate);
if folder_exists_and_not_empty( sessionFolder)
    present = true;
    return
end
sessionFolder = fullfile(datacollectionFolder,'Microscopy',setupId,datasetId,subjectId,isoDate);
if folder_exists_and_not_empty( sessionFolder)
    present = true;
    return
end
sessionFolder = fullfile(datacollectionFolder,datasetId,subjectId,isoDate,setupId);
if folder_exists_and_not_empty( sessionFolder)
    present = true;
    return
end
sessionFolder = fullfile(datacollectionFolder,datasetId,subjectId,session.date,setupId);
if folder_exists_and_not_empty( sessionFolder)
    present = true;
    return
end
sessionFolder = fullfile(datacollectionFolder,'Imaging',setupId,datasetId,subjectId,session.date);
if folder_exists_and_not_empty( sessionFolder)
    present = true;
    return
end
sessionFolder = fullfile(datacollectionFolder,'Electrophys',setupId,datasetId,subjectId,isoDate);
if folder_exists_and_not_empty( sessionFolder)
    present = true;
    return
end
if strcmpi(session.date,'confocal') && strcmpi(setupId,'Lif')
    sessionFolder = fullfile(datacollectionFolder,datasetId,subjectId,session.date,setupId);
    if folder_exists_and_not_empty( sessionFolder)
        present = true;
        return
    end
end

sessionFolder = '';
end


