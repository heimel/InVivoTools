%function dani_scripts
%DANI_SCRIPTS loads dani's scripts from desktop folder
%
% 2012, Alexander Heimel

folder = fullfile(getdesktopfolder,'Dani');
d = dir(folder);
for i=1:length(d)
    if strcmp(d(i).name( max(1,end-2):end),'mat')
        load( fullfile(folder,d(i).name));
    end
end
%load(fullfile(getdesktopfolder,'dani_scripts.mat'));