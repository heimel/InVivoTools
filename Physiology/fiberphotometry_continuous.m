function record = fiberphotometry_continuous( record)
%FIBERPHOTOMETRY starts fiberoptometry and sends trigger at start
%
%  RECORD = FIBERPHOTOMETRY( RECORD, VERBOSE )
%
% 2019, Alexander Heimel

if nargin<1 || isempty(record)
    
    % h = getwctestdbwindow
    
    record.mouse = 'test';
    record.date = datestr(now,'yyyy-mm-dd');
    record.experiment = '1820.fiberphoto';
    record.setup = 'fiberphoto';
    record.datatype = 'wc';
    record.epoch = 't00001';
    record.experimenter = 'ma';
    record.comment = 'GCaMP6s_flex_AAV9 in ZI Left';
    record.measures = [];
end

logmsg('Set params.experimentpath_localroot in processparam_local.m for place to store data');


remotecommglobals

logmsg(['Communicating via ' Remote_Comm_dir]);


% par = fpprocessparams( record ); % to implement in the future
par.timeshift = 0.036; % calibrated on 2019-11-04 for NI USB-6001
par.voltage_high = 3.3; % V
par.voltage_low = 0; % V
par.min_pulsesamples = 1024; % for some NI board
par.sample_rate = 100; % Hz

triggerpulse = par.voltage_low * ones(5000,1);
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
aqDat.reps = NaN; %ceil( duration/10); % 10s per rep
aqDat.ref = 1;
aqDat.ECGain = NaN;
writeAcqStruct(fullfile(datapath,'acqParams_in'),aqDat);
% wait to finish writing and write acqReady
pause(0.3);
write_pathfile(fullfile(Remote_Comm_dir,'acqReady'),localpath2remote(datapath));

queuedata('reset');
plotData('reset',[]);

session.Rate = par.sample_rate;
addAnalogOutputChannel(session,'Photometry', 'ao1', 'Voltage'); % triggerpulse
addAnalogInputChannel(session,'Photometry', 0 , 'Voltage'); % photometry
addAnalogInputChannel(session,'Photometry', 1 , 'Voltage'); % measuring optopulse from raspipi
%queueOutputData(session,triggerpulse);
queuedata(session);

lhoutput = addlistener(session,'DataRequired', @queuedata);

figure
lh = addlistener(session,'DataAvailable', @plotData);
session.IsContinuous = true;
prepare(session);

pause(2); % add some time for other computers to prepare
startBackground(session);
logmsg(['Started continuous recording and sent triggerpulse at ' datestr(now,'hh:mm:ss')]);
logmsg('Hold q to quit');
while 1
    [keyIsDown,~,keyCode] = KbCheck;
    if keyIsDown && any(find(keyCode)==81) % q
        break
    end
    pause(0.05);
end

stop(session);
%wait(session);


logmsg(['Stopped recording ' datestr(now,'hh:mm:ss')]);
delete(lh);
delete(lhoutput);
clear session



% send a stopping trigger
logmsg('Sending stop trigger');
send_trigger();

logmsg('Giving raspberry pi 7 seconds to stop recording.');
pause(7);

record.measures.parameters = par;
[data,time] = plotData('retrieve',[]);
time = time + par.timeshift; % to match calibration


save(fullfile(datapath,'fiberphotometry.mat'),'time','data','par');
save(fullfile(datapath,'record.mat'),'record','-mat');

figure('Name',recordfilter(record));
plot(time,data);
hold on
plot(time,smoothen(data(:,1),5)); % plot fiber data
xlabel('Time (s)');
ylabel('Voltage')

ind = find(isnan(data(:,1)),1,'first');

figure;
pwelch(data(1:min([ind-1 10000 end]),1),[],[],[],par.sample_rate)

function send_trigger()
par.voltage_high = 3.3; % V
par.voltage_low = 0; % V
par.min_pulsesamples = 1024; % for some NI board
par.sample_rate = 1024; % Hz
session = daq.createSession('ni'); % National Instruments USB-6001
session.Rate = par.sample_rate;
addAnalogOutputChannel(session,'Photometry', 'ao1', 'Voltage'); 
triggerpulse = [ par.voltage_high * ones(round(session.Rate*0.5),1)]; % half a second
triggerpulse = [triggerpulse; par.voltage_low * ones(2*par.min_pulsesamples,1)];
queueOutputData(session,triggerpulse);
startForeground(session);
logmsg('Sent trigger');
stop(session);
clear session

function queuedata(src,event) %#ok<INUSD>
persistent data

if ischar(src)
    switch src
        case 'reset'
            data = [];
            return
    end
end
if isempty(data)
    disp('PULSSSSSSSSSSSSSSSSSSSSSSSSSSSSS');
    data = 0 * ones(5000,1);
    data(1:100,1) = 3.3;
    %    data(1:1000,1) = 3.3;
else
    disp('NOOOOOOOOOOPULLLLLLS');
    data = 0 * ones(5000,1);
end
src.queueOutputData(data);

function [outdata,outtime] = plotData(src,event)
persistent data time counter ymin ymax

n_channels = 2;

outdata = [];
outtime = [];
nbuffer = 1000000;


if ischar(src)
    switch src
        case 'reset'
            data = [];
            ymax =  -inf;
            ymin =  inf;
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

ymax = max([ymax max(data(counter:counter+n-1,1))*1.1]);
ymin = min([ymin min(data(counter:counter+n-1,1))/1.1]);

counter = counter + n;
if counter+n > nbuffer
    counter = 1;
end



plot(time,data(:,1)); % plot fiber data

xlabel('Time (s)');
ylabel('Voltage')


ylim([ymin ymax]);
xlim([max([0 time(counter-1)-20]) time(counter-1)]);


function h = getwctestdbwindow
% gets open testdbwindow
children = get(0,'children');
h = [];
c = 1;
while isempty(h) && c<=length(children)
    if ~isempty(strfind(get(children(c),'Name'),'Wc database'))
        h = children(c);
    end
    c = c + 1;
end

