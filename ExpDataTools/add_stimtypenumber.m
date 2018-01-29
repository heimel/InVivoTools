function add_stimtypenumber
%ADD_STIMTYPENUMBER adds typenumber to saveScript for a hupescript or borderscript
%
%  Should not be necessary for anything but the preliminary data
%
% 2010, Alexander Heimel
%

clear all
stimfilename = '/home/data/InVivo/Electrophys/2010/01/15/t00027/stims.mat';
backupfilename = [stimfilename '.backup'];
if ~exist(backupfilename,'file');
    copyfile(stimfilename,backupfilename);
end
load(stimfilename);

classtype = class(saveScript);

switch classtype
    case 'hupescript'
        expected_length = 3;
        typenumber = [1 2 3];
    case 'borderscript'
        expected_length = 8;
        typenumber = [1  4 2 3 3 2 4 1 ];
    otherwise
        disp('ADD_STIMTYPENUMBER: not a typenumber script');
        return
end

ss = get(saveScript);

if length(ss)~=expected_length
    error('ss not the right length');
end

for i = 1:expected_length
    p = getparameters(ss{i});
    p.typenumber = typenumber(i);
    ss{i} = setparameters(ss{i},p);
end

do = getDisplayOrder( saveScript);
for i=1:expected_length
    saveScript = remove(saveScript,1);
end
for i=1:expected_length
    saveScript = append(saveScript,ss{i});
end

saveScript = setDisplayMethod(saveScript, 2, do);
clear('do','i','p','ss','backupfilename');

save(stimfilename,'-v7');
logmsg('Succesfull');
