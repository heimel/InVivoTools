function [d] = winddiscfilter(wd,data)

%  D = WINDDISCFILTER
%
%  Filters the data according to the parameters of the windowdiscriminator WD.
%
%  See also:  WINDOWDISCRIMINATOR

disp(['filter method is ' int2str(wd.WDparams.filtermethod) '.']);

switch wd.WDparams.filtermethod,
	case 0, % none.
		d = data;
	case 1, % convolution
		d = filterwaveform(data,struct('method','conv',...
			'B',wd.WDparams.filterarg,'A',[]));
	case 2,
		argstr='';
		fa = wd.WDparams.filterarg;
		if min(fa)==0,
			if max(fa)==Inf, d = data; return;
			else, argstr='low'; fa = max(fa); end;
		elseif max(fa)==Inf, argstr='high',fa=min(fa); end;
		if isempty(argstr), [b,a]=cheby1(4,0.8,fa);
		else, [b,a]=cheby1(4,0.8,fa,argstr); end;
                disp(['filtering...']);
		d=filterwaveform(data,struct('method','filtfilt','B',b,'A',a));
	otherwise, d = data;
end;

