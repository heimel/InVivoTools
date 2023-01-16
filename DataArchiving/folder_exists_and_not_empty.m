function present = folder_exists_and_not_empty( sessionFolder)
%FOLDER_EXISTS_AND_NOT_EMPTY checks if folder exists and has at least 3 items
%
% 2022, Alexander Heimel

present = false;
if exist(sessionFolder,'dir')
    d = dir(sessionFolder);
    if length(d)>2 % at least .,.., and one more item
        present = true;
        return
    end
end
end
