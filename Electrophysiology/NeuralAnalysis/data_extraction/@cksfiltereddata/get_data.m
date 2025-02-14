function [filtereddata,T,discont,ncksfd] = get_data(cksfd,interval,warnon)

% GET_DATA reads data from a cksfiltereddata object.
%
%  [FILTEREDDATA,T,DISCONT,NCKSFD]=GET_DATA(MYCKSFD,INTERVAL,WARNON)
%
%  Reads data from INTERVAL(1) to INTERVAL(2) from the CKSFILTEREDDATA object
%  MYCKSFD.  The data are then filtered according to the filter parameters
%  of MYCKSFD.  To reduce effects of windowing, extra data is read in (if possible)
%  before filtering, but only data in the requested interval is returned.  If there
%  is a discontinuity in the data (because data was not continusouly recorded in the
%  intervals above) then no extra data is read in.
%
%  If WARNON is 0, then an error message is given if the user attempts to read
%  data during an interval when no data was recorded.  If WARNON is 1, a warning 
%  is given under this circumstance.  If WARNON is 2, then no error or warning is
%  given and as much data as possible is returned.  T is the time of each sample.
%  DISCONT is 1 if there is a discontinuity in the data.


if nargin==2, warn = []; else, warn = warnon; end;

  % OFFSET - time before and after each interval to try to read to offset
  % edge effects of filtering
maxoffset = 0.2;

all_ints = get_intervals(cksfd); % get all intervals
int1in=-1;int2in=-1;
for i=1:length(all_ints),
	if interval(1)>=all_ints(i,1)&interval(1)<=all_ints(i,2), int1in=i; end;
	if interval(2)>=all_ints(i,1)&interval(2)<=all_ints(i,2), int2in=i; end;
end;

[data,T,discont,ncskfd] = get_data_par(cksfd,interval,warn);

minbefore = max([all_ints(int1in,1) interval(1)-maxoffset]);
maxafter = min([all_ints(int2in,2) interval(2)+maxoffset]);

if minbefore==interval(1), % then interval(1) is already at beg edge, don't add
	databefore=[];discontbefore = 0;Tbefore=[];
else,
	[databefore,Tbefore,discontbefore] = get_data_par(cksfd,[minbefore interval(1)],2);
end;
if maxafter==interval(2), % then interval(2) is already at end edge, don't add
	dataafter = [];discontafter =0;Tafter=[];
else,
	[dataafter,Tafter,discontafter] = get_data_par(cksfd,[interval(2) maxafter],2);
end;

if discontbefore, databefore=[];Tbefore=[];end;  %if there's a discontinuity, don't bother fixing edges
if discontafter, dataafter=[];Tafter=[];end;    %if there's a discontinuity, don't bother fixing edges

szbefore = length(databefore);
szafter = length(dataafter);
szdata = length(data);

switch cksfd.filtermethod,
case 0,
	filtereddata = data;
case 1,
	filtereddata = filterwaveform([databefore;data;dataafter;],struct('method','conv',...
				'B',cksdf.filterarg,'A',[]));
case 2,
	skip = 0;
	fa = cksfd.filterarg;
	if min(fa)==0,
		if max(fa)==Inf, filterddata = data; skip =1 ; % nothing to do
		else, argstr = 'low'; fa = max(fa); end;
	elseif max(fa)==Inf, argstr = 'high'; fa=min(fa); end;
	if isempty(argstr),[b,a]=cheby1(4,0.8,fa);
	else, [b,a]=cheby1(4,0.8,fa,argstr); end;
	filtereddata = filterwaveform([databefore;data;dataafter],struct('method','filtfilt','B',b,'A',a));
case 3,
	% filterarg = {t0,t1,spiketimes}
	t0=cksfd.filterarg.t0; t1=cksfd.filterarg.t1;
	spiketimes=cksfd.filterarg.spiketimes(find(cksfd.filterarg.spiketimes>interval(1)-(t0+t1)&...
			cksfd.filterarg.spiketimes<interval(2)+(t0+t1))); % assume t0+t1<maxoffset
	Tt = [Tbefore;T;Tafter]; d = [databefore;data;dataafter];
	if ~isempty(Tt), T_=Tt-Tt(1); dt=diff(T_([1 2])); else, T_ = []; dt = []; end;
	if ~isempty(spiketimes), S_ = spiketimes-Tt(1); else, S_ = []; end;
	%t0s=(t0/dt); t1s=(t1/dt); sample widths
	%t0s,t1s,dt, % for debugging
	for i=1:length(S_),
		bk=max([1 round((S_(i)-t0+dt)/dt)]);
		fw=min([round((S_(i)+t1+dt)/dt) floor(T_(end)/dt)]);
		d(bk:fw) = d(bk)+diff(d([bk fw]))/(fw-bk+1)*(1:fw-bk+1);
	end;
	filtereddata = d;
otherwise, filtereddata = data;
end;

filtereddata = filtereddata( (szbefore+1):(szdata+szbefore) );
