function [t,wv] = loadspike2(smrfilename,records_to_get,record_units)
%LOADSPIKE2 loads spike2 into mclust 
%
%  INPUTS
% smrfilename = file name string
% records_to_get = a range of values
% record_units = a flag taking one of 5 cases (1,2,3,4 or 5)
%       1. implies that records_to_get is a timestamp list.
%       2. implies that records_to_get is a record number list
%       3. implies that records_to_get is range of timestamps (a vector with 2
%          elements: a start and an end timestamp)
%       4. implies that records_to_get is a range of records (a vector with 2
%          elements: a start and an end record number)
%       5. asks to return the count of spikes (records_to_get should be [] in this case)
%    In addition, if only smrfilename is passed in then the entire file should be read.
%
%  OUTPUT
%      [t, wv]
%           t = n x 1: timestamps of each spike in file
%           wv = n x 4 x 32 waveforms
%
%  2013, Alexander Heimel
%

t = [];
wv = [];

cells={};

ttl_delay = 0.0115;

%    secondsmultiplier = 1.000018; % nin380 2012-08
warning('LOADSPIKE2:TIMING','LOADSPIKE2: Alexander: improve and generalize timing correction, joint for ec and lfp');
warning('off', 'LOADSPIKE2:TIMING');

secondsmultiplier = 1.000032; % daneel 2012-09-18

ttlchannelname='TTL';
unitchannelname='Spikes';


fid=fopen(smrfilename);
if fid==-1
    logmsg(['Failed to open  ' smrfilename]);
    return;
end

list_of_channels=SONChanList(fid);
unitchannel=findchannel(list_of_channels,unitchannelname);
ttlchannel=findchannel(list_of_channels,ttlchannelname);
if unitchannel==-1 || ttlchannel==-1
    return  % didn't find one of the channels
end
[data_units,header_units]=SONGetChannel(fid,unitchannel);
if ~isfield(header_units,'kind') || header_units.kind~=6
    logmsg(['Unitchannel is of unexpected kind for ' smrfilename']);
    return
end
sample_interval=SONGetSampleInterval(fid,unitchannel);
[data_ttl,header_ttl]=SONGetChannel(fid,ttlchannel);
if ~isstruct(header_ttl) || header_ttl.kind~= 3
    logmsg(['TTLchannel is of unexpected kind for ' smrfilename]);
    return
end
fclose(fid);

% apply time correction
data_ttl = data_ttl * secondsmultiplier;
data_units.timings = data_units.timings * secondsmultiplier;

% load stimulus starttime
datapath = fileparts(smrfilename);
stimsfilename=fullfile(datapath,'stims.mat');
if exist(stimsfilename,'file')
    stimsfile=load(stimsfilename);

    % shift time to fit with TTL and stimulustimes
    timeshift=stimsfile.start-data_ttl(1);
    timeshift=timeshift+ ttl_delay; % added on 24-1-2007 to account for delay in ttl
    data_units.timings=data_units.timings+timeshift;

    intervals=[stimsfile.start ...
        stimsfile.MTI2{end}.frameTimes(end)+10];
else
    intervals = []; 
end

t = data_units.timings;
w(:,1,:)=data_units.adc;
w(:,[2:4],:) = 0;

switch record_units
    case 5 % return number of spikes 
        t = length(t);
end

return

function channel=findchannel(list_of_channels,channelname)
ch=1;
channel=-1;
while ch<=length(list_of_channels)
    if strcmp(list_of_channels(ch).title,channelname)==1
        channel=list_of_channels(ch).number;
        break;
    else
        ch=ch+1;
    end
end
if channel==-1
    logmsg(['Could not find channel named ' channelname]);
end
return


