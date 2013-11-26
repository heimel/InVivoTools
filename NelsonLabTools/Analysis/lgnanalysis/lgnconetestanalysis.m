function [newcell,outstr,assoc,ra]=lgnconetestanalysis(cksds,cell,...
		cellname,display)

%  LGNCONETESTANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,RA]=LGNCONETESTANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the cone test.  CKSDS is a valid CKSDIRSTRUCT experiment, 
%  CELL is a SPIKEDATA object, CELLNAME is a string containing the name of the
%  cell, and DISPLAY is 0/1 depending upon whether or not output should be
%  displayed graphically.
%
%  This function analyzes two versions of the cone test stimuli.
%  One just runs the cone test, and the other runs 40 trials of center
%  stimulation with either black or white (whatever was optimal for the cell).
%
%  
%
%  Measures gathered from the Cent Size test (associate name in quotes):
%  'Color spont rates'            |   Spontaneous rate for all eight cases
%  'Color stim rates '            |   Firing rate during [0.020 0.120] for 8
%  'Color significant firing'     |   0/1's whether firing was significant
%  'Center Initial Response imp'  | Initial response to center stimulus (50ms)
%  'Center Maintained Response imp'| Response 300-350 ms later
%  'Phasic-Tonic index'           | Phasic-tonic index
%  'Peak latency'                 | Measure of latency at peak firing rate
%  'Peak firing rate'             | Firing rate at peak latency
%  'Spike density'                | Firing during interval [20ms...170ms]

newcell = cell;

%some parameters
Int0 = 0.010;
Int1 = 0.110;  % if change from 100ms, need to adjust spont calc below
p_val = 0.01;   % p value for significant differences in means in t-test
spInt0=0.020;spInt1=0.170;% spike density intervals
spikethresh =6; % firing rate above background for statistical significance
Int00= 0;
Int01= 0.500;
spikethresh0=4;

% adding measures: PTIle, PTIme, PTIlm, l=late, m=middle, e=early
eb = 0.010; ee = 0.110;
mb = 0.200; me = 0.300;
lb = 0.400; le = 0.500;

 % first, disassociate any 'cent size' measures associated with this cell
assoclist = lgnassociatelist('ConeTest');

for I=1:length(assoclist),
  [as,i] = findassociate(newcell,assoclist{I},'protocol_LGN',[]);
  if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

if display,
	h0 = figure;
	wherecn.figure=h0;wherecn.rect=[0.05 0.45 0.90 0.5];
	wherecn.units='normalized';
	wherecs=wherecn;wherecs.rect=[0.05 0.05 0.90 0.35];
else, wherecn = []; wherecs = [];
end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

spontrates = []; stimrates = []; sigfiring=[]; sig = [];
centExtra = []; mticE = [];  genconetest=0; startTimes = [];

