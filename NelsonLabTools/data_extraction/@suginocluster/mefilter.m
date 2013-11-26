function [d] = winddiscfilter(me,data)

%  D = MEFILTER(ME, DATA)
%
%  Filters DATA according to the parameters of the MULTIEXTRACTOR ME, and
%  returns the filtered data in D.
%
%  See also:  MULTIEXTRACTOR

switch me.MEparams.filtermethod,
	case 0, % none.
		d = data;
	case 1, % convolution
		d = filterwaveform(data,struct('method','conv',...
			'B',me.MEparams.filterarg,'A',[]));
	case 2,
		argstr='';
		fa = me.MEparams.filterarg;
		if min(fa)==0,
			if max(fa)==Inf, d = data; return;
			else, argstr='low'; fa = max(fa); end;
		elseif max(fa)==Inf, argstr='high',fa=min(fa); end;
		if isempty(argstr), [b,a]=cheby1(4,0.8,fa,argstr);
		else, [b,a]=cheby1(4,0.8,fa,argstr); end;
		d=filterwaveform(data,struct('method','filtfilt','B',b,'A',a));
	otherwise, d = data;
end;

