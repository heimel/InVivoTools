function [datapath,record] = find_unique_epochpath(record)
%FIND_UNIQUE_EPOCHPATH find unique epoch path
%
%  [DATAPATH, RECORD] = FIND_UNIQUE_EPOCHPATH( RECORD )
%
% 2019, Alexander Heimel

datapath = experimentpath(record,true,true,'2015t');
d = dir(datapath);
if length(d)>2
    logmsg('Epoch exists. Increasing epoch number.');
end
while length(d)>2 % not empty
    record.epoch = ['t' num2str(str2double(record.epoch(2:end))+1,'%05d')];
    datapath = experimentpath(record,true,true,'2015t');
    d = dir(datapath);
end
logmsg(['Writing data to ' datapath]);