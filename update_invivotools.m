function update_invivotools
%UPDATE_INVIVOTOOLS pulls latest version from github repository
%
% 2014, Alexander Heimel

if isunix
    curdir = pwd;
    cd(fileparts(mfilename('fullpath')));
    [fail,result] = system('git pull');
    if ~fail
        logmsg(['Succesful: ' result]);
    else
        logmsg('Unsuccessful: result');
    end
    cd(curdir);
else
    logmsg('Not implemented yet. Run Github and synchronize manually.');
end