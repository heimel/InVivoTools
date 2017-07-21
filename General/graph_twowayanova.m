function [p,tbl,stats] = graph_twowayanova( values,levels )
%GRAPH_TWOWAYANOVA computers two way anova interactions
%
% GRAPH_TWOWAYANOVA( values, levels)
%     levels is a vector with the number of levels in each of the two
%     groups. Except are that the data are first all of level 1 of group 1,
%     which different levels of group 2, then all data of level 2 of group
%     1, etc.
%
% 2017, Alexander

if nargin<2 || isempty(levels)
   levels = [2 2];
end

p = [];
tbl = [];
stats = [];

n_values = length(values);

if n_values~=prod(levels)
    errormsg(['Number of value groups do not much the number of different levels (' num2str(prod(levels)) ')']);
    return
end

i = 1;
g1 = [];
g2 = [];

for v1 = 1:levels(1)
    for v2 = 1:levels(2)
        n(i) = length(values{i});
        g1 = [g1; v2*ones(n(i),1)];
        g2 = [g2; v1*ones(n(i),1)];
        i = i+1;
    end % v2
end % v1

[p,tbl,stats] = anovan( flatten(values)',{g1,g2},'model','interaction','display','off' );
logmsg(['Source 1   : p = ' num2str(p(1),2) ', F = ' num2str(tbl{2,6},2)]);
logmsg(['Source 2   : p = ' num2str(p(2),2) ', F = ' num2str(tbl{3,6},2)]);
logmsg(['Interaction: p = ' num2str(p(3),2) ', F = ' num2str(tbl{4,6},2)]);

ctype = 'tukey-kramer';
results = multcompare(stats,'Dimension',[1 2],'ctype' ,ctype,'display','off');
for i=1:size(results,1)
    logmsg(['group ' num2str(results(i,1)) ' vs group ' num2str(results(i,2)) ': p = ' num2str(results(i,6),2) ' posthoc ' ctype  ]);
end

