function [d] = dotdiscfilter(dd,data)

%  DOTDISCFILTER Filters data according to parameters of dotdiscriminator.
%
%  D = DOTDISCFILTER(DD,DATA)
%
%  D is the filtered data, DD is the dot discriminator, and DATA is the 
%  data to be filtered.
%
%  See also:  DOTDISCRIMINATOR, WINDOWDISCRIMINATOR

if size(data,1)>size(data,2), data = data'; end;

nn_ = isnan(data);
nn = find(nn_);
if ~isempty(nn),
	if length(nn)==length(data), data = zeros(size(data)); % zero if all NaN
	elseif nn(1)==1, % if first entry is NaN, need to handle special case
		nnn = find(1-nn_);
		data(1:(nnn(1)-1)) = data(nnn(1));
		nn = find(isnan(data));
	end;
	if length(nn)~=length(data),
		nnd = [ 1 find(diff(nn)>1)+1 length(nn)+1];
		for i=1:length(nnd)-1,
			data(nn(nnd(i)):nn(nnd(i+1)-1)) = data(nn(nnd(i))-1);
		end;
	end;
end;

disp(['filter method is ' int2str(dd.DDparams.filtermethod) '.']);

switch dd.DDparams.filtermethod,
	case 0, % none.
		d = data;
	case 1, % convolution
		d = filterwaveform(data,struct('method','conv',...
			'B',dd.DDparams.filterarg,'A',[]));
	case 2,
		argstr='';
		fa = dd.DDparams.filterarg;
		if min(fa)==0,
			if max(fa)==Inf, d = data; return;
			else, argstr='low'; fa = max(fa); end;
		elseif max(fa)==Inf, argstr='high',fa=min(fa); end;
		if isempty(argstr), [b,a]=cheby1(4,0.8,fa);
		else, [b,a]=cheby1(4,0.8,fa,argstr); end;
                disp(['filtering...']);
		d=filterwaveform(data,struct('method','filtfilt','B',b,'A',a));
				disp(['done']);
	otherwise, d = data;
end;

