function cells = sort_with_klustakwik(orgcells,record)
%SORT_WITH_KLUSTAKWIK
%
%   SORT_WITH_KLUSTAKWIK 
%
% 2013, Alexander Heimel
%

params = ecprocessparams(record);

cells = [];

if isunix
    kkexecutable = 'KlustaKwik';
else
    kkexecutable = which('KlustaKwik.exe');
end

[status,res] = system(kkexecutable);

if status~=1
    if isunix
        kkexecutable = 'MaskedKlustaKwik';
    else
        kkexecutable = which('MaskedKlustaKwik.exe');
    end
    [status,res] = system(kkexecutable);
end

if status~=1
    logmsg('KlustaKwik not present');
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
            errormsg(result(max(1,end-100):end),true);
        else
            logmsg(result(max(1,end-100):end));
        end
    end
    cd(savepwd);
    cells = import_klustakwik(record,orgcells);
end

