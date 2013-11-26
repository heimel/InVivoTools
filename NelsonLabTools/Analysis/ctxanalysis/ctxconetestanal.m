function outstr = ctxconetestanal(tc,data,ssp)

%  CTXCENTSIZEANAL
%
%  ANALINFO = CTXCONETESTANAL(TUNING_CURVE,DATA,SSP)
%
%  Analyzes the results of presenting centersurround stimuli to an CTX cell.
%
%  Returns the following:
%    best center size *
%    the latency of the response  *
%    an index of transience  *
%    the initial and maintained response, with error  *
%    whether the maintained response is significant (sustained) *

c = getoutput(tc);

% find spontaneous rates
spikes=get_data(data,...
		[ssp.mti{1}.startStopTimes(1) ssp.mti{8}.startStopTimes(end)]);
% take intervals from adapting time
%inp.spikes=data;
for i=1:8,
	startTimes(i) = ssp.mti{i}.startStopTimes(1);
end;
%for i=1:8,
%	inp.triggers{i} = ssp.mti{i}.startStopTimes(1)+5+(0:0.1:10-0.1);
%end;
%inp.condnames={'Madapt','madapt','Sadapt','sadapt','Madapts','madapts',...
%		'Sadapts','sadapts'};
%pars = struct('res',0.010,'interval',[0 0.1],'cinterval',[0 0.1],...
%	'showcbars',1,'fracpsth',0.5,'normpsth',1,'showvar',0,'psthmode',0,...
%	'showfrac',1,'axessameheight',0);
%spontrast = raster(inp,pars,[]);
%spontc = getoutput(spontrast);
%global spontc,
%btsp = diff(spontc.bins{1}(1:2));
%is1=1;t1=spontc.bins{1}(is1);is2=length(spontc.bins{1});t2=spontc.bins{1}(is2);
%is1,is2,
%ls=length(inp.triggers{4}),
%for i=1:8,
%   size(inp.triggers{i}),
%   for j=1:ls,
%      spcounts(i,j)=sum(spontc.values{i}(is1:is2,j))/(btsp*(is2-is1+1));
%   end;
%end;
trigs=[];
for i=1:100,
		inter=5+(i-1)*0.100+[0 0.099999];  % 100ms intervals starting 5s in
	for j=1:8,
        spinter = startTimes(j)+inter;
		if j==4,trigs(end+1)=spinter(1);end;
		spcounts(j,i)=length(find(spikes>spinter(1)&spikes<spinter(2)))/0.1;
    end;
end;  % have to use identical method
%global trigs
stimcts = [];
c = getoutput(tc);
cr = getoutput(c.rast);
bt = diff(cr.bins{1}(1:2)),
l = size(cr.values{1},2);
i1=findclosest(cr.bins{1},0.020),     % assume all trials the same
i2=findclosest(cr.bins{1},0.120),
for i=1:8,
    for j=1:l,
		stimcts(i,j) = sum(cr.values{i}(i1:i2,j))/(bt*(i2-i1+1));
    end;
    [sigfiring(i),sig(i)]=ttest2(stimcts(i,:),spcounts(i,:),0.001,1);
end;

outstr.spontrates=[mean(spcounts')' std(spcounts')' std(spcounts')'/sqrt(100)];
outstr.stimrates=[mean(stimcts')' std(stimcts')' std(stimcts')'/sqrt(l)];
outstr.sigfiring=sigfiring;
outstr.sig = sig;

