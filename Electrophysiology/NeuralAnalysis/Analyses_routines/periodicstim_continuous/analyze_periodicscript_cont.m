function [comps] = analyze_periodicscript_cont(cksmd,sts,p,timeres,howanalyze,runspont)

% ANALYZE_PERIODICSTIM_CONT Analyze continuous data response to periodic_script
%
%   [COMPS]=ANALYZE_PERIODICSCRIPT_CONT(CKSMD,STS,PARAMETER,TIMERES,...
%          HOWANALYZE,RUNSPONT)
%
%  Computes individual, mean, standard deviations, and standard errors of the
%  F0, F1, and F2 components of the response to a periodic_script.  CMSMD
%  is a CKSMEASUREDDATA object with continuously-measured data, STS is a
%  stimscripttimestruct containing a periodic_script and its timing record,
%  PARAMETER is the varied parameter of interest (e.g., 'angle'), and TIMERES
%  is the time resolution of the desired answer (e.g., 1e-3s,1e-4s, etc.).
%  HOWANALYZE is one of the following strings:
%     'whole'            analyze over all of each stimulus
%     'cycle-by-cycle'   analyze each  ** (not implemented yet)
%  
%  COMPS is a structure containing fields f0, f1, f2, f0mean, f1mean, f2mean,
%  f0stddev,f1stddev,f2stddev,f0stderr,f1stderr, f2stderr,indwaves,meanwaves,
%  stdwaves,samptimes (the sample times for indwaves,meanwaves,stdwaves).
%  All of these fields are cells.  If the analysis is 'whole', then there are
%  as many cells for each parameter as stimuli in the periodic_script.
%  If the analysis is 'cycle-by-cycle', then the cells are
%  numofcyclesXnumofstim.
%  If RUNSPONT is not given or is 1, spontaneous activity rates are calculated.
%  If RUNSPONT is 0, spontaneous activity rates are not calculated.
%
%  Note: at present, 'cycle-by-cycle' is pretty slow, not tested.
%
%  See also:  PERIODICSCRIPT, STIMSCRIPTTIMESTRUCT

ps = sts.stimscript;
params = getparameters(ps);
nCyc = params.nCycles;

do = getDisplayOrder(ps);
stims = unique(do);

if nargin<6, rs = 1; else, rs = runspont; end;

spontindwaves={}; spontmeanwaves={}; spontstdwaves={}; spontsampletimes={};
spontf0={}; spontf1={};spontf2={};
spontf0mean=[];spontf1mean=[];spontf2mean=[];
f0vals = []; f1vals = []; f2vals = [];

