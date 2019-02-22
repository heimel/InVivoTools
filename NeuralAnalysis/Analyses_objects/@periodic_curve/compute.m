function pcn = compute(pc,record)

% Part of the NeuralAnalysis package
%
%    PCN = COMPUTE(MY_PERIODIC_CURVE)
%
%  Performs computations for the PERIODIC_CURVE object MY_PERIODIC_CURVE and
%  returns a new object.
%
%  See also:  ANALYSIS_GENERIC/compute, PERIODIC_CURVE


if nargin<2
	record = [];
end

processparams = ecprocessparams(record);

p = getparameters(pc);
I = getinputs(pc);

if ~isempty(pc.internals.oldparams)
	if eqlen(pc.internals.oldparams.paramnames,p.paramnames)&&...
			pc.internals.oldparams.res==p.res && ...
			pc.internals.oldparams.lag==p.lag
		pcn=pc;
		return
	end
end

% otherwise, we have new parameter values which affect the computation
pst = false;
pre = false;

% isolate data to be analyzed
inc = [];
[stims,mti,disporder] = mergestimscripttimestruct(I.st);
for i=1:length(stims)
	if ~isempty(p.paramnames)
		use = 1;
		par = getparameters(stims{i});
		for j=1:length(p.paramnames)
			b = isfield(par,I.paramnames{1});
			if length(I.paramnames)>1
				b=b&isfield(par,I.paramnames{2});
			end
			if isfield(par,p.paramnames{j}) && b
				for k=1:length(p.values{j})
					if par.(p.paramnames{j})~=p.values{j}{k},use=0;end;
				end;
			else
				use=0;
			end
		end
		if use==1
			inc = cat(2,inc,i);
		end
	else
		inc = cat(2,inc,i);
	end
end

vars={};
vals={};
if length(I.paramnames)==1
	vals{1}=[];
end
for i=inc
	par = getparameters(stims{inc(i)});
	if length(I.paramnames)==1
		vals{1} = cat(2,vals{1},i);
	else
		used=0;
		for j=1:length(vars)
			if eqlen(vars{j},par.(I.paramnames{2}))
				vals{j} = cat(2,vals{j},i);
				used=1;
			end
		end
		if ~used
			vars{length(vars)+1} = par.(I.paramnames{2});
			vals{length(vals)+1} = i;
		end
	end
end
if isempty(vars)
	vars = {[]};
end

% compute spontaneous activity rate on first pass through
for z = 1:length(vars) % looping over second parameter
	s = 1;
	interval{z} = zeros(length(vals{z}),2);
	cinterval{z} = zeros(length(vals{z}),2);
	for j = 1:length(vals{z}) % looping over first parameter
		ps = getparameters(stims{vals{z}(j)});
		curve_x{z}(s) = ps.(I.paramnames{1});
		condnames{z}{s} = [I.paramnames{1} '=' num2str(curve_x{z}(s))];
		stimlist = find(disporder==vals{z}(j));
		dp = struct(getdisplayprefs(stims{vals{z}(j)}));
		df = mean(diff(mti{stimlist(1)}.frameTimes));
		cinterval{z}(j,:) = [0 mti{stimlist(1)}.frameTimes(end)-mti{stimlist(1)}.frameTimes(1)+df];
		for k=1:length(stimlist)
			trigs{z}{s}(k) = mti{stimlist(k)}.frameTimes(1);
			spon{1}(stimlist(k)) = trigs{z}{s}(k);
		end
		if length(mti)>=2
			if dp.BGpretime - processparams.separation_from_prev_stim_off >= processparams.minimum_spontaneous_time
				% use BGpretime
				pre = true;
				interval{z}(j,:) = [cinterval{z}(j,1)-dp.BGpretime cinterval{z}(j,2)];
			elseif dp.BGposttime - processparams.separation_from_prev_stim_off >= processparams.minimum_spontaneous_time
				% use BGposttime
				pst = true;
				interval{z}(j,:) = [cinterval{z}(j,1) cinterval{z}(j,2)+dp.BGposttime];
			else
				interval{z}(j,:) = cinterval{z}(j,:);
			end
		else
			interval{z}(j,:) = interval{z}(j,:);
		end
	end
end
sint = [ min(interval{1}(:,1)) max(interval{1}(:,2)) ];
if pst && ~pre   %BGposttime used
	spontlabel = 'stimulus / spontaneous';
	scint = [ max(cinterval{1}(:,2))+processparams.separation_from_prev_stim_off max(interval{1}(:,2))];
