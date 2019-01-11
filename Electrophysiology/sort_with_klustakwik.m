function cells = sort_with_klustakwik(orgcells,record)
%SORT_WITH_KLUSTAKWIK
%
%   CELLS = SORT_WITH_KLUSTAKWIK( ORGCELLS, RECORD )
%
% 2013-2019, Alexander Heimel
%

params = ecprocessparams(record);

orgcells = pool_cells( orgcells );

cells = [];

if isunix
    kkexecutable = 'KlustaKwik';
else
    [r,kkexecutable]=system('where klustakwik.exe');
    kkexecutable = ['"' strtrim(kkexecutable) '"'];
    if r~=0
        kkexecutable = ['"' which('KlustaKwik.exe') '"'];
    end
end

status = system(kkexecutable);

if status~=1
    if isunix
        kkexecutable = 'MaskedKlustaKwik';
    else
        kkexecutable = ['"' which('MaskedKlustaKwik.exe') '"'];
    end
    status = system(kkexecutable);
end

if status~=1
    logmsg('KlustaKwik not present. Go to https://github.com/klusta-team/klustakwik and follow instructions to install.');
    return
end

if ~params.sort_always_resort
    cells = import_klustakwik(record,orgcells);
end

if isempty(cells) %|| 1
    channels = unique([orgcells.channel]);
    fclose('all'); 
    if params.sort_always_resort
        for ch = channels
            filenamef = fullfile(experimentpath(record,true),[ 'klustakwik.*.' num2str(ch)]);
            d = dir(filenamef);
            if ~isempty(d)
                delete(filenamef);
            end
        end
    end
    
    write_spike_features_for_klustakwik( orgcells, record,channels );
    savepwd = pwd;
    cd(experimentpath(record));
    arguments = params.sort_klustakwik_arguments;
    
    for ch=channels
       cmd = [kkexecutable ' klustakwik ' num2str(ch) ' ' arguments];
        logmsg(cmd);
        [status,result] = system(cmd);
        if status == 1
            logmsg(['Check if Klustakwik is installed as ' kkexecutable '. Otherwise download and install from https://github.com/klusta-team/example']);
            errormsg(result(max(1,end-100):end),true);
        else
            logmsg(result(max(1,end-100):end));
        end
    end
    cd(savepwd);
    cells = import_klustakwik(record,orgcells);
end

