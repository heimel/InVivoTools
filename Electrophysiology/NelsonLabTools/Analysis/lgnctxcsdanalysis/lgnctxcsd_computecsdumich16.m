function [csdinds,sampletimes,fieldsind]=lgnctxcsd_computecsdumich16(cksds,ref,triggers,t0,t1,timeres)

% LGNCTXCSD_COMPUTECSD - Compute current source density
%[CSD,CSDMEAN,CSDSTD]=LGNCTXCSD_COMPUTECSD(CKSDS,NAMEREFS,TRIGGERS,...
%		T0,T1,TIMERES)
%  

  % assumes single addition,subtract,multiplication

sampletimes=t0:timeres:t1;

fieldsind=single(zeros(length(sampletimes),16,length(triggers)));
csdinds=single(zeros(length(sampletimes),16,length(triggers)));

 % can make cell index over triggers or depth or both
thedir = getpathname(cksds);

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

probechanlist=[1 9 2 10 5 13 4 12 7 15 8 16 7 14 3 11];

for j=1:16,
	j,
	[fieldsind(:,probechanlist(j),:)]=single(raster_continuous(cksmd{j},...
		triggers,t0,t1,timeres))';
end;

  % compute csd
csdinds(:,2:15,:)=(fieldsind(:,1:14,:)+fieldsind(:,3:16,:)-...
		fieldsind(:,2:15,:))./(1e-8);
		% CSD = (V(i+1)+V(i-1)+V(i))/(dX*dX)
