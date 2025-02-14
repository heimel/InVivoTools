function [indwaves,meanwaves,stdwaves,sampletimes]=raster_continuous(...
    cksmeasobj,trigs,t0,t1,timeres)
%RASTER_CONTINUOUS computes raster,triggered average,std.dev. of continuous data
%
%   [INDWAVE,MEANWAVES,STDWAVES,SAMPLETIMES]=RASTER_CONTINUOUS( ...
%                   CKSMEASOBJ,TRIGS,T0,T1,TIMERES)
%
%          computes average of rawdata contained in the
%          cksmeasureddata-object CKSMEASOBJ in the interval [T0 T1]
%          around the times contained in TRIGS, realigned to samples at
%          TIMERES resolution (e.g., 0.001 s).
%          MEANWAVES contains this average
%          SAMPLETIMES contains the exact time of each sample
%          STDWAVES contains standard deviation of wavws
%          if STDWAVES is not required, then it will not be calculated
%
%          TRIGS are assumed to be sorted in ascending order.
%
%          2003, Alexander Heimel and Steve Van Hooser

sampletimes = []; dt = [];

% cut total data into 30s segments
segs = (trigs(1)+t0):30:(trigs(end)+t1);
segs(end) = trigs(end)+t1;

indwaves=[];

for k=1:length(segs)-1,
  z = find(trigs>=segs(k)&trigs<segs(k+1));
  if ~isempty(z),
    [data,tt]=get_data(cksmeasobj,[trigs(z(1))+t0 trigs(z(end))+t1+0.1]);
	tnew = tt(1):timeres:tt(end);
    data=interp1(tt,data,tnew,'nearest');
    if isempty(sampletimes) % at first pass
      dt=tnew(2)-tnew(1);
      sampletimes=t0:timeres:t1;
      meanwaves=zeros(1,length(sampletimes)); 
      stdwaves=zeros(1,length(sampletimes)); 
    end;
    si=1+round((trigs(z)-tnew(1)+t0)/dt);
    +(t0:timeres:t1);meanwaves=meanwaves+contsumwaveshelper(data,si,...
				   ones(1,length(z)),1,length(sampletimes));
    stdwaves=stdwaves+contsquarewaveshelper(data,si,...
			      ones(1,length(z)),1, ...
			      length(sampletimes));
	indwaves=cat(1,indwaves,conttriggerhelper(data,si,length(sampletimes)));
  end;
end;

meanwaves = meanwaves/length(trigs);
stdwaves=stdwaves/length(trigs);
stdwaves=sqrt(stdwaves-meanwaves.^2);
