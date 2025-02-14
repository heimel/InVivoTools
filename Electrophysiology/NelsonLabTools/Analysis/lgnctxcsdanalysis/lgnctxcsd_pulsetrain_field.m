function [meanwaves,T,pulsetimes]=lgnctxcsd_pulsetrain_field(cksds,test,pulsedata,ref,t0,t1,sampmult)

% LGNCTXCSD_PULSETRAIN_FIELD - Computes pulse response image in field potentials
%
%  [MEANWAVES,T]=LGNCTXCSD_PULSETRAIN_FIELD(CKSDS,TEST,PULSEDATA,REF,T0,T1,SAMPMULT,...
%		NUMPULSES,STARTPULSE)
%
%  Computes the field potential as a function of depth for data recorded with
%  16 channel probes.  Data are assumed to come from a CKSDIRSTRUCT CKSDS, in
%  the test directory TEST.  PULSEDATA is a SPIKEDATA object containing pulse
%  times.  REF is the reference number of the recording.  It is assumed that
%  each channel is recorded using the name/ref pair 'ctxF#'/REF, where # is
%  the raw channel number.  Field potential is computed in a window (T0,T1)
%  around each pulse trigger.  Only every SAMPMULT data point is analyzed (e.g.,
%  to analyze 1/50th of the data, set SAMPMULT to 50); this helps to save memory
%  and computing time for densely-sampled data.  NUMPULSES is the number of pulses that
%  are repeated.  STARTPULSE is the pulse number to start with.

sts=getstimscripttimestruct(cksds,test);
thedir = getpathname(cksds);

  % open records to all files
cksmd{1}  = cksmeasureddata(thedir,'ctxF1',ref,[],[]);
cksmd{2}  = cksmeasureddata(thedir,'ctxF2',ref,[],[]);
cksmd{3}  = cksmeasureddata(thedir,'ctxF3',ref,[],[]);
cksmd{4}  = cksmeasureddata(thedir,'ctxF4',ref,[],[]);
cksmd{5}  = cksmeasureddata(thedir,'ctxF5',ref,[],[]);
cksmd{6}  = cksmeasureddata(thedir,'ctxF6',ref,[],[]);
cksmd{7}  = cksmeasureddata(thedir,'ctxF7',ref,[],[]);
cksmd{8}  = cksmeasureddata(thedir,'ctxF8',ref,[],[]);
cksmd{9}  = cksmeasureddata(thedir,'ctxF9',ref,[],[]);
cksmd{10} = cksmeasureddata(thedir,'ctxF10',ref,[],[]);
cksmd{11} = cksmeasureddata(thedir,'ctxF11',ref,[],[]);
cksmd{12} = cksmeasureddata(thedir,'ctxF12',ref,[],[]);
cksmd{13} = cksmeasureddata(thedir,'ctxF13',ref,[],[]);
cksmd{14} = cksmeasureddata(thedir,'ctxF14',ref,[],[]);
cksmd{15} = cksmeasureddata(thedir,'ctxF15',ref,[],[]);
cksmd{16} = cksmeasureddata(thedir,'ctxF16',ref,[],[]);

[triggers,pulsetimes,numpulses,n]=lgnctxcsd_extractpulsetrains(cksds,test,pulsedata);
T = []; dt = [];

segs = unique([triggers(1,1):30:triggers(end,end) triggers(end,end)+0.0001]);

probechanlist=[1 9 2 10 5 13 4 12 7 15 8 16 7 14 3 11];
counts = zeros(1,numpulses);

for i=1:16,
	i,
	for k=1:length(segs)-1,
		[zi,zj] = find(triggers>=segs(k)&triggers<segs(k+1));
		trigs = diag(triggers(zi,zj));
		if ~isempty(trigs),
			[data,tt]=get_data(cksmd{probechanlist(i)},[min(trigs)+t0 max(trigs)+t1+0.1]);
			data=data(1:sampmult:end); tt=tt(1:sampmult:end);
			if isempty(T),
				dt=tt(2)-tt(1);T=t0:dt:t1;
			    for jj=1:16, meanwaves{jj}=zeros(numpulses,length(T)); end;
			end;
		end;
		si=1+round((trigs-tt(1)+t0)/dt);
		meanwaves{i}=meanwaves{i}+contsumwaveshelper(data,si,zj,numpulses,length(T));
	end;
	meanwaves{i} = meanwaves{i}/n;
end;


