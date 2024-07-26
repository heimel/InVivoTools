function noisedata=removeevents(data)
%REMOVEEVENTS removes all outlier events

stddev=std(data);
n_channels=size(data,2);

events=[];
for ch=1:n_channels
  events=union(find(abs(data(:,ch))>3*stddev(ch)),events);
end

broadevents=[];
ev=(-20:20);
for i=1:size(events)
     broadevents=union(broadevents,ev+events(i));
end

nonevents=setdiff( (1:size(data,1)),broadevents);

noisedata=data(nonevents,:);

