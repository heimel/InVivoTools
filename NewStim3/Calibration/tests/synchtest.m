function synchtest(date, test, mult, ref)

%  SYNCHTEST - test synchronization of data and analysis
%
%  SYNCHTEST(DATE, TEST, MULT, REF)
%
%  Example:  synchtest('2003-02-12','t00032', 1.0000000);
%  REF is optional, default is 1

if nargin<4
  ref=1;
end

dt = date;
tst = test;
cn =sprintf('cell_photo_%04d_001_%s',ref, date);
cn(find(cn=='-'))='_';

cksds=cksdirstruct(['/home/data/' dt]);
g=load(getexperimentfile(cksds),'-mat');
blsgs = getstimscripttimestruct(cksds,tst);
blseq = stimtimestruct(blsgs,1);
gg = load(['/home/data/' dt '/' tst '/stims.mat'],'-mat');
blseq.mti = fudgemti2(blseq.mti,gg.start,1);

if 1,
%try, close(10); end;
blseq.mti = fudgemti2(blseq.mti,gg.start,mult);
v = getgridvalues(blseq.stim);
j = find(v(1,:)==1);

frameTimes = blseq.mti{1}.frameTimes(j(1:100));
rainp.triggers = {frameTimes};
rainp.spikes = getfield(g,cn);

if 1,
bins = 0:1e-5:5e-3;
[rast,psth] = fastraster(rainp.spikes,rainp.triggers{1},bins,0);
figure;
rast_x = []; rast_y = [];
for i=1:size(rast,1),
	ind = find(rast(i,:));
	if ~isempty(ind),
		rast_x = [rast_x bins(ind);];
		rast_y = [rast_y repmat(i,1,length(ind))];
	end;
end;
ax1 = axes('position',[0.1 0.1 0.8 0.4]);
bar(bins(1:end-1),psth); 
a = axis;
axis([bins(1) bins(end) a(3) a(4)]);
ax2 = axes('position',[0.1 0.5 0.8 0.4]);
plot(rast_x,rast_y,'k.','markersize',2);
title(['Test: ' test]);
axis([bins(1) bins(end) 0 size(rast,1)]);
set(gca,'xtick',[],'ydir','reverse','yaxislocation','right');
else,
	rainp.condnames= {['synchtest: ' test]};

	where2.figure=figure;where2.rect=[0 0 1 1];where2.units='normalized';
	ra = raster(rainp,'default',where2);
	p=getparameters(ra);
	%p.interval=[0 0.005]; p.cinterval=[0 0.005]; p.res=1e-5; p.showvar=0;
	p.interval=[0 0.015]; p.cinterval=[0 0.015]; p.res=1e-5; p.showvar=0;
	p.fracpsth=0.5;
	ra = setparameters(ra,p)
end;
end;
