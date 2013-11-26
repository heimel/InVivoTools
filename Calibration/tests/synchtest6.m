cksds=cksdirstruct('/home/data/2003-02-13')
g=load(getexperimentfile(cksds),'-mat')
blsgs = getstimscripttimestruct(cksds,'t00003')
blseq = stimtimestruct(blsgs,1)
gg = load('/home/data/2003-02-13/t00003/stims.mat','-mat');
gg.start,
%blseq.mti = fudgemti2(blseq.mti,gg.start,0.99375);
blseq.mti = fudgemti2(blseq.mti,gg.start,1);

if 0,
try, close(3); end;
inp.spikes = { g.cell_photo_0001_001_2002_09_10};
inp.stimtime = blseq;
inp.cellnames = { ' test ' };
where.figure=3;where.rect=[0 0 1 1];where.units='normalized';
rc = reverse_corr(inp,'default',where);
end;

if 0,
frameTimes = blseq.mti{1}.frameTimes;
rainp.triggers = { frameTimes};
rainp.spikes = g.cell_photo_0001_001_2002_09_10;
rainp.condnames= {'test'};

where2.figure=2;where2.rect=[0 0 1 1];where2.units='normalized';
ra = raster(rainp,'default',where2);

end;


if 1,
try, close(10); end;
blseq.mti = fudgemti2(blseq.mti,gg.start,0.9999915);
v = getgridvalues(blseq.stim);
j = find(v(1,:)==1);

frameTimes = blseq.mti{1}.frameTimes(j(2:50:end));
rainp.triggers = { frameTimes};
rainp.spikes = g.cell_photo_0001_001_2003_02_13;
rainp.condnames= {'test'};

where2.figure=10;where2.rect=[0 0 1 1];where2.units='normalized';
ra = raster(rainp,'default',where2);
p=getparameters(ra);
p.interval=[0 0.005]; p.cinterval=[0 0.005]; p.res=1e-5; p.showvar=0;
p.fracpsth=0.5;
ra = setparameters(ra,p)
end;
