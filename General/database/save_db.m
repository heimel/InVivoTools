function [filename,lockfile]=save_db(db, filename , suggest,lockfile)
%SAVE_DB saves matlab struct array database
%
% FILENAME = SAVE_DB( DB, [FILENAME], [SUGGEST], [LOCKFILE])
%      if no FILENAME is given, then a dialog popups to select a name
%      SUGGEST is what to suggest if no filename is given
%
% 2007-2013, Alexander Heimel
%

if nargin<4;lockfile='';end
if nargin<2;filename='';end
if nargin<3;suggest='';end

if isempty(filename)
    if isempty(suggest)
        suggest='database.mat';
    end
    filterspec = {'*.mat','MATLAB Files (*.mat)'; ...
        '*.csv','CSV Files (*.csv)'};
    [filename,pathname]=uiputfile(filterspec,'Save database',suggest);
    if filename==0
        return
    end
    filename=fullfile(pathname,filename);
end

if exist(filename,'dir')
    error('SAVE_DB:FOLDER_EXISTS',['A folder already exists with name ' filename ]);
end

[dummy1,dummy2,extension] = fileparts(filename);

switch lower(extension)
    case '.csv'
        save_csv(db,filename);
    otherwise
        if ~strcmp(extension,'.mat')
            filename = [filename '.mat'];
        end
        save_mat(db,filename,lockfile)
end
return

function save_csv(db,filename)


saveStructArray(filename,db,1,';',1);

return


function save_mat(db,filename,lockfile)
debug = 1;


[res,newlockfile]=checklock(filename);
if res==1 % a lockfile exists
    if newlockfile~=lockfile
        [res,lockfile]=setlock(filename);
        if res==0
            [filename,lockfile]=save_db(db, '',filename,lockfile);
            return
        end
    end
else % no lockfile exists yet
    [res,lockfile]=setlock(filename);
end

h=waitbar(0,'Saving database. Please wait...');

if debug
    tic
end

v=version;
if v(1)<'5'
    error('Cannot save in Version 5 matlab format');
end
if v(1)=='5'
    if exist(filename,'file')
        movefile(filename,[filename '_copy']);
    end
    save(filename,'db','-mat')
    if debug
        disp('SAVE_DB: Saved in v5 format');
        toc
    end
else
    if exist(filename,'file')
        movefile(filename,[filename '_copy'],'f');
    end
    try
        save(filename,'db','-mat','-v7');
        if debug
            tc = toc;
            disp(['SAVE_DB: Saved ' filename ' in v6 format in ' num2str(round(tc)) ' s.']);
        end
    catch
        [p,fname,ext]=fileparts(filename);
        tempfile =fullfile(tempdir,[fname ext]);
        save(tempfile,'db','-mat');
        movefile(tempfile,filename,'f')
        if debug
            tc = toc;
            disp(['SAVE_DB: Saved ' filename ' in format of ' version ' in ' num2str(round(tc)) ' s.']);
        end
    end
end
waitbar(1,h);
delete(h);