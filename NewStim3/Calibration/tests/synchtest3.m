cksds=cksdirstruct('/home/data/2001-10-17')
g=load(getexperimentfile(cksds),'-mat')
blseqst = getstimscripttimestruct(cksds,'t00015')
blseq = stimtimestruct(blseqst,1)
blranst = getstimscripttimestruct(cksds,'t00011')
blran = stimtimestruct(blranst,1)
blsgsst = getstimscripttimestruct(cksds,'t00012')
blsgs = stimtimestruct(blsgsst,1)

inp.spikes = { g.cell_photo_0001_001_2001_10_17};
inp.stimtime = blsgs;
inp.cellnames = { ' test ' };
where.figure=1;where.rect=[0 0 1 1];where.units='normalized';
rc = reverse_corr(inp,'default',where);

frameTimes = blseq.mti{1}.frameTimes;
rainp.triggers = { frameTimes};
rainp.spikes = g.cell_photo_0001_001_2001_10_17;
rainp.condnames= {'test'};

where2.figure=2;where2.rect=[0 0 1 1];where2.units='normalized';
ra = raster(rainp,'default',where2);

v = getgridvalues(blseq.stim);
j = find(v(42,:)==2);

frameTimes = blseq.mti{1}.frameTimes(j);
rainp.triggers = { frameTimes};
rainp.spikes = g.cell_photo_0001_001_2001_10_17;
rainp.condnames= {'test'};

where2.figure=2;where2.rect=[0 0 1 1];where2.units='normalized';
ra = raster(rainp,'default',where2);


