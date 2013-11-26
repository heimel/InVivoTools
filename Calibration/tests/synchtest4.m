cksds=cksdirstruct('/home/data/2002-06-09')
g=load(getexperimentfile(cksds),'-mat')
blsgs = getstimscripttimestruct(cksds,'t00004')
blseq = stimtimestruct(blsgs,1)
gg = load('/home/data/2002-06-09/t00004/stims.mat','-mat');
%blseq.mti = fudgemti2(blseq.mti,gg.start,0.99375);

if 0,
try, close(3); end;
inp.spikes = { g.cell_photo_0003_001_2002_04_29};
inp.stimtime = blseq;
inp.cellnames = { ' test ' };
where.figure=3;where.rect=[0 0 1 1];where.units='normalized';
rc = reverse_corr(inp,'default',where);
end;

if 0,
frameTimes = blseq.mti{1}.frameTimes;
rainp.triggers = { frameTimes};
rainp.spikes = g.cell_photo_0001_001_2002_06_09;
rainp.condnames= {'test'};

where2.figure=2;where2.rect=[0 0 1 1];where2.units='normalized';
ra = raster(rainp,'default',where2);

end;

if 1,
try, close(10); end;
%blseq.mti = fudgemti2(blseq.mti,gg.start,0.9937);
v = getgridvalues(blseq.stim);
j = find(v(172,:)==1);

frameTimes = blseq.mti{1}.frameTimes(j);
frameTimes = frameTimes(2:400);
rainp.triggers = { frameTimes};
rainp.spikes = g.cell_photo_0001_001_2002_06_09;
rainp.condnames= {'test'};

where2.figure=10;where2.rect=[0 0 1 1];where2.units='normalized';
ra = raster(rainp,'default',where2);

end;
