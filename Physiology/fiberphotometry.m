function record = fiberphotometry( record)
%FIBERPHOTOMETRY starts fiberoptometry and sends trigger at start
%
% 2019, Alexander Heimel


logmsg('Set params.experimentpath_localroot in processparam_local.m for place to store data');


% National Instruments USB-6001 

remotecommglobals

logmsg(['Communicating via ' Remote_Comm_dir]);

if nargin<1 || isempty(record)
    record.mouse = 'testmouse';
    record.experiment = '1820.fiberopto';
    record.epoch = 't00001';
    record.datatype = 'wc';
    record.date = datestr(now,'yyyy-mm-dd');
    record.setup = 'fiberopto';
end

% par = foprocessparams( record ); % to implement in the future
par.timeshift = 0.036; % calibrated on 2019-11-04 for NI USB-6001
par.upvoltage = 3.3;
par.samplerate = 1000; % Hz
par.optopulse_duration = 2;% s, optopulse duration in seconds
par.optopulse_frequency = 20; % Hz
par.stimduration = 0.5; % s
par.prestim = 1; % s
par.repeats = 2;
par.delay = 2; % s

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
    session = daq.createSession('ni');
catch me
    switch me.identifier
        case 'daq:general:unknownVendor'
            errormsg('No National Instrument available');
            return
    end
end


duration = (par.delay + par.repeats*(par.prestim+par.stimduration));


% Write acqParams_in
aqDat.name = 'eye';
aqDat.type = 'eyetrack';
aqDat.fname = 'eye';
aqDat.samp_dt = NaN;
aqDat.reps = ceil( duration/10); % 10s per rep
aqDat.ref = 1;
aqDat.ECGain = NaN;
writeAcqStruct(fullfile(datapath,'acqParams_in'),aqDat);
% wait to finish writing and write acqReady
pause(0.3);
write_pathfile(fullfile(Remote_Comm_dir,'acqReady'),localpath2remote(datapath));
pause(0.3);

session.Rate = par.samplerate;
session.NumberOfScans = duration * session.Rate; 
addAnalogOutputChannel(session,'Photometry', 'ao0', 'Voltage'); % optopulse
chao1 = addAnalogOutputChannel(session,'Photometry', 'ao1', 'Voltage'); % triggerpulse
chao1.Range = [-10 10];

addAnalogInputChannel(session,'Photometry', 0 , 'Voltage'); % photometry

% 1 Frequency pulse for duration
npulses = par.optopulse_duration * par.optopulse_frequency;
onepulse = zeros(round(par.samplerate / par.optopulse_frequency),1);
onepulse(1:round(par.samplerate / par.optopulse_frequency / 2)) = par.upvoltage;
optopulse = repmat(onepulse,npulses,1);
if length(optopulse)<1024 % minimally 1024 samples required
    optopulse(end+1:end) = 0;
end

% delay [prestim stimduration] x repeats 0 
delaypulse = zeros(par.samplerate*par.delay,1);
prestimpulse = zeros(par.samplerate*par.prestim,1);
stimpulse = par.upvoltage*ones(par.samplerate*par.stimduration,1);
optopulse = [delaypulse; repmat( [prestimpulse;stimpulse],par.repeats,1); 0];

triggerpulse = zeros(size(optopulse));
triggerpulse(1:100,1) = par.upvoltage; % trigger up samples

queueOutputData(session,[optopulse triggerpulse]);

plotData('reset',[]);

% for data acquisition
lh = addlistener(session,'DataAvailable', @plotData);

% add sometime for eyetracking computer to prepare
pause(5);

prepare(session);
logmsg('Starting acquisition');
startBackground(session);
logmsg(['Started optopulse and triggerpulse at ' datestr(now,'hh:mm:ss')]);
logmsg(['Session duration = ' num2str(duration) ]);

pause(duration);

logmsg(['Stopped optopulse and triggerpulse ' datestr(now,'hh:mm:ss')]);

record.measures.parameters = par;

wait(session);

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
    data = NaN(nbuffer,1);
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
    
%plot(event.TimeStamps, event.Data,'.-')
 plot(time,data(:,1));
 xlabel('Time (s)');
 ylabel('Voltage')
 xlim([max([0 time(counter-1)-2]) time(counter-1)]);


