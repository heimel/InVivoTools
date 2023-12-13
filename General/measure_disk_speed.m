% measure_disk_speed. Short script to measure writing and reading times
%
%
%
% 2022, Alexander Heimel

M = rand(10000,10000);
arraysize = 8 * numel(M);

pth = 'C:\Temp';
filename = fullfile(pth,'temptest.mat');

disp(['Writing ' num2str(arraysize) ' 3 times to ' filename])
tic
for i=1:3
    disp([num2str(i) ' time'])
    save(filename,"M")
end
toc

disp(['Loading ' num2str(arraysize) ' 3 times from ' filename])
tic
for i=1:3
    disp([num2str(i) ' time'])
    load(filename,"M")
end
toc