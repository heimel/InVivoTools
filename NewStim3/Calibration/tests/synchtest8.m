function d = synchtest8(date, test,mult,arg1,arg2,arg3)

cksds=cksdirstruct(['/home/data/' date]);
g = load(getexperimentfile(cksds),'-mat');
gg = load(['/home/data/' date '/' test '/stims.mat']);
cs = ['cell_photo_0001_001_' date]; cs(find(cs=='-'))='_';
d = get_data(getfield(g,cs),[gg.start gg.MTI2{end}.frameTimes(end)]);

d = d(10:end); % ignore first 10 points

df = diff(d);
mn = mean(diff(d));  % get interval for first 20 triggers
if max(df)>1.5*mn, disp(['Warning: dropped pulse']); end;
if min(df)<0.5*mn, disp(['Warning: double-counted pulse']); end;

trig = [d(1) + (0:(length(d)-1))*mult] - 0.002;

disp(['Mean interval: ' mat2str(mn) '.']);
disp(['Number of triggers: ' int2str(length(trig)) '.']);

eval(['trig = trig(' arg1 ':' arg2 ':' arg3 ');']);

rainp.triggers = { trig };
rainp.spikes = getfield(g,cs);
rainp.condnames = { ['Test: ' test]};

where.figure=figure;where.rect=[0 0 1 1]; where.units='normalized';
ra = raster(rainp,'default',where);
p = getparameters(ra);
p.interval = [ 0 0.005]; p.cinterval = [ 0 0.005]; p.res = 1e-5;
p.fracpsth=0.5; p.showvar = 0;
ra = setparameters(ra,p);

set(gca,'fontsize',16');

 % to move bottom to left, increase mult; to move bottom to right, decrease mult