% first perform cone analysis
cntest = findassociate(newcell,'Cone test','protocol_LGN',[]);
if ~isempty(cntest), % if there is no cone test, continue to center analysis
	s = getstimscripttimestruct(cksds,cntest.data);
	if ~isempty(s),  % decompose script into its original stimuli
		if length(s.mti)>88, % then there is a center part, too
			[centExtra,rest,mticE,mtir]=DecomposeScriptMTI(s.stimscript,...
				s.mti,[1]);
			genconetest=2;
		else, rest = s.stimscript; mtir=s.mti; genconetest = 1;
		end;
		[Madapt,rest,mtiMa,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[Mcent,rest,mtiMc,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[madapt,rest,mtima,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[mcent,rest,mtimc,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[Sadapt,rest,mtiSa,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[Scent,rest,mtiSc,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[sadapt,rest,mtisa,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[scent,rest,mtisc,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[Madapts,rest,mtiMas,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[Msurr,rest,mtiMs,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[madapts,rest,mtimas,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[msurr,rest,mtims,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[Sadapts,rest,mtiSas,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[Ssurr,rest,mtiSs,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[sadapts,ssurr,mtisas,mtiss]=DecomposeScriptMTI(rest,mtir,1);
		inp.triggers= { gettrigs(mtiMc) gettrigs(mtimc) gettrigs(mtiSc) ...
					gettrigs(mtisc) gettrigs(mtiMs) gettrigs(mtims) ...
					gettrigs(mtiSs) gettrigs(mtiss) };
		inp.condnames = {'m+ cent' 'm- cent' 's+ cent' 's- cent' ...
					'm+ surr' 'm- surr' 's+ surr' 's- surr'};
		inp.spikes = newcell;
        parms=struct('res',1e-2,'interval',[-0.5 0.5],'fracpsth',0.5,...
			'normpsth',1,'showvar',0,'psthmode',0,'showfrac',1,...
			'cinterval',[0 0.5],'showcbars',1,'axessameheight',1);
		ra = raster(inp,parms,wherecn);

		% get starting times for adapting stimuli
		startTimes(1) = mtiMa{1}.startStopTimes(1);
		startTimes(2) = mtima{1}.startStopTimes(1);
		startTimes(3) = mtiSa{1}.startStopTimes(1);
		startTimes(4) = mtisa{1}.startStopTimes(1);
		startTimes(5) = mtiMas{1}.startStopTimes(1);
		startTimes(6) = mtimas{1}.startStopTimes(1);
		startTimes(7) = mtiSas{1}.startStopTimes(1);
		startTimes(8) = mtisas{1}.startStopTimes(1);
        % compute spontaneous rate during last 10s of adapting stimuli
		spikes=get_data(cell,[startTimes(1) mtisas{1}.startStopTimes(end)]);
		spcounts=[];
		for i=1:100,
        	inter=5+(i-1)*0.100+[0 0.099999];  % 100ms intervals starting 5s in
		    for j=1:8,
		        spinter = startTimes(j)+inter;
        		spcounts(j,i)=...
					length(find(spikes>spinter(1)&spikes<spinter(2)))/0.1;
			end;
		end;
		spontrates=[mean(spcounts')' std(spcounts')' std(spcounts')'/sqrt(100)];
		spcounts0=[];
		for i=1:20,
        	inter=5+(i-1)*0.500+[0 0.499999];  % 500ms intervals starting 5s in
		    for j=1:8,
		        spinter = startTimes(j)+inter;
        		spcounts0(j,i)=...
					length(find(spikes>spinter(1)&spikes<spinter(2)))/0.500;
			end;
		end;
		spontrates0=[mean(spcounts0')' std(spcounts0')' std(spcounts0')'/sqrt(20)];
		% compute stimulus rates for all 8 stims
		stimcts = []; sigfiring = []; sig=[];
		cr = getoutput(ra);
		bt = diff(cr.bins{1}(1:2));
		l = size(cr.values{1},2);
		i1=findclosest(cr.bins{1},Int0); % assume trials have same length,bins
		i2=findclosest(cr.bins{1},Int1);
		for i=1:8,
			for j=1:l,
				stimcts(i,j) = sum(cr.values{i}(i1:i2,j))/(bt*(i2-i1+1));
			end;
			[sigfiring(i),sig(i)]=ttest2(stimcts(i,:),...
					spcounts(i,:)+spikethresh,p_val,1);
		end;
		stimrates=[mean(stimcts')' std(stimcts')' std(stimcts')'/sqrt(l)];
		stimcts0 = []; sigfiring0 = []; sig0=[];
		i01=findclosest(cr.bins{1},Int00); % assume trials have same length,bins
		i02=findclosest(cr.bins{1},Int01);
		for i=1:8,
			for j=1:l,
				stimcts0(i,j) = sum(cr.values{i}(i01:i02,j))/(bt*(i02-i01+1));
			end;
			[sigfiring0(i),sig0(i)]=ttest2(stimcts0(i,:),...
					spcounts0(i,:)+spikethresh0,p_val,1);
		end;
		stimrates0=[mean(stimcts0')' std(stimcts0')' std(stimcts0')'/sqrt(l)];

		puremono = 0;
		if eqlen(sigfiring,sigfiring0)& (eqlen(sigfiring,[1 0 1 0 0 1 0 1])|...
			eqlen(sigfiring,[0 1 0 1 1 0 1 0])),
			puremono = 1;
		end;
		weird=0;
		if ~eqlen(sigfiring,sigfiring0), weird = 1; end;
		assoc(end+1)=struct('type','Cone test spont rates',...
			'owner','protocol_LGN','data',spontrates,'desc',...
			'Spontaneous rates during adaptation to 8 colors');
		assoc(end+1)=struct('type','Cone test stim rates',...
			'owner','protocol_LGN','data',stimrates,'desc',...
			'Stimulus rates during cone test');
		assoc(end+1)=struct('type','Cone test significant firing',...
			'owner','protocol_LGN','data',struct('H',sigfiring,'sig',sig),...
			'desc','0/1''s and sig ratings from t-test');
		assoc(end+1)=struct('type','Cone test spont rates whole',...
			'owner','protocol_LGN','data',spontrates0,'desc',...
			'Spontaneous rates during adaptation to 8 colors');
		assoc(end+1)=struct('type','Cone test stim rates whole',...
			'owner','protocol_LGN','data',stimrates0,'desc',...
			'Stimulus rates during cone test');
		assoc(end+1)=struct('type','Cone test significant firing whole',...
			'owner','protocol_LGN','data',struct('H',sigfiring0,'sig',sig0),...
			'desc','0/1''s and sig ratings from t-test over whole trial');
		assoc(end+1)=struct('type','Cone test ind. data','owner',...
			'protocol_LGN','data',...
			struct('spcounts',spcounts,'stimcts',stimcts),...
			'desc','Cone test individual trial data');
		assoc(end+1)=struct('type','Cone test ind. data0','owner',...
			'protocol_LGN','data',...
			struct('spcounts',spcounts0,'stimcts',stimcts0),...
			'desc','Cone test individual trial data');
		assoc(end+1)=struct('type','Pure monochrome','owner','protocol_LGN',...
			'data',puremono,'desc','0/1 is cell purely monochromatic?');
		assoc(end+1)=struct('type','Cone weird','owner','protocol_LGN',...
			'data',weird,'desc','Cone response weird');
newcell = cell;

%some parameters
	else,errordlg(['Cannot find stimulus data for ' cellname ':' cnttest.data]);
	end;
end;

outstr.spontrates=spontrates;
outstr.stimrates = stimrates;
outstr.sigfiring=sigfiring;
outstr.sig = sig;
outstr.stimcts0 = stimcts0;


% now compute cent size analysis values
% six possible situations:
%  is a cent size test but no cone test: compute cent size parameters
%  is a cent size test and 1st gen cone test: compute cent size parameters as
%                                             above
%  is a cent size test and 2nd gen cone test: compute improved cent size params
%  is no cent size test and no cone test: do nothing
%  is no cent size test and 1st gen cone test: just compute limited color params
%  is no cent size test and 2nd gen cone test: compute cent size params
%                       assuming radius in cone test is optimal

cstest = findassociate(newcell,'Cent Size test','protocol_LGN',[]);

inpcs.condnames = {'Center surround response'};
inpcs.spikes = newcell;
binsz = 0.001;

yloc = [];

if isempty(cstest),
	switch genconetest,
		case 0, % we're done, nothing to do
			inpcs.triggers = [];
		case 1, % no cent size test, just cone test, just return color stuff
			inpcs.triggers = [];
		case 2, % compute cent size params assuming radius in cone test is good
			inpcs.triggers = {gettrigs(mticE)};
			yloc = getparameters(get(centExtra,1));
			yloc = yloc.center(2);
	end;
else,
	disp('CSTEST is not empty');
	scs = getstimscripttimestruct(cksds,cstest.data);
	if ~isempty(scs),
		% need to identify best radius in cent size, assume is saved
		NewStimGlobals;
        warning('LGNCONETESTANALYSIS: uses NewStimPixelsPerCm. maybe incorrect.');
		cs = findassociate(newcell,'Center size','protocol_LGN',[]);
		centSize = cs.data*NewStimPixelsPerCm/2;
		csrad = []; csradind=[];
		for i=1:numStims(scs.stimscript),
			ps=getparameters(get(scs.stimscript,i));
			if (centSize-ps.radius)<1, csrad=ps.radius;csradind=i;break; end;
		end;
		yloc = ps.center(2);
		do = getDisplayOrder(scs.stimscript);
		switch genconetest,
			case {0,1}, % compute improved cent size stuff using cent size test
				if isempty(csrad), % shouldn't happen but handle in case
					inpcs.triggers = [];
				else,	
					inds = find(do==csradind);
					inpcs.triggers = {gettrigs(scs.mti(inds))};
					binsz = 0.005; % use 5ms bins in this case
				end;
			case 2,   % compute improved cent size stuff pooling cent/cone 
				ps2 = getparameters(get(centExtra,1));
				if isempty(csrad), % shouldn't happen, but handle it in case
					inpcs.triggers = {gettrigs(mticE)};
				elseif abs(csrad-ps2.radius)<=1, % pool data from two cases
					inds = find(do==csradind);
					inpcs.triggers = {cat(2,gettrigs(scs.mti(inds)),...
						gettrigs(mticE))};
				else, % data are too different to pool, use cent size version
					inds = find(do==csradind);
					inpcs.triggers = {gettrigs(scs.mti(inds))};
					binsz = 0.005; % use 5ms bins in this case
				end;
		end;
	end;
end;

csparams = findassociate(newcell,'Cent Size Params','protocol_LGN',[]);
try,centsizewindow=eval(csparams.data.evalint);catch,centsizewindow=[0 0.1];end;
try, earlywind = []; end;  % force algorithmically-defined windows
try, latewind=[]; end;

peak_latency=[]; peak_firingrate=[]; spike_density=[]; trans=[]; initresp=[];
maintresp=[];earresp=[];midresp=[];lateresp=[];PTIem=[];PTIel=[];PTIml=[];
psth=[];init_latency = [];peak_firingrate_cv = [];

if ~isempty(inpcs.triggers), % compute params
	parmscs=struct('res',binsz,'interval',[-0.5 0.5],'fracpsth',0.5,...
			'normpsth',1,'showvar',0,'psthmode',0,'showfrac',1,...
			'cinterval',[0 0.5],'showcbars',1,'axessameheight',1);
	racs = raster(inpcs,parmscs,wherecs);
	cr = getoutput(racs);
	psth = cr.counts{1};
	[mm,ii]=max(cr.counts{1});  % mm is peak counts
	bt = diff(cr.bins{1}(1:2));
	peak_latency = cr.bins{1}(ii); % peak latency
	%peak_firing at peak latency
	l = size(cr.values{1},2);
	lwbnd = max([1 ii-1]); hibnd = min([ii+1 length(cr.bins{1})]);
	peak_firingrate = sum(cr.counts{1}(lwbnd:hibnd))/(bt*l*(hibnd-lwbnd+1));
	pfrs = sum(cr.values{1}(lwbnd:hibnd,:));
	peak_firingrate_cv = std(pfrs)/mean(pfrs);
    % initial latency
    initinds = find(cr.counts{1}>=0.5*mm);
	if isempty(initinds)|peak_firingrate<65, init_latency = peak_latency;
	else,
		if initinds(1)>ii|initinds(1)==1,init_latency=peak_latency;
		else, init_latency=cr.bins{1}(initinds(1));
		end;
	end;
	%spike_density
	sd0=findclosest(cr.bins{1},spInt0); sd1=findclosest(cr.bins{1},spInt1);
	spike_density = sum(cr.counts{1}(sd0:sd1))/(bt*l*(sd1-sd0));
	% initial, maintained, pti improved
	if isempty(earlywind)|isempty(latewind),
		   ear = peak_latency + [0 0.050]; lat = peak_latency + 0.3 + [0 0.050];
	else, ear = earlywind; lat = latewind;
	end;
	if max(lat)>0.5, lat = 0.45+[0 0.050]; latewind = lat; end;
		% get spontaneous response
	spontasc=findassociate(newcell,'Cent Size spontaneous','protocol_LGN',[]);
	if isempty(spontasc), % we have to calculate a spontaneous rate during isi
		inpcs_spont = inpcs;
		inpcs_spont.triggers = { inpcs_spont.triggers{1} - 0.5 };
		ra_spont = raster(inpcs_spont,parmscs,[]);
		crs = getoutput(ra_spont);
		spontrate = crs.ncounts(1);
	else, spontrate = spontasc.data(1); end; % just grab it from cent size
	e1 = findclosest(cr.bins{1},ear(1));
	e2 = findclosest(cr.bins{1},ear(2));
	l1 = findclosest(cr.bins{1},lat(1));
	l2 = findclosest(cr.bins{1},lat(2));
	l = size(cr.values{1},2);  % number of trials
	% now let's compute a few more measures of transience
	eb1 = findclosest(cr.bins{1},eb); ee1 = findclosest(cr.bins{1},ee);
	mb1 = findclosest(cr.bins{1},mb); me1 = findclosest(cr.bins{1},me);
	lb1 = findclosest(cr.bins{1},lb); le1 = findclosest(cr.bins{1},le);
	x=sum(cr.counts{1}(e1:e2))/(bt*l*(e2-e1+1))-spontrate;
	y=sum(cr.counts{1}(l1:l2))/(bt*l*(e2-e1+1))-spontrate;
	xe=sum(cr.counts{1}(eb1:ee1))/(bt*l*(ee1-eb1+1))-spontrate;
	xm=sum(cr.counts{1}(mb1:me1))/(bt*l*(me1-mb1+1))-spontrate;
	xl=sum(cr.counts{1}(lb1:le1))/(bt*l*(le1-lb1+1))-spontrate;
	eps = 1e-6;
	trans = (x-y)/(x+eps);
	newpti= (peak_firingrate-y)/((peak_firingrate-spontrate)+eps);
    tau = 0.325/(-log(max([0 y/(x+eps)])));
    tau_peak = 0.325/(-log(max([0 y/(peak_firingrate+eps)])));
	maintinitratio = y/(x+eps);
    maintinitration = max([y 0])/(max([x 0])+eps);
	PTIel = (xe-xl)/(xe+eps);
	PTIem = (xe-xm)/(xe+eps);
	PTIml = (xm-xl)/(xm+eps);
	replyear=[];replylat=[];repeint=[];repmint=[];replint=[];
	for I=1:l,
		replyear(end+1) = sum(cr.values{1}(e1:e2,I))/(bt*(e2-e1+1));
		replylat(end+1) = sum(cr.values{1}(l1:l2,I))/(bt*(l2-l1+1));
		repeint(end+1)  = sum(cr.values{1}(eb1:ee1,I))/(bt*(ee1-eb1+1));
		repmint(end+1)  = sum(cr.values{1}(mb1:me1,I))/(bt*(me1-mb1+1));
		replint(end+1)  = sum(cr.values{1}(lb1:le1,I))/(bt*(le1-lb1+1));
	end;
	initresp = [mean(replyear) std(replyear) std(replyear)/sqrt(l)];
	maintresp= [mean(replylat) std(replylat) std(replylat)/sqrt(l)];
	earresp   = [mean(repeint) std(repeint)   std(repeint)/sqrt(l)];
	midresp   = [mean(repmint) std(repmint)   std(repmint)/sqrt(l)];
	latresp   = [mean(replint) std(replint)   std(replint)/sqrt(l)];
	% add associates

	%adjust peak latency

    if ~isempty(yloc),
		peak_latency = peak_latency-(0.2e-3)-(6.79e-3)*yloc/480;
		init_latency = init_latency-(0.2e-3)-(6.79e-3)*yloc/480;
	else, warning('no yloc');
	end;
	
	assoc(end+1)=struct('type','Peak latency',...
			'owner','protocol_LGN','data',peak_latency,'desc',...
			'Peak latency to center surround stimulus');
	assoc(end+1)=struct('type','Initial latency',...
			'owner','protocol_LGN','data',init_latency,'desc',...
			'Initial latency to center surround stimulus');
	assoc(end+1)=struct('type','Peak firing rate',...
			'owner','protocol_LGN','data',peak_firingrate,'desc',...
			'Peak firing rate to center surround stimulus');
	assoc(end+1)=struct('type','Peak firing rate CV',...
			'owner','protocol_LGN','data',peak_firingrate_cv,'desc',...
			'Peak firing rate coefficient of variation');
	assoc(end+1)=struct('type','Spike density','owner','protocol_LGN',...
			'data',spike_density,'desc',...
			'Spike density in 0.020..0.170 after center-surround stim');
	assoc(end+1)=struct('type','Phasic-Tonic index','owner','protocol_LGN',...
		'data',trans,'desc','Phasic-tonic index');
	assoc(end+1)=struct('type','PTI Peak','owner','protocol_LGN',...
		'data',newpti,'desc','PTI Peak');
	assoc(end+1)=struct('type','Tau Peak','owner','protocol_LGN',...
		'data',tau_peak,'desc','Tau Peak PTI');
	assoc(end+1)=struct('type','Tau','owner','protocol_LGN',...
		'data',tau,'desc','Tau PTI');
	assoc(end+1)=struct('type','Center Initial Response imp',...
		'owner','protocol_LGN','data',initresp,'desc',...
		'Center initial response improved');
	assoc(end+1)=struct('type','Center Maintained Response imp',...
		'owner','protocol_LGN','data',maintresp,'desc',...
		'Center maintained response imp');
	assoc(end+1)=struct('type','Center early response',...
		'owner','protocol_LGN','data',earresp,'desc',...
		'Early response to center stimulation');
	assoc(end+1)=struct('type','Center middle response',...
		'owner','protocol_LGN','data',midresp,'desc',...
		'Middle response to center stimulation');
	assoc(end+1)=struct('type','Center late response',...
		'owner','protocol_LGN','data',latresp,'desc',...
		'Late response to center stimulation');
	assoc(end+1)=struct('type','PTI early/late',...
		'owner','protocol_LGN','data',PTIel,'desc',...
		'Phasic-Tonic index early/late');
	assoc(end+1)=struct('type','PTI early/middle',...
		'owner','protocol_LGN','data',PTIem,'desc',...
		'Phasic-Tonic index early/middle');
	assoc(end+1)=struct('type','PTI middle/late',...
		'owner','protocol_LGN','data',PTIml,'desc',...
		'Phasic-Tonic index middle/late');
	assoc(end+1)=struct('type','Maintained/Initial Response Ratio',...
		'owner','protocol_LGN','data',maintinitratio,...
		'desc','Maintained Response / Initial Response');
	assoc(end+1)=struct('type','Maintained/Initial Response Ratio Positive',...
		'owner','protocol_LGN','data',maintinitration,...
		'desc','Maintained Response / Initial Response Positive');
	assoc(end+1)=struct('type','Center PSTH','owner','protocol_LGN',...
		'data',psth,'desc','Center PSTH');
end;

outstr.peak_latency = peak_latency; outstr.peak_firingrate =peak_firingrate;
outstr.spike_density = spike_density; outstr.trans = trans;
outstr.initresp = initresp; outstr.maintresp = maintresp;
outstr.earresp = earresp; outstr.PTIel = PTIel; outstr.PTIem = PTIem;
outstr.PTIml = PTIml;

for i=1:length(assoc),newcell=associate(newcell,assoc(i)); end;

%outstr = cr;

function trigs=gettrigs(mti)
trigs = [];
for i=1:length(mti), trigs(end+1) = mti{i}.frameTimes(1); end;


