function [data,t,discont,ncksmu] = get_data(cksmu, interval, warnon)

	if nargin<=2, warn = 0; else, warn = warnon; end;

	[data,dummy,discont] = get_data(cksmu.spikedata,interval,warn);

	data=cksmu.data(find(cksmu.data>=interval(1)&cksmu.data<=interval(2)));

	ncksmu = cksmu;
        t = data;
