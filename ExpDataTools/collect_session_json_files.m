function dbj = collect_session_json_files(pth,verbose)
%COLLECT_SESSION_JSON_FILES reads all json files in folder and subfolder
%
% DBJ = COLLECT_SESSION_JSON_FILES(PTH, VERBOSE)
%        PTH is starting path. Default '.'
%        If VERBOSE is true, then list every searched folder and added
%        session, otherwise only summary
%
% 2022, Alexander Heimel

if nargin<1 || isempty(pth)
    pth = '.';
end
if nargin<2 || isempty(verbose)
    verbose = false;
end

d = dir(fullfile(pth,'*session.json'));
dbj = [];
for i = 1:length(d)
    jsonfile = fullfile(pth,d(i).name);
    if verbose
        logmsg(['Adding ' jsonfile]);
    end
    json = jsondecode(fileread(jsonfile));
    if isempty(dbj)
        dbj = json;
    else
        dbj  = structconvert(dbj,json);
        json  = structconvert(json,dbj(1));
        dbj = [dbj json];
    end
end

d = dir(pth);
d = d([d.isdir]); % select folders
for i = 3:length(d) % skip . and ..
    if verbose 
        disp([ '-' d(i).name]);
    end
    dbjn = collect_session_json_files(fullfile(pth,d(i).name));
    if isempty(dbj)
        dbj = dbjn;
    elseif ~isempty(dbjn)
        dbj  = structconvert(dbj,dbjn(1));
        dbjn  = structconvert(dbjn,dbj(1));
        dbj = [dbj dbjn];
    end
    
end




