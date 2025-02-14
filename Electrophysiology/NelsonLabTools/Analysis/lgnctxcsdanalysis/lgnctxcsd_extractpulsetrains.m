function [triggers,pulsetimes, numpulses,n] = lgnctxcsd_extractpulsetrains(cksds,test,pulsedata)

% LGNCTXCSD_EXTRACTPULSES - Extracts pulse trains from pulse object
%
%  [TRIGGERS,PULSETIMES,NUMPULSES,N] = LGNCTXCSD_EXTRACTPULSETRAINS(CKSDS,...
%       TEST,PULSEDATA)
%
%  Extracts pulse train triggers for a two frequency pulse train electrical
%  stimulus.  In this stimulus, each trial involves two pulse trains of
%  different frequencies played one after the other.  There is at least a 10
%  second pause between each trial.  NUMPULSES is the number of pulses in
%  each trial, and N is the number of trials.  TRIGGERS is an NxNUMPULSES
%  matrix of the time of each pulse in the trains during each trial.  PULSETIMES
%  is the time of each pulse in the train relative to the first pulse in the
%  train.

sts=getstimscripttimestruct(cksds,test);

pulses=get_data(pulsedata,sts.mti{1}.startStopTimes([1 4]));

dp = find(diff([sts.mti{1}.startStopTimes(1) pulses])>9);

pulses = pulses(dp(1):end); % remove spurious pulses before 1st complete train
 % redo calculations
dp = find(diff([sts.mti{1}.startStopTimes(1) pulses])>9);
numpulses = dp(2)-dp(1);
n = floor(length(pulses)/numpulses);
if length(pulses)/numpulses==n, dp = [dp length(pulses)+1]; end;
triggers = zeros(n,numpulses);

for i=1:n,
   triggers(i,:) = pulses(dp(i):dp(i+1)-1);
end;
triggers,
if n==0, pulsetimes = []; else, pulsetimes=triggers(1,:)-triggers(1,1); end;
