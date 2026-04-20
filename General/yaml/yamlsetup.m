function yamlsetup(fold,save)
%Download and add SnakeYAML.jar to java class path.
% yamlsetup          -download jar to same folder as this m file
% yamlsetup(fold)      -download to custom folder
% yamlsetup(fold,save)   -if true adds jar to static javaclasspath.txt
%
%See also: yamlread, yamlwrite
%
% Version 1.14
% Downloaded from https://github.com/serg3y/yaml-matlab/tree/main

%defaults
if nargin<1 || isempty(fold), fold = fileparts(mfilename('fullpath')); end
if nargin<2 || isempty(save), save = false; end

jar = 'snakeyaml-2.0.jar';
pth = fullfile(fold,jar);
url = 'https://repo1.maven.org/maven2/org/yaml/snakeyaml/2.0/snakeyaml-2.0.jar';

%download snakeyaml
if ~isfile(pth)
    websave(pth,url);
end

%add jar file temporarily to dynamic javaclasspaths
if ~any(contains(javaclasspath('-all'),jar))
    javaaddpath(pth)
end

%add jar file permanently to static javaclasspaths
if save
    javaPathsFile = fullfile(userpath,'javaclasspath.txt');
    if isfile(javaPathsFile)
        javapath = regexp(strip(fileread(javaPathsFile)),'[\r\n]','split')'; %read existing file
    else
        javapath = {};
    end
    javapath = regexprep(javapath,'.*snakeyaml.*',''); %remove old paths
    javapath(cellfun(@isempty,javapath)) = [];
    javapath = [javapath; pth]; %append new path to the end
    fid = fopen(javaPathsFile,'w');
    fprintf(fid,'%s\n',javapath{:}); %write new path
    fclose(fid);
end