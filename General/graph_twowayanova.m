function [p,tbl,stats] = graph_twowayanova( values )

p = [];
tbl = [];
stats = [];

if length(values)~=4
    errormsg('Need four groups');
    return
end

for i=1:length(values)
    n(i) = length(values{i});
end

g1 = [zeros(1,n(1)+n(2)) ones(1,n(3)+n(4))];
g2 = [zeros(1,n(1)) ones(1,n(2)) zeros(1,n(3)) ones(1,n(4))];


[p,tbl,stats] = anovan( flatten(values)',{g1,g2},'model','interaction','display','off' );
logmsg(['Source 1   : p = ' num2str(p(1),2)]);
logmsg(['Source 2   : p = ' num2str(p(2),2)]);
logmsg(['Interaction: p = ' num2str(p(3),2)]);

