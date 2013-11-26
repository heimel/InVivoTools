function [newcell,outstr,assoc,ra]=lgnconetestanalysis(cksds,cell,...
		cellname,display)

%  LGN3CONETESTANALYSIS
%
%  [NEWSCELL,OUTSTR,ASSOC,RA]=LGN3CONETESTANALYSIS(CKSDS,CELL,CELLNAME,DISPLAY)
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
%  (there are more, see 'lgnassociatelist.m')

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

 % first, disassociate any 'cent size' measures associated with this cell
assoclist = lgnassociatelist('ConeTest3');

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
if ~isempty(cntest), % if there is no cone test, stop
	s = getstimscripttimestruct(cksds,cntest.data);
	if ~isempty(s),  % decompose script into its original stimuli
		rest = s.stimscript; mtir=s.mti; genconetest = 1;
		[Madapt,rest,mtiMa,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[Mcent,rest,mtiMc,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[madapt,rest,mtima,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[mcent,rest,mtimc,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[Sadapt,rest,mtiSa,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[Scent,rest,mtiSc,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[sadapt,rest,mtisa,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[scent,rest,mtisc,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[Radapt,rest,mtiRa,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[Rcent,rest,mtiRc,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[radapt,rest,mtira,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[rcent,rest,mtirc,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[Madapts,rest,mtiMas,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[Msurr,rest,mtiMs,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[madapts,rest,mtimas,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[msurr,rest,mtims,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[Sadapts,rest,mtiSas,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[Ssurr,rest,mtiSs,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[sadapts,rest,mtisas,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[ssurr,rest,mtiss,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[Radapts,rest,mtiRas,mtir]=DecomposeScriptMTI(rest,mtir,1);
		[Rsurr,rest,mtiRs,mtir]=DecomposeScriptMTI(rest,mtir,[1]);
		[radapts,rsurr,mtiras,mtirs]=DecomposeScriptMTI(rest,mtir,1);
		inp.triggers= { gettrigs(mtiMc) gettrigs(mtimc) gettrigs(mtiSc) ...
					gettrigs(mtisc) gettrigs(mtiRc) gettrigs(mtirc) ...
					gettrigs(mtiMs) gettrigs(mtims) ...
					gettrigs(mtiSs) gettrigs(mtiss) gettrigs(mtiRs) ...
					gettrigs(mtirs)};
		inp.condnames = {'m+ cent' 'm- cent' 's+ cent' 's- cent' 'r+ cent' 'r- cent'...
					'm+ surr' 'm- surr' 's+ surr' 's- surr' 'r+ surr' 'r- surr'};
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
		startTimes(5) = mtiRa{1}.startStopTimes(1);
		startTimes(6) = mtira{1}.startStopTimes(1);
		startTimes(7) = mtiMas{1}.startStopTimes(1);
		startTimes(8) = mtimas{1}.startStopTimes(1);
		startTimes(9) = mtiSas{1}.startStopTimes(1);
		startTimes(10) = mtisas{1}.startStopTimes(1);
		startTimes(11) = mtiRas{1}.startStopTimes(1);
		startTimes(12) = mtiras{1}.startStopTimes(1);
        % compute spontaneous rate during last 10s of adapting stimuli
		spikes=get_data(cell,[startTimes(1) mtiras{1}.startStopTimes(end)]);
		spcounts=[];
		for i=1:100,
        	inter=5+(i-1)*0.100+[0 0.099999];  % 100ms intervals starting 5s in
		    for j=1:12,
		        spinter = startTimes(j)+inter;
        		spcounts(j,i)=...
					length(find(spikes>spinter(1)&spikes<spinter(2)))/0.1;
			end;
		end;
		spontrates=[mean(spcounts')' std(spcounts')' std(spcounts')'/sqrt(100)];
		spcounts0=[];
		for i=1:20,
        	inter=5+(i-1)*0.500+[0 0.499999];  % 500ms intervals starting 5s in
		    for j=1:12,
		        spinter = startTimes(j)+inter;
        		spcounts0(j,i)=...
					length(find(spikes>spinter(1)&spikes<spinter(2)))/0.500;
			end;
		end;
		spontrates0=[mean(spcounts0')' std(spcounts0')' std(spcounts0')'/sqrt(20)];
		% compute stimulus rates for all 12 stims
		stimcts = []; sigfiring = []; sig=[];
		cr = getoutput(ra);
		bt = diff(cr.bins{1}(1:2));
		l = size(cr.values{1},2);
		i1=findclosest(cr.bins{1},Int0); % assume trials have same length,bins
		i2=findclosest(cr.bins{1},Int1);
		for i=1:12,
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
		for i=1:12,
			for j=1:l,
				stimcts0(i,j) = sum(cr.values{i}(i01:i02,j))/(bt*(i02-i01+1));
			end;
			[sigfiring0(i),sig0(i)]=ttest2(stimcts0(i,:),...
					spcounts0(i,:)+spikethresh0,p_val,1);
		end;
		stimrates0=[mean(stimcts0')' std(stimcts0')' std(stimcts0')'/sqrt(l)];

		puremono = 0;
		if eqlen(sigfiring,sigfiring0)& (eqlen(sigfiring,[1 0 1 0 1 0 0 1 0 1 0 1])|...
			eqlen(sigfiring,[0 1 0 1 0 1 1 0 1 0 1 0])),
			puremono = 1;
		end;
		weird=0;
		if ~eqlen(sigfiring,sigfiring0), weird = 1; end;
		assoc(end+1)=struct('type','Cone test 3 spont rates',...
			'owner','protocol_LGN','data',spontrates,'desc',...
			'Spontaneous rates during adaptation to 12 colors');
		assoc(end+1)=struct('type','Cone test 3 stim rates',...
			'owner','protocol_LGN','data',stimrates,'desc',...
			'Stimulus rates during cone test');
		assoc(end+1)=struct('type','Cone test 3 significant firing',...
			'owner','protocol_LGN','data',struct('H',sigfiring,'sig',sig),...
			'desc','0/1''s and sig ratings from t-test');
		assoc(end+1)=struct('type','Cone test 3 spont rates whole',...
			'owner','protocol_LGN','data',spontrates0,'desc',...
			'Spontaneous rates during adaptation to 8 colors');
		assoc(end+1)=struct('type','Cone test 3 stim rates whole',...
			'owner','protocol_LGN','data',stimrates0,'desc',...
			'Stimulus rates during cone test');
		assoc(end+1)=struct('type','Cone test 3 significant firing whole',...
			'owner','protocol_LGN','data',struct('H',sigfiring0,'sig',sig0),...
			'desc','0/1''s and sig ratings from t-test over whole trial');
		assoc(end+1)=struct('type','Cone test 3 ind. data','owner',...
			'protocol_LGN','data',...
			struct('spcounts',spcounts,'stimcts',stimcts),...
			'desc','Cone test individual trial data');
		assoc(end+1)=struct('type','Cone test 3 ind. data0','owner',...
			'protocol_LGN','data',...
			struct('spcounts',spcounts0,'stimcts',stimcts0),...
			'desc','Cone test individual trial data');
		assoc(end+1)=struct('type','Pure monochrome 3','owner','protocol_LGN',...
			'data',puremono,'desc','0/1 is cell purely monochromatic?');
		assoc(end+1)=struct('type','Cone weird 3','owner','protocol_LGN',...
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

for i=1:length(assoc),newcell=associate(newcell,assoc(i)); end;

%outstr = cr;

function trigs=gettrigs(mti)
trigs = [];
for i=1:length(mti), trigs(end+1) = mti{i}.frameTimes(1); end;


