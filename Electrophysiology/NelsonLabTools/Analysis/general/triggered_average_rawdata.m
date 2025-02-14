function [meanwaves,sampletimes,stdwaves,indwaves]=triggered_average_rawdata(...
    cksmeasobj,trigs,t0,t1,sampmult)
%TRIGGERED_AVERAGE_RAWDATA computes triggered average of rawdata
%
%   [MEANWAVES,SAMPLETIMES,STDWAVES]=TRIGGERED_AVERAGE_RAWDATA( ...
%                   CKSMEASOBJ,TRIGS,T0,T1,SAMPMULT)
%
%          computes average of rawdata contained in the
%          cksmeasureddata-object CKSMEASOBJ in the interval [T0 T1]
%          around the times contained in TRIGS, skipping every SAMPMULT-1
%          samples.
%          MEANWAVES contains this average
%          SAMPLETIMES contains the exact time
%          STDWAVES contains standard deviation of wavws
%          if STDWAVES is not required, then it will not be calculated
%
%          2003, Alexander Heimel
%          Adapted from LGNCTXCSD_PULSE_FIELD of Stephen Van Hooser

sampletimes = []; dt = [];

% cut total data into 30s segments
segs = (trigs(1)+t0):30:(trigs(end)+t1);

no_std=0;comp_ind_waves=0;

if nargout<3 no_std=1; end
if nargout==4, comp_ind_waves=1; ind_waves = []; end;

for k=1:length(segs)-1,
  z = find(trigs>=segs(k)&trigs<segs(k+1));
  if ~isempty(z),
    [data,tt]=get_data(cksmeasobj,[trigs(z(1))+t0 trigs(z(end))+t1+0.1]);
    data=data(1:sampmult:end); 
    tt=tt(1:sampmult:end);
    if isempty(sampletimes) % at first pass
      dt=tt(2)-tt(1);
      sampletimes=t0:dt:t1;
      wave=zeros(1,length(sampletimes)); 
      meanwaves=zeros(1,length(sampletimes)); 
      stdwaves=zeros(1,length(sampletimes)); 
    end;
    si=1+round((trigs(z)-tt(1)+t0)/dt);
    meanwaves=meanwaves+contsumwaveshelper(data,si,...
				   ones(1,length(z)),1,length(sampletimes));
    if ~no_std
      % if no standard deviation is required,
      % don't bother to calculate it
      stdwaves=stdwaves+contsquarewaveshelper(data,si,...
			      ones(1,length(z)),1, ...
			      length(sampletimes));
    end
	if comp_ind_waves,
	  ind_wavs=cat(1,ind_waves,conttriggerhelper(data,si,length(sampletimes)));
	end;
  end;
end;

meanwaves = meanwaves/length(trigs);
if ~no_std
  stdwaves=stdwaves/length(trigs);
  stdwaves=sqrt(stdwaves-meanwaves.^2);
end
