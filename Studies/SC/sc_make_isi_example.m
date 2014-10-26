load('singleunitC');

max_spikes = 10000;
max_interval = 0.05;

spikes1 = repmat( Ctime(1:min(end,max_spikes))',...
    length(Ctime(1:min(end,max_spikes))),1);
spikes2 = repmat( Ctime(1:min(end,max_spikes)),...
    1,length(Ctime(1:min(end,max_spikes))));
intervals = flatten(spikes2-spikes1);
intervals(intervals==0) = [];


intervals = intervals(abs(intervals)<max_interval);

xl = [-0.05 0.05];
x = xl(1):0.001:xl(2);

hist(1000*intervals,x*1000);
xlabel('Inter spike time (ms)');
ylabel('Count');
xlim(xl*1000);
