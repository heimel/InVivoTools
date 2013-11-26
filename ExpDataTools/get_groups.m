function groupss = get_groups( groups, groupdb )
%GET_groupS gets group-structs by name from groupdb
%
% groupSS = GET_groupS( groupS )
% groupSS = GET_groupS( groupS, groupDB )
%
% 2007, Alexander Heimel
%

if nargin<2
  groupdb=[];
end
if isempty(groupdb)
  groupdb=load_groupdb;
end
if ~iscell(groups)
  groups={groups};
end
n_groups=length(groups);
ind=[];
for m=1:n_groups
  ind=[ind find_record(groupdb,['name~' groups{m}])];
end
groupss=groupdb(ind);


