function [rast,avg,stdev,stder] = fastrasterc(md,triggers,interval,norm)

% FASTRASTERC-Computes raster and signal average for triggered continuous data
% 
%  [RAST,AVG,STD,STDERR,RASTN]=FASTRASTERC(MEASUREDDATA,TRIGGERS,INTERVAL)
%
%  Computes a raster and psth for continuous data MEASUREDDATA object, triggered
%  on times listed in TRIGGERS in INTERVAL=[t0 t1] around this time.  Each row
%  of RAST contains a waveform for that trigger.  AVG is the signal average,
%  STD is the standard deviation, and STDERR is the standard error around the
%  signal average.  RASTN is a raster normalized by the first entry in each
%  row.
%
%  Note:  Despite its name, this function is actually very slow, and%
%  raster_continuous does the same thing and is much faster.

binlength = [];
for i=1:length(triggers),
	r = get_data(md,triggers(i)+interval)';
	if isempty(binlength),
		binlength=length(r)-1; % because sample sizes can vary by 1 due to round
		rast = zeros(length(triggers),binlength);
	end;
	if isempty(r),
		error(['No data for trigger number ' int2str(i) ...
				'(value ' num2str(triggers(i)) ').']);
	end;
	try,
		rast(i,:) = r(1:binlength);
	catch, error(['Error on trigger ' int2str(i) ': ' lasterr]);
	end;
	i,
end;
avg= mean(rast);
stdev=std(rast);
stder = stderr(rast);
