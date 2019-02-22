function optoheartecgpupil( record)
%OPTOHEARTECGPUPIL starts ECG and sends trigger and turns on channel
%
% 2019, Alexander Heimel


remotecommglobals

if nargin<1 || isempty(record)
    
    record.mouse = 'testmouse';
    record.experiment = '1820.test';
    record.epoch = 't00001';
    record.datatype = 'wc';
    record.date = datestr(now,'yyyy-mm-dd');
    record.setup = 'tron';
end


par.upvoltage = 3.3;
par.inputsamplerate = 1000; % Hz
par.outputsamplerate = 1000; % Hz
%par.recording_duration = 5;% s, duration of recording
par.optopulse_duration = 2;% s, optopulse duration in seconds
par.optopulse_frequency = 20; % Hz


datapath = experimentpath(record,true,true,'2015t');
d = dir(datapath);
while length(d)>2 % not empty
    logmsg('Datapath exists. Increasing epoch number.');
    record.epoch = ['t' num2str(str2double(record.epoch(2:end))+1,'%05d')];
    datapath = experimentpath(record,true,true,'2015t');
    d = dir(datapath);
end



logmsg(['Writing data to ' datapath]);

out = daqhwinfo('mcc');
boardid = str2double(out.InstalledBoardIds{find(strcmp(out.BoardNames,'PCI-DAS6025'),1)});
if isempty(boardid)
    logmsg('Could not find PCI-DAS6025 board');
    return
end

% Write acqParams_in
aqDat.name = 'eye';
aqDat.type = 'eyetrack';
aqDat.fname = 'eye';
aqDat.samp_dt = NaN;
aqDat.reps = 1; % 10s per rep
aqDat.ref = 1;
aqDat.ECGain = NaN;
writeAcqStruct(fullfile(datapath,'acqParams_in'),aqDat);
pause(0.3);
write_pathfile(fullfile(Remote_Comm_dir,'acqReady'),localpath2remote(datapath));
pause(0.3);

input_arg.simulate = false;
ai = daq_parameters_mcc(input_arg); % get datapath from acqReady
ai.triggertype = 'manual';

ao = analogoutput('mcc',boardid);
set(ao,'SampleRate',par.outputsamplerate); % Hz
addchannel(ao,[0 1]); % opto, trigger

ao.Channel(1).ChannelName = 'Opto';


npulses = par.optopulse_duration * par.optopulse_frequency;
onepulse = zeros(round(par.outputsamplerate / par.optopulse_frequency),1);
onepulse(1:round(par.outputsamplerate / par.optopulse_frequency / 2)) = par.upvoltage;
optopulse = repmat(onepulse,npulses,1);
if length(optopulse)<1024 % minimally 1024 samples required
    optopulse(end+1:end) = 0;
end

ao.Channel(1).OutputRange = [-10 10];

ao.Channel(2).ChannelName = 'Trigger';
ao.Channel(2).OutputRange = [-10 10];

triggerpulse = zeros(size(optopulse));
triggerpulse(2:5,1) = par.upvoltage; % trigger up samples
putdata(ao,[optopulse triggerpulse]); % put on both channels



% add sometime for eyetracking computer to prepare
pause(10);

logmsg('Starting acquisition');
start(ai);
start(ao);
trigger(ai);
logmsg(['Started optopulse and triggerpulse at ' datestr(now,'hh:mm:ss')]);

pause(ai.SamplesPerTrigger/ai.SampleRate);
stop(ai);
stop(ao);

logmsg(['Stopped optopulse and triggerpulse ' datestr(now,'hh:mm:ss')]);
