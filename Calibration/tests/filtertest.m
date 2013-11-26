[b,a]=cheby1(4,0.8,[300/15000 5000/15000]);

t0 = clock;
for i=1:37,
	fname = ['/home/data/2001-02-27/t007/r' sprintf('%0.3d',1) '_ctx'];
	g = loadIgor(fname);
	newg = filtfilt(b,a,g);
end;
t1 = clock;
etime(t1,t0)/37
