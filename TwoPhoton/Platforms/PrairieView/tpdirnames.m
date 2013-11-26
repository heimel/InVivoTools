function dirnames = tpdirnames( dirname )
%TPDIRNAMES returns cell list of twophoton subdirectories
%
% Steve VanHooser, Alexander Heimel
%

pathstr = fileparts(dirname);

% figure out how many data directories we have
TPD = dir([dirname '-*']);
if isempty(TPD)
  error(['Cannot find any directories ' dirname '-001, -002, etc.']); 
end;

dirnames = sort({TPD.name});  

for k=1:length(dirnames),
  dirnames{k}=fullfile(pathstr,dirnames{k});
end