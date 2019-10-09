function record = fiberphotometry( record,verbose)
%FIBERPHOTOMETRY starts fiberoptometry and sends trigger at start
%
%  RECORD = FIBERPHOTOMETRY( RECORD )
%
% 2019, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = true;
end

logmsg('Set params.experimentpath_localroot in processparam_local.m for place to store data');

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
par.voltage_high = 3.3; % V
par.voltage_low = 0; % V
par.min_pulsesamples = 1024; % for some NI board
par.sample_rate = 1000; % Hz
par.optopulse_duration = 2;% s, optopulse duration in seconds
par.optopulse_frequency = 20; % Hz
par.preoptopulse_duration = 1; % s
par.postoptopulse_duration = 5; % s
par.optopulse_repeats = 1;
par.delay_duration = 2; % s
% delay [preoptopulse optopulse postoptopulse] x optopulse_repeats

% create pulses
[optopulse,time] = optopulsetrain(par.sample_rate,par.delay_duration,par.preoptopulse_duration,...
    par.optopulse_duration,par.postoptopulse_duration,par.optopulse_frequency,...
    par.optopulse_repeats,par.voltage_high,par.voltage_low,par.min_pulsesamples );
triggerpulse = par.voltage_low * ones(size(optopulse));
triggerpulse(1:round(par.sample_rate *0.1),1) = par.voltage_high; % trigger up samples
duration = max(time);

verbose = false;
if verbose
    figure
    plot(time,optopulse);
    hold on
    plot(time,triggerpulse);
    xlabel('Time (s)');
    ylabel('Pulse (V)');
end

try
    session = daq.createSession('ni'); % National Instruments USB-6001
catch me
    switch me.identifier
        case 'daq:general:unknownVendor'
            errormsg('No National Instrument board available');
            return
    end
end

[datapath,record] = find_unique_epochpath(record);

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
addAnalogOutputChannel(session,'Photometry', 'ao0', 'Voltage'); % optopulse
chao1 = addAnalogOutputChannel(session,'Photometry', 'ao1', 'Voltage'); % triggerpulse
chao1.Range = [-10 10];
addAnalogInputChannel(session,'Photometry', 0 , 'Voltage'); % photometry
addAnalogInputChannel(session,'Photometry', 1 , 'Voltage'); % measuring optopulse from raspipi
queueOutputData(session,[optopulse triggerpulse]);
figure
plotData('reset',[]);
lh = addlistener(session,'DataAvailable', @plotData);

prepare(session);

pause(2); % add some time for other computers to prepare
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
hold on
plot(time,data(:,1));
plot(time,data(:,2));
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

        plot(time,data(:,1));
hold on
        plot(time,data(:,2));
xlabel('Time (s)');
ylabel('Voltage')
xlim([max([0 time(counter-1)-2]) time(counter-1)]);