elseif pre && ~pst  % BGpretime used
	spontlabel = 'spontaneous / stimulus';
	scint = [ min(interval{1}(:,1))+processparams.separation_from_prev_stim_off min(cinterval{1}(:,1)) ];
else
	logmsg('No or too short spontaneous period. Consider changing separation_from_prev_stim_off or minimum_spontaneous_time in processparams_local');
	spontlabel = 'trials';
	scint = sint;
end

spontval = [];
spontrast = [];
avg_rate = 0;
inp.condnames = condnames;
inp.spikes = I.spikes;
inp.triggers=trigs;
RAparams.res = p.res;
RAparams.interval = interval;
RAparams.cinterval = cinterval;
RAparams.showcbars = 1;
RAparams.fracpsth = 0.5;
RAparams.normpsth = 1;
RAparams.showvar = 0;
RAparams.psthmode = 0;
RAparams.showfrac = 1;
RAparams.axessameheight = 1;
if ~isempty(scint)
	RAparams.cinterval=scint;
	RAparams.interval=sint;
	inp.triggers=spon;
	inp.condnames = {spontlabel};
	pc.internals.spont=raster(inp,RAparams,[]);
	spontrast = pc.internals.spont;
	sc = getoutput(pc.internals.spont);
	spontval = [mean(sc.ncounts') mean(sc.ctdev')];
	avg_rate = spontval(1);
end

clear trigs condnames RAparams curve_x cinterval interval

% general parameters for rasters
RAparams.res = p.res;  % need specifics below
RAparams.showcbars = 1;
RAparams.fracpsth = 0.5;
RAparams.normpsth = 1;
RAparams.showvar = 0;
RAparams.axessameheight = 1;
RAparams.psthmode = 0;
RAparams.showfrac = 1;
RAinp.spikes = I.spikes;

