function [rast,avg,stddev,stderror,thespikes,rastn]=spiketriggeredaverage(md,spikedat,interval,tests)

% SPIKETRIGGEREDAVERAGE-Compute STA of continuous data based on spikes
%
%  [RAST,AVG,STD,STDERR]=spiketriggeredaverage(MD,SPIKEDAT,INTERVAL,NUMTRIGGERS)
%
% Computes the spike-triggered-average (STA) of continuous MEASUREDDATA object
% MD based on spikes of SPIKEDAT, a SPIKEDATA object.  The STA is computed
% over the interval [t0 t1] around each spike of SPIKEDAT.  The STA is computed
% using at most NUMTRIGGERS.

thespikes = [];
theints = get_intervals(md);
rast=[]; rastn=[]; rastct = 1;
sp = [];
for i=tests,
	sp = [sp get_data(spikedat,...
			[theints(i,1)-interval(1) theints(i,2)-interval(2)])];
end; % so we can make one big rast later
	
for i=tests,
	newspikes=get_data(spikedat,...
			[theints(i,1)-interval(1) theints(i,2)-interval(2)]);
	if ~isempty(newspikes),
		[int_data,t0] = get_data(md,[theints(i,1) theints(i,2)]);
		int_data = single(int_data);
		ns = newspikes-theints(i,1);
		dt = diff(t0([1 2])); % get sampling rate
		clear t0;
		t0s = round(interval(1)/dt); t1s = round(interval(2)/dt);
		samps = t0s:t1s; samp0 = find(samps==0);
		for j=1:length(ns),
			if isempty(rast),
				rast = zeros(length(sp),length(samps));
				rastn = zeros(length(sp),length(samps));
			end;
			rast(rastct,:) = int_data( round(ns(j)/dt) + samps)';
			rastct = rastct + 1,
		end;
		clear int_data;
	end;
	thespikes=[thespikes newspikes];
end;

avg = mean(rast); stddev = std(rast); stderror=stderr(rast);
%thespikes = thespikes([1:245 247:length(thespikes)]);

%[rast,avg,std,stderr,rastn]=fastrasterc(md,thespikes(1:5:end-10),interval);
