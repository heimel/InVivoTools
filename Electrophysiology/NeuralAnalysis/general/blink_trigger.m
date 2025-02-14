function [meanwaves, T] = blink_trigger(md,blinkstim,mti,t0,t1,sampmult)

% BLINK_TRIGGER Compute mean waveforms triggered off a blinkingstim
% 
% [MEANWAVE,T]=blink_trigger(MD,BLINKSTIM,MTI,t0,t1,SAMPMULT)
%
%  Computes mean waveforms following presentation of frames of a blinkingstim
%  in the interval [t0 t1] around each frame.  BLINKSTIM is the blinkingstim
%  that was shown, and MTI is a MTI stimulus record from the stimulus
%  presentation.  T is time samples for MEANWAVE with respect to the trigger
%  time.  SAMPMULT is the factor by which to reduce sampling; e.g., SAMPMULT=10
%  reduces the samples by a factor of 10.  SAMPMULT must be an integer.
%
%  See also:  BLINKINGSTIM, DISPLAYSTIMSCRIPT

if nargin==3, doindwaves=1; else, doindwaves=0; end;

%[data,t] = get_data(md,[mti.startStopTimes(1),mti.startStopTimes(4)+t1]);

segs = (mti.frameTimes(1)+t0):30:(mti.frameTimes(end)+t1);

dt = [];
 % assume constant sampling rate

blinkList = getgridorder(blinkstim);
nreps = length(find(blinkList==1));

for k=1:length(segs)-1,
  z = find(mti.frameTimes>=segs(k)&mti.frameTimes<=segs(k+1));
  [datam,tt]=get_data(md,[mti.frameTimes(z(1))+t0 mti.frameTimes(z(end))+t1+0.1]);
  datam = datam(1:sampmult:end); tt = tt(1:sampmult:end);
  if isempty(dt),  % initialize variables
	dt=tt(2)-tt(1); T=t0:dt:t1; % assume constant sampling rate
	meanwaves = zeros(length(blinkList)/nreps,length(T));
  end;
%  for m=1:length(z),
%    n = blinkList(z(m));
%	si = 1+round((mti.frameTimes(z(m))-tt(1)+t0)/dt);
%	meanwaves(n,:) = meanwaves(n,:)+datam(si:si+length(T)-1)';
%  end;
  meanwaves = meanwaves+ contsumwaveshelper(datam,1+round((mti.frameTimes(z)-tt(1)+t0)/dt),...
          blinkList(z),length(blinkList)/nreps,length(T));
end;
%  for n=1:length(blinkList)/nreps,  % number of grid locations
%  	  n,
%    trigs = mti.frameTimes(find(blinkList==n));
%    for jj=1:length(trigs),
%  	  si = 1+round((trigs(jj)-t(1)+t0)/dt);
%	  meanwaves(n,:) = meanwaves(n,:)+data(si:si+length(T)-1)';
%    end;
%  end;
meanwaves=meanwaves/nreps;
%stddevwaves=[];
%meanwaves=reshape(mean(indwaves,2),length(blinkList)/nreps,length(T));
%stddevwaves=reshape(std(indwaves,2),length(blinkList)/nreps,length(T));
