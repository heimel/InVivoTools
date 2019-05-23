function record = fiberphotometry( duration,record,verbose)
%FIBERPHOTOMETRY starts fiberoptometry and sends trigger at start
%
%  RECORD = FIBERPHOTOMETRY(DURATION, RECORD, VERBOSE )
%
% 2019, Alexander Heimel

if nargin<1 || isempty(duration)
    duration = 60; % s
end
if nargin<2 || isempty(record)
    record.mouse = 'testmouse';
    record.date = datestr(now,'yyyy-mm-dd');
    record.experiment = '1820.fiberphoto';
    record.setup = 'fiberphoto';
    record.datatype = 'wc';
    record.epoch = 't00001';
    record.experimenter = 'ma';
    record.comment = '';
    record.measures = [];
end
if nargin<3 || isempty(verbose)
    verbose = true;
end


logmsg('Set params.experimentpath_localroot in processparam_local.m for place to store data');


remotecommglobals

logmsg(['Communicating via ' Remote_Comm_dir]);


% par = fpprocessparams( record ); % to implement in the future
par.timeshift = 0.036; % calibrated on 2019-11-04 for NI USB-6001
par.voltage_high = 3.3; % V
par.voltage_low = 0; % V
par.min_pulsesamples = 1024; % for some NI board
par.sample_rate = 1000; % Hz

triggerpulse = par.voltage_low * ones(ceil(duration*par.sample_rate),1);
triggerpulse(1:round(par.sample_rate *0.1),1) = par.voltage_high; % trigger up samples

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

try
    session = daq.createSession('ni'); % National Instruments USB-6001
catch me
    switch me.identifier
        case 'daq:general:unknownVendor'
            errormsg('No National Instrument board available');
            return
    end
end

% Write acqParams_in
aqDat.name = 'fiber';
aqDat.type = 'fiber';
aqDat.fname = 'fiber';
aqDat.samp_dt = NaN;
aqDat.reps = ceil( duration/10); % 10s per rep
aqDat.ref = 1;
aqDat.ECGain = NaN;
writeAcqStruct(fullfile(datapath,'acqParams_in'),aqDat);
% wait to finish writing and write acqReady
pause(0.3);
write_pathfile(fullfile(Remote_Comm_dir,'acqReady'),localpath2remote(datapath));

session.Rate = par.sample_rate;
session.NumberOfScans = duration * session.Rate;
addAnalogOutputChannel(session,'Photometry', 'ao1', 'Voltage'); % triggerpulse
addAnalogInputChannel(session,'Photometry', 0 , 'Voltage'); % photometry
addAnalogInputChannel(session,'Photometry', 1 , 'Voltage'); % measuring optopulse from raspipi
queueOutputData(session,triggerpulse);

% data=linspace(-1,1,5000)';
% lh = addlistener(s,'DataRequired', ...
%         @(src,event) src.queueOutputData(data));
    
figure
plotData('reset',[]);
lh = addlistener(session,'DataAvailable', @plotData);
% session.IsContinuous = true;

prepare(session);

pause(2); % add some time for other computers to prepare
logmsg(['Starting acquisition of ' num2str(duration) ' s']);
startBackground(session);
logmsg(['Started recording and sent triggerpulse at ' datestr(now,'hh:mm:ss')]);


% pause(5);
% stop(session);
wait(session);

logmsg(['Stopped recording ' datestr(now,'hh:mm:ss')]);
record.measures.parameters = par;


[data,time] = plotData('retrieve',[]);

time = time + par.timeshift; % to match calibration
delete(lh); % delete datahandler

save(fullfile(datapath,'fiberphotometry.mat'),'time','data','par');
save(fullfile(datapath,'record.mat'),'record','-mat');

figure('Name',recordfilter(record));
plot(time,data);
xlabel('Time (s)');
ylabel('Voltage')


function [outdata,outtime] = plotData(src,event)
persistent data time counter

n_channels = 2;

outdata = [];
outtime = [];
nbuffer = 1000000;

if ischar(src)
    switch src
        case 'reset'
            data = [];
            return
        case 'retrieve'
            outdata = data;
            outtime = time;
            return
    end
end

if isempty(data)
    data = NaN(nbuffer,n_channels);
    time = NaN(nbuffer,1);
    counter = 1;
end

n = size(event.Data,1);
data(counter:counter+n-1,:) = event.Data;
time(counter:counter+n-1,:) = event.TimeStamps;
counter = counter + n;
if counter+n > nbuffer
    counter = 1;
end

plot(time,data(:,1)); % plot fiber data
xlabel('Time (s)');
ylabel('Voltage')
xlim([max([0 time(counter-1)-2]) time(counter-1)]);


