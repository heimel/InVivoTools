function [meanwaves,T]=lgnctxcsd_pulse_field(cksds,test,pulsedata,ref,t0,t1,sampmult)

% LGNCTXCSD_PULSE_FIELD - Computes pulse response image in field potentials
%
%  [MEANWAVES,T]=LGNCTXCSD_PULSE_FIELD(CKSDS,TEST,PULSEDATA,REF,T0,T1)
%
%  Computes the field potential as a function of depth for data recorded with
%  16 channel probes.  Data are assumed to come from a CKSDIRSTRUCT CKSDS, in
%  the test directory TEST.  PULSEDATA is a SPIKEDATA object containing pulse
%  times.  REF is the reference number of the recording.  It is assumed that
%  each channel is recorded using the name/ref pair 'ctxF#'/REF, where # is
%  the raw channel number.  Field potential is computed in a window (T0,T1)
%  around each pulse trigger.
%

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

trigs = get_data(pulsedata,sts.mti{1}.startStopTimes([1 4]));
trigs= trigs(find(trigs<sts.mti{1}.startStopTimes(4)-t1)); % exclude late spikes
T = []; dt = [];

segs = (trigs(1)+t0):30:(trigs(end)+t1);

probechanlist=[1 9 2 10 5 13 4 12 7 15 8 16 7 14 3 11];

for i=1:16,
  for k=1:length(segs)-1,
	z = find(trigs>=segs(k)&trigs<segs(k+1));
	if ~isempty(z),
		[data,tt]=get_data(cksmd{probechanlist(i)},...
				[trigs(z(1))+t0 trigs(z(end))+t1+0.1]);
		data=data(1:sampmult:end); tt=tt(1:sampmult:end);
		if isempty(T),dt=tt(2)-tt(1);T=t0:dt:t1;
			for jj=1:16, meanwaves{jj}=zeros(1,length(T)); end;
		end;
		si=1+round((trigs(z)-tt(1)+t0)/dt);
		meanwaves{i}=meanwaves{i}+contsumwaveshelper(data,si,...
			ones(1,length(z)),1,length(T));
	end;
  end;
  meanwaves{i} = meanwaves{i}/length(trigs);
end;