for i=1:length(stims),
	stiminds=find(do==stims(i));
	pp=getparameters(get(ps,i));
	curve(i)=getfield(pp,p);

	 % compute spontaneous activity rates, in interstimulus times
	dp=struct(getdisplayprefs(get(ps,i)));
    fpc=length(unique(dp.frames));
	if (dp.BGposttime>0), spontTime = dp.BGposttime;
	elseif (dp.BGpretime>0), spontTime = dp.BGpretime;
	else, spontTime = 0;
	end;
	if spontTime>0&rs~=0,
		for j=1:length(stiminds),
			if (dp.BGposttime>0)|(dp.BGpretime>0),
				sponttrigs(j)=sts.mti{stiminds(j)}.frameTimes(end);
			    meanfdt(j) = mean(diff(sts.mti{stiminds(j)}.frameTimes));
			end;
		end;
	    [spontindwaves{i},spontmeanwaves{i},spontstdwaves{i},...
			spontsampletimes{i}]=...
			raster_continuous(cksmd,sponttrigs+mean(meanfdt),0,spontTime,...
					timeres);
		estper=fpc*mean(meanfdt);
		spontf0{i}=fouriercoeffs_tf(spontindwaves{i}',0,1/timeres);
		spontf1{i}=fouriercoeffs_tf(spontindwaves{i}',1/estper,1/timeres);
		spontf2{i}=fouriercoeffs_tf(spontindwaves{i}',2/estper,1/timeres);
		spontf0mean = [spontf0mean spontf0{i}];
		spontf1mean = [spontf1mean abs(spontf1{i})];
		spontf2mean = [spontf2mean abs(spontf2{i})];
	end;

	% now compute stimulus activity rates
	switch howanalyze
	case 'whole',
		trigs=[]; len=[]; meanfdt=[];
		for j=1:length(stiminds),
			trigs(j)=sts.mti{stiminds(j)}.frameTimes(1);
			meanfdt(j) = mean(diff(sts.mti{stiminds(j)}.frameTimes));
			len(j) = sts.mti{stiminds(j)}.frameTimes(end)-trigs(j)+meanfdt(j);
		end;
		[indwaves{i},meanwaves{i},stdwaves{i},sampletimes{i}]=...
			raster_continuous(cksmd,trigs,0,median(len),timeres);
	    dp=struct(getdisplayprefs(get(ps,i)));
        fpc=length(unique(dp.frames));
		estper=fpc*mean(meanfdt);
	    curve(i)=getfield(pp,p);
		f0{i}=fouriercoeffs_tf(indwaves{i}',0,1/timeres);
		f0vals(:,i) = f0{i}';
		f1{i}=fouriercoeffs_tf(indwaves{i}',1/estper,1/timeres);
		f1vals(:,i) = f1{i}';
		f2{i}=fouriercoeffs_tf(indwaves{i}',2/estper,1/timeres);
		f2vals(:,i) = f2{i}';
		f0mean(i)=mean(f0{i});f1mean(i)=mean(f1{i});f2mean(i)=mean(f2{i});
		f0stddev(i)=std(f0{i});f1stddev(i)=std(f1{i});f2stddev(i)=std(f2{i});
		f0stderr(i)=stderr(f0{i}');
		f1stderr(i)=stderr(f1{i}');
		f2stderr(i)=stderr(f2{i}');
	case 'cycle-by-cycle',
		   % STILL NEED TO CHECK THAT F#VALS ARE STORED CORRECTLY
		trigs = cell(1,nCyc); len = []; meanfdt = [];
		dp=struct(getdisplayprefs(get(ps,i)));
		fpc=length(unique(dp.frames));
		for j=1:length(stiminds),
		  meanfdt(j)=mean(diff(sts.mti{stiminds(j)}.frameTimes));
		  len(j)=sts.mti{stiminds(j)}.frameTimes(end)-...
		  		sts.mti{stiminds(j)}.frameTimes(1)+meanfdt(j);
		  for n=1:nCyc,
		     trigs{n}=cat(1,trigs{n},sts.mti{stiminds(j)}.frameTimes(1+(n-1)*fpc));
		  end;
	    end;
		estper=fpc*mean(meanfdt);
		for n=1:nCyc,
			[indwaves{i}{n},meanwaves{i}{n},stdwaves{i}{n},sampletimes{i}{n}]=...
				raster_continuous(cksmd,trigs{n},0,median(len),timeres);
			f0{i}{n}=fouriercoeffs_tf(indwaves{i}{n}',0,1/timeres);
			f0vals((n-1)*length(stiminds)+(1:length(stiminds)),i) = f0{i}{n}';
			f1{i}{n}=fouriercoeffs_tf(indwaves{i}{n}',1/estper,1/timeres);
			f1vals((n-1)*length(stiminds)+(1:length(stiminds)),i) = f1{i}{n}';
			f2{i}{n}=fouriercoeffs_tf(indwaves{i}{n}',2/estper,1/timeres);
			f2vals((n-1)*length(stiminds)+(1:length(stiminds)),i) = f2{i}{n}';
			f0mean(i,n)=mean(f0{i}{n}); f1mean(i,n)=mean(f1{i}{n});
			f2mean(i,n)=mean(f2{i}{n});
			f0stddev(i,n)=std(f0{i}{n}); f1stddev(i,n)=std(f1{i}{n});
			f2stddev(i,n)=std(f2{i}{n});
			f0stderr(i,n)=stderr(f0{i}{n}'); f1stderr(i,n)=stderr(f1{i}{n}');
			f2stderr(i,n)=stderr(f2{i}{n}');
		end;
	end;
end;

if rs==1,
	spontf0mean = mean(spontf0mean);
	spontf1mean = mean(spontf1mean);
	spontf2mean = mean(spontf2mean);
end;

% make variables similar to periodic_curve even though redundant
f0curve = [ curve ; f0mean ; f0stddev ; f0stderr];
f1curve = [ curve ; f1mean ; f1stddev ; f1stderr];
f2curve = [ curve ; f2mean ; f2stddev ; f2stderr];

comps.f0=f0;comps.f1=f1;comps.f2=f2;comps.indwaves=indwaves;
comps.meanwaves=meanwaves;comps.stdwaves=stdwaves;
comps.f0mean=f0mean; comps.f1mean=f1mean; comps.f2mean=f2mean;
comps.f0stddev=f0stddev; comps.f1stddev=f1stddev; comps.f2stddev=f2stddev;
comps.f0stderr=f0stderr; comps.f1stderr=f1stderr; comps.f2stderr=f2stderr;
comps.curve = curve;comps.sampletimes=sampletimes;
comps.spontindwaves=spontindwaves; comps.spontmeanwaves=spontmeanwaves;
comps.spontstdwaves=spontstdwaves; comps.spontsampletimes=spontsampletimes;
comps.spontf0=spontf0;comps.spontf1=spontf1;comps.spontf2=spontf2;
comps.spontf0mean=spontf0mean; comps.spontf1mean=spontf1mean;
comps.spontf2mean=spontf2mean;
comps.f0curve=f0curve; comps.f1curve=f1curve; comps.f2curve=f2curve;
comps.f1vals=f1vals; comps.f0vals=f0vals; comps.f2vals=f2vals;

