function record = host_start_epoch( record, duration )
%HOST_START_EPOCH writes acqReady and acqParams file and triggers trial start
%
% RECORD =  HOST_START_EPOCH( RECORD, DURATION=10)
%
%   Optional DURATION in seconds, to be written in acqParams_in
% 
% 2019, Alexander Heimel
%

NewStimGlobals;
remotecommglobals;
StimSerialGlobals;

if nargin< 2 || isempty(duration)
    duration = 3; % s
end
if nargin<1 || isempty(record)
    record.mouse = 'testmouse';
    record.experiment = '1920test';
    record.epoch = 't00001';
    record.datatype = 'wc';
    record.date = datestr(now,'yyyy-mm-dd');
    record.setup = host;
end

logmsg('Set params.experimentpath_localroot in processparam_local.m for place to store data');
logmsg(['Communicating via ' Remote_Comm_dir]);
logmsg('Change Remote_Comm_dir in NewStimConfiguration to change communication folder.');
logmsg('Set trigger settings in NewStimConfiguration');

if NSUseInitialSerialTrigger
    try
       serial_out = serial(StimSerialScriptOut);
    catch
        logmsg(['Cannot find ' StimSerialScriptOut '. Check StimSerialScriptOut settings in NewStimConfiguration']);
        return
    end
end
fopen(serial_out);
set(serial_out,'dataterminalready','on');
set(serial_out,'requesttosend','on');

params.delay_for_remote_computers = 2; % s
params = processparams_local(params); 
logmsg(['Using ' num2str(params.delay_for_remote_computers) ' s delay for communication. Set params.delay_for_remote_computers in processparams_local.m']);

[datapath,record] = find_unique_epochpath(record);
if ~exist(datapath,'dir')
  if isoctave
    system(['mkdir -p ' datapath]);
  else
    mkdir(datapath)
  end
end
if ~exist(datapath,'dir')
  logmsg(['Unable to create folder ' datapath]);
end

% Write acqParams_in
aqDat.name = record.setup;
aqDat.type = record.datatype;
aqDat.fname = record.epoch;
aqDat.samp_dt = NaN;
aqDat.reps = ceil( (duration+1)/10); % 10s per rep, added communication delay
aqDat.ref = 1;
aqDat.ECGain = NaN;
writeAcqStruct(fullfile(datapath,'acqParams_in'),aqDat);

acqduration = aqDat.reps*10; % s 

% wait to finish writing and write acqReady
pause(0.3);
write_pathfile(fullfile(Remote_Comm_dir,'acqReady'),localpath2remote(datapath));

% wait to let remote computers find acqReady
pause(params.delay_for_remote_computers);

if NSUseInitialSerialTrigger && StimSerialSerialPort
    switch(StimSerialScriptOutPin)
       case 'dtr'
          outpin = 'dataterminalready';
       case 'rts'
          outpin = 'requesttosend';
    end
    set(serial_out,outpin,'off');
    %StimSerial(StimSerialScriptOutPin,StimSerialScript,0);
    if exist('NSUseInitialSerialContinuous','var') && ~isempty(NSUseInitialSerialContinuous) && NSUseInitialSerialContinuous
        logmsg([ StimSerialScriptOutPin ' pin flipped down for whole script']);
    else
        WaitSecs(0.010);
        set(serial_out,outpin,'on');
        %StimSerial(StimSerialScriptOutPin,StimSerialScript,1);
        logmsg(['Triggered on pin ' StimSerialScriptOutPin ' of ' StimSerialScriptOut]);
    end
end

logmsg(['Started epoch ' record.epoch ' for ' num2str(acqduration) ' s.' ]);
WaitSecs(acqduration);
logmsg(['Finished epoch '  record.epoch]);

if NSUseInitialSerialTrigger && StimSerialSerialPort
    set(serial_out,outpin,'on');
    %    StimSerial(StimSerialScriptOutPin,StimSerialScript,1);
end

params.wc_postrecording_delay = 12;%s
logmsg(['Safety post recording delay ' num2str(params.wc_postrecording_delay)]);
WaitSecs(params.wc_postrecording_delay);

fclose(serial_out);