% now make computations on second pass
interval = cell(length(vars),1);
cinterval = cell(length(vars),1);
for z = 1:length(vars)  % looping over second parameter
	% make plots/analysis for each condition
	s = 1; % stim range number
	interval{z} = zeros(length(vals{z}),2);
	cinterval{z} = zeros(length(vals{z}),2);
	for j = 1:length(vals{z}) % looping over first parameter
		ps = getparameters(stims{vals{z}(j)});
		curve_x{z}(s) = ps.(I.paramnames{1});
		condnames{z}{s}=[I.paramnames{1} '=' num2str(curve_x{z}(s))];
		stimlist = find(disporder==vals{z}(j));
		dp = struct(getdisplayprefs(stims{vals{z}(j)}));
		df = mean(diff(mti{stimlist(1)}.frameTimes)); % frameperiod 
		cinterval{z}(j,:) = [0 mti{stimlist(1)}.frameTimes(end)-mti{stimlist(1)}.frameTimes(1)+df];
		%fpc = length(unique(dp.frames));
		fpc = length(dp.frames)/ps.nCycles;
		estpers(s) = fpc*df; % estimated actual period shown
		cyci_curve_x{z}{s} = 1:ps.nCycles;
		cyci_cinterval{z}{s} = p.lag+[0 estpers(s)];
		cyci_interval{z}{s}  = p.lag+[0 estpers(s)];
		for nn=1:ps.nCycles
			cyci_condnames{z}{s}{nn} = num2str(nn);
		end
		for k=1:length(stimlist)
			trigs{z}{s}(k) = mti{stimlist(k)}.frameTimes(1);
			spon{1}(stimlist(k)) = trigs{z}{s}(k);
			% our monitor can't produce tF exactly, so we have to get frame time stamps
			for nn=1:ps.nCycles
				cyci_trigs{z}{s}{nn}(k) = mti{stimlist(k)}.frameTimes(1+(nn-1)*fpc);
				cycg_trigs{z}{s}((k-1)*ps.nCycles+nn) = cyci_trigs{z}{s}{nn}(k);
			end
		end
		if length(mti)>=2 % set 'interval'
			if dp.BGposttime>0 % use posttime
				%pst = pst+1;
				interval{z}(j,:) = [cinterval{z}(j,1) cinterval{z}(j,2)+dp.BGposttime] + p.lag;
			elseif dp.BGpretime>0 % use pretime
				%pre = pre+1;
				interval{z}(j,:) = [cinterval{z}(j,1)-dp.BGpretime cinterval{z}(j,2)] + p.lag;
			else
				interval{z}(j,:) = cinterval{z}(j,:) + p.lag;
			end
		else
			interval{z}(j,:) = interval{z}(j,:) + p.lag;
		end
		cinterval{z}(j,:) = cinterval{z}(j,:) + p.lag;
		% at this point, ready to compute individual cycle average
		RAip = RAparams; 
		RAip.interval = cyci_interval{z}{s}; 
		RAip.cinterval = cyci_cinterval{z}{s};
		RAI = RAinp; 
		RAI.condnames = cyci_condnames{z}{s}; 
		RAI.triggers = cyci_trigs{z}{s};
		%global c estper spontval cyci_curve
		cyci_rast{z}{s} = raster(RAI,RAip,[]); 
		c = getoutput(cyci_rast{z}{s});
		cyci_curve{z}{s} = [cyci_curve_x{z}{s}; c.ncounts'; c.ctdev'; c.stderr'];
		% compute f1's,f2's,etc...
		loc1 = findclosest(c.fftfreq{1},1/estpers(s)); % since its multiple pres. of same stim, take first
		loc2 = findclosest(c.fftfreq{1},2/estpers(s)); % since its multiple pres. of same stim, take first
		
		cf1mean = []; 
		cf1stddev = []; 
		cf1stderr = [];
		cf2mean = []; 
		cf2stddev = []; 
		cf2stderr = [];
		cf1f0mean = []; 
		cf1f0stddev = []; 
		cf1f0stderr = [];
		cf2f1mean = []; 
		cf2f1stddev = [];
		for nn = 1:ps.nCycles 
			cf1mean(nn) = abs(mean((c.fftvals{nn}(loc1,:))));
			cf1stddev(nn) = std(c.fftvals{nn}(loc1,:));
			cf1stderr(nn) = cf1stddev(nn)/sqrt(length(stimlist));
			cf2mean(nn) = abs(mean((c.fftvals{nn}(loc2,:))));
			cf2stddev(nn) = std(c.fftvals{nn}(loc2,:));
			cf2stderr(nn) = cf2stddev(nn)/sqrt(length(stimlist));
			cf1f0mean(nn) = abs(abs(mean(divide_nozero((c.fftvals{nn}(loc1,:)),(c.fftvals{nn}(1,:))-avg_rate))));
			cf1f0stddev(nn) = std(divide_nozero((c.fftvals{nn}(loc1,:)),(c.fftvals{nn}(1,:))-avg_rate));
			cf1f0stderr(nn) = cf1f0stddev(nn)/sqrt(length(stimlist));
			cf2f1mean(nn) = abs(abs(mean(divide_nozero((c.fftvals{nn}(loc2,:)),(c.fftvals{nn}(loc1,:))))));
			cf2f1stddev(nn) = std(divide_nozero((c.fftvals{nn}(loc2,:)),(c.fftvals{nn}(loc1,:))));
			cf2f1stderr(nn) = cf2f1stddev(nn)/sqrt(length(stimlist));
		end
		cyci_f1curve{z}{s} = [cyci_curve_x{z}{s}; cf1mean; cf1stddev; cf1stderr;];
		cyci_f2curve{z}{s} = [cyci_curve_x{z}{s}; cf2mean; cf2stddev; cf2stderr;];
		cyci_f1f0curve{z}{s} = [cyci_curve_x{z}{s}; cf1f0mean; cf1f0stddev; cf1f0stderr;];
		cyci_f2f1curve{z}{s} = [cyci_curve_x{z}{s}; cf2f1mean; cf2f1stddev; cf2f1stderr;];
		
		cycg_cinterval{z}(j,:) = cyci_cinterval{z}{s};
		cycg_interval{z}(j,:)  = cyci_interval{z}{s};
		s = s+1;
	end
	
	% for c1
	RAcp = RAparams; 
	RAcp.interval = cycg_interval{z}; 
	RAcp.cinterval = cycg_cinterval{z};
	RAci = RAinp; 
	RAci.condnames = condnames{z}; 
	RAci.triggers = cycg_trigs{z};
	cycg_rast{z} = raster(RAci,RAcp,[]);
	c1 = getoutput(cycg_rast{z}); 
	cycg_curve{z} = [curve_x{z}; c1.ncounts'; c1.ctdev'; c1.stderr'];

	% for c
	RAp = RAparams;
	RAp.interval = interval{z};
	RAp.cinterval = cinterval{z};
	RAi = RAinp;
	RAi.condnames = condnames{z};
	RAi.triggers = trigs{z};
	rast{z} = raster(RAi,RAp,[]);
	c = getoutput(rast{z});
	curve{z} = [curve_x{z}; c.ncounts'; c.ctdev'; c.stderr'];
	
	
	cf1meanc = zeros(1,length(stims));
	cf1stddevc = zeros(1,length(stims)); 
	cf1stderrc = zeros(1,length(stims)); 
	cf2meanc = zeros(1,length(stims)); 
	cf2stddevc = zeros(1,length(stims)); 
	cf2stderrc = zeros(1,length(stims));
	cf1f0meanc = zeros(1,length(stims)); 
	cf1f0stddevc = zeros(1,length(stims)); 
	cf1f0stderrc = zeros(1,length(stims)); 
	cf2f1meanc = zeros(1,length(stims)); 
	cf2f1stddevc = zeros(1,length(stims));
	cf1mean = zeros(1,length(stims));
	cf1stddev = zeros(1,length(stims));
	cf1stderr = zeros(1,length(stims));
	cf2mean = zeros(1,length(stims));
	cf2stddev = zeros(1,length(stims));
	cf2stderr = zeros(1,length(stims));
	cf1f0mean = zeros(1,length(stims)); 
	cf1f0stddev = zeros(1,length(stims)); 
	cf1f0stderr = zeros(1,length(stims)); 
	cf2f1mean = zeros(1,length(stims));
	cf2f1stddev = zeros(1,length(stims));
	cf2f1stderr = zeros(1,length(stims));
	cf0vals = zeros(size(c.fftvals{z},2),length(stims));
	cf1vals = zeros(size(c.fftvals{z},2),length(stims));
	cf2vals = zeros(size(c.fftvals{z},2),length(stims));
	cf1f0vals = zeros(size(c.fftvals{z},2),length(stims));
	cf2f1vals = zeros(size(c.fftvals{z},2),length(stims));
	
	for nn=1:length(stims)
		% for c1
		loc1c = findclosest(c1.fftfreq{nn},1/estpers(nn)); % index of F1 freq
		loc2c = findclosest(c1.fftfreq{nn},2/estpers(nn)); % index of F2 freq
		cf1meanc(nn) = (abs(mean((c1.fftvals{nn}(loc1c,:)))));
		cf1stddevc(nn) = std((c1.fftvals{nn}(loc1c,:)));
		cf1stderrc(nn) = cf1stddevc(nn)/sqrt(length(stims));
		cf2meanc(nn) = (abs(mean((c1.fftvals{nn}(loc2c,:)))));
		cf2stddevc(nn) = std((c1.fftvals{nn}(loc2c,:)));
		cf2stderrc(nn) = cf2stddevc(nn)/sqrt(length(stims));
		cf1f0meanc(nn) = abs(real(mean(divide_nozero((c1.fftvals{nn}(loc1c,:)),(c1.fftvals{nn}(1,:))-avg_rate))));
		cf1f0stddevc(nn) = std(divide_nozero((c1.fftvals{nn}(loc1c,:)),(c1.fftvals{nn}(1,:))-avg_rate));
		cf1f0stderrc(nn) = cf1f0stddevc(nn)/sqrt(length(stims));
		cf2f1meanc(nn) = abs(abs(mean(divide_nozero((c1.fftvals{nn}(loc2c,:)),(c1.fftvals{nn}(loc1c,:))))));
		cf2f1stddevc(nn) = std(divide_nozero((c1.fftvals{nn}(loc2c,:)),(c1.fftvals{nn}(loc1c,:))));
		cf2f1stderrc(nn) = cf2f1stddevc(nn)/sqrt(length(stims));
		
		% for c
		loc1 = findclosest(c.fftfreq{nn},1/estpers(nn)); % index of F1 freq
		loc2 = findclosest(c.fftfreq{nn},2/estpers(nn)); % index of F2 freq
		cf0vals(:,nn) = (c.fftvals{nn}(1,:))';
		cf1vals(:,nn) = (c.fftvals{nn}(loc1,:))';
		cf2vals(:,nn) = (c.fftvals{nn}(loc2,:))';
		cf1f0vals(:,nn) = (divide_nozero(c.fftvals{nn}(loc1,:),c.fftvals{nn}(1,:)-avg_rate))';
		cf2f1vals(:,nn) = (divide_nozero(c.fftvals{nn}(loc2,:),c.fftvals{nn}(loc1,:)-avg_rate))';
		cf1mean(nn) = (abs(mean((c.fftvals{nn}(loc1,:)))));
		cf1stddev(nn) = std((c.fftvals{nn}(loc1,:)));
		cf1stderr(nn) = cf1stddev(nn)/sqrt(length(stims));
		cf0mean(nn) = (abs(mean((c.fftvals{nn}(1,:)))));
		cf0stddev(nn) = std((c.fftvals{nn}(1,:)));
		cf0stderr(nn) = cf0stddev(nn)/sqrt(length(stims));
		cf2mean(nn) = (abs(mean((c.fftvals{nn}(loc2,:)))));
		cf2stddev(nn) = std((c.fftvals{nn}(loc2,:)));
		cf2stderr(nn) = cf2stddev(nn)/sqrt(size(c.fftvals,2));
		cf1f0mean(nn) = abs(abs(mean(divide_nozero((c.fftvals{nn}(loc1,:)),(c.fftvals{nn}(1,:))-avg_rate))));
		cf1f0stddev(nn) = std(divide_nozero((c.fftvals{nn}(loc1,:)),(c.fftvals{nn}(1,:))-avg_rate));
		cf1f0stderr(nn) = cf1f0stddev(nn)/sqrt(length(stims));
		cf2f1mean(nn) = abs(abs(mean(divide_nozero((c.fftvals{nn}(loc2,:)),(c.fftvals{nn}(loc1,:))))));
		cf2f1stddev(nn) = std(divide_nozero((c.fftvals{nn}(loc2,:)),(c.fftvals{nn}(loc1,:))));
		cf2f1stderr(nn) = cf2f1stddev(nn)/sqrt(length(stims));
	end;
	cycg_f1curve{z} = [curve_x{z}; cf1meanc; cf1stddevc; cf1stderrc;];
	cycg_f2curve{z} = [curve_x{z}; cf2meanc; cf2stddevc; cf2stderrc;];
	cycg_f1f0curve{z} = [curve_x{z}; cf1f0meanc; cf1f0stddevc; cf1f0stderrc;];
	cycg_f2f1curve{z} = [curve_x{z}; cf2f1meanc; cf2f1stddevc; cf2f1stderrc;];
	f0curve{z} = [curve_x{z}; cf0mean; cf0stddev; cf0stderr;];
	f1curve{z} = [curve_x{z}; cf1mean; cf1stddev; cf1stderr;];
	f2curve{z} = [curve_x{z}; cf2mean; cf2stddev; cf2stderr;];
	f1f0curve{z} = [curve_x{z}; cf1f0mean; cf1f0stddev; cf1f0stderr;];
	f2f1curve{z} = [curve_x{z}; cf2f1mean; cf2f1stddev; cf2f1stderr;];
	f0vals{z} = cf0vals;
	f1vals{z} = cf1vals;
	f2vals{z} = cf2vals;
	f1f0vals{z} = cf1f0vals;
	f2f1vals{z} = cf2f1vals;
end % second stimulus parameter z

pc.internals.oldparams = p;
pc.internals.stims = stims;

pc.computations = struct('spont',spontval);
pc.computations.f0vals = f0vals; 
pc.computations.f1vals = f1vals;
pc.computations.f2vals = f2vals; 
pc.computations.f1f0vals = f1f0vals;
pc.computations.f2f1vals = f2f1vals;
pc.computations.vals2=vars; 
pc.computations.vals1 = vals;
pc.computations.curve = curve; 
pc.computations.rast = rast;
pc.computations.cycg_curve=cycg_curve; 
pc.computations.cycg_rast=cycg_rast;
pc.computations.cyci_curve=cyci_curve;
pc.computations.cyci_rast=cyci_rast;
pc.computations.spontrast = spontrast;
pc.computations.cycg_f1curve = cycg_f1curve; 
pc.computations.cycg_f2curve = cycg_f2curve;
pc.computations.cycg_f1f0curve = cycg_f1f0curve; 
pc.computations.cycg_f2f1curve = cycg_f2f1curve;
pc.computations.cyci_f1curve = cyci_f1curve; 
pc.computations.cyci_f2curve = cyci_f2curve;
pc.computations.cyci_f1f0curve = cyci_f1f0curve; 
pc.computations.cyci_f2f1curve = cyci_f2f1curve;
pc.computations.f1curve = f1curve; 
pc.computations.f2curve = f2curve;
pc.computations.f0curve = f0curve;
pc.computations.f1f0curve = f1f0curve; 
pc.computations.f2f1curve = f2f1curve;

pcn = pc;
