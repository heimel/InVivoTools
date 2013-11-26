function cells = sort_with_klustakwik(orgcells,record)
%SORT_WITH_KLUSTAKWIK
%
%   SORT_WITH_KLUSTAKWIK 
%
% 2013, Alexander Heimel
%

cells = [];

kkexecutable = 'KlustaKwik';

[status,res] = system(kkexecutable);


if status~=1
    kkexecutable = 'MaskedKlustaKwik';
    [status,res] = system(kkexecutable);
end

if status~=1
    disp('SORT_WITH_KLUSTAKWIK: KlustaKwik not present');
    return
end


try
    cells = import_klustakwik(record,orgcells);
catch
    cells = [];
end
if isempty(cells) %|| 1
    write_spike_features_for_klustakwik( orgcells, record );
    savepwd = pwd;
    cd(fullfile(ecdatapath(record),record.test));
    arguments = [ ...
         ' -ElecNo 1' ...
         ' -nStarts 1' ...
        ' -MinClusters 1' ...   % 20
        ' -MaxClusters 10' ...   % 30
         ' -MaxPossibleClusters 30' ...  % 100
         ' -UseDistributional 0' ... 
         ' -PriorPoint 1'...
         ' -FullStepEvery 20'...
        ' -UseFeatures 10111'...   % 11111
         ' -SplitEvery 40' ...
         ' -RandomSeed 1' ...
         ' -MaxIter 500' ...  % 500  
        ' -DistThresh 6.9' ...   % 6.9
        ' -ChangedThresh 0.05' ... % 0.05
        ' -PenaltyK 0'...
        ' -PenaltyKLogN 1' ];

%             ' -UseMaskedInitialConditions 1'...  % 1
%         ' -AssignToFirstClosestMask 1'... 

    system([kkexecutable ' klustakwik 1' arguments]);
    cd(savepwd);
    cells = import_klustakwik(record,orgcells);
end

