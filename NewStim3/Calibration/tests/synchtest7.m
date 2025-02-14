cksds=cksdirstruct('/home/data/2002-10-28')
g=load(getexperimentfile(cksds),'-mat')
blsgs = getstimscripttimestruct(cksds,'t00006')
blseq = stimtimestruct(blsgs,1)
gg = load('/home/data/2002-10-28/t00006/stims.mat','-mat');
gg.start,
%blseq.mti = fudgemti2(blseq.mti,gg.start,0.99375);
blseq.mti = fudgemti2(blseq.mti,gg.start,1);

if 0,
try, close(3); end;
inp.spikes = { g.cell_photo_0001_001_2002_10_28};
inp.stimtime = blseq;
inp.cellnames = { ' test ' };
where.figure=3;where.rect=[0 0 1 1];where.units='normalized';
rc = reverse_corr(inp,'default',where);
end;

if 0,
frameTimes = blseq.mti{1}.frameTimes;
rainp.triggers = { frameTimes};
rainp.spikes = g.cell_photo2_0001_001_2002_10_28;
rainp.condnames= {'test'};

where2.figure=2;where2.rect=[0 0 1 1];where2.units='normalized';
ra = raster(rainp,'default',where2);

end;

get_intervals(g.cell_photo2_0001_001_2002_10_28),
g=load(getexperimentfile(cksds),'-mat')
if 1,
try, close(10); end; 
%0.99975 slight left
%0.99970 right
%0.99973 right
%0.99974 right
%0.999745 right
%0.999747 left
%0.999746 right


blseq.mti = fudgemti2(blseq.mti,gg.start,0.9997465);
v = getgridvalues(blseq.stim);
j = find(v(1,:)==1);

frameTimes = blseq.mti{1}.frameTimes(j(1:10:end));
rainp.triggers = { frameTimes};
rainp.spikes = g.cell_photo2_0001_001_2002_10_28;
rainp.condnames= {'test'};

where2.figure=10;where2.rect=[0 0 1 1];where2.units='normalized';
ra = raster(rainp,'default',where2);
p=getparameters(ra);
p.interval=[-0.05 0.1]; p.cinterval=[-0.0 0.1];p.showvar=0;p.res=0.5e-4;
ra = setparameters(ra,p)
end;
