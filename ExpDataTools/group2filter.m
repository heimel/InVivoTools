function filt=group2filter(group, groupdb)
%GROUP2FILTER constructs a filter string from group name
%
%  FILT = GROUP2FILTER( GROUP )
%  FILT = GROUP2FILTER( GROUP, GROUPDB )
%        GROUP can be the groupname or the grouprecord
%
%
% 2007, Alexander Heimel
%

if nargin<2;groupdb=[];end

if isempty(groupdb)
  groupdb=load_groupdb;
end

if ischar(group)
  % then replace group by its grouprecord 
  ind=find_record(groupdb,['name~' group]);
  if isempty(ind)
    filt='';
    error(['Could not find group ' group ]);
    return
  end
  group=groupdb(ind);
end


filt=group.filter;
if ~isempty(filt)
  filt=['(' filt ')'];
end

combine=split(group.combine);

while ~isempty(combine)
  addfilt=group2filter(trim(combine{1}),groupdb);
  if isempty(filt)
    filt=addfilt;
  elseif ~isempty(addfilt)
    filt=[filt ',' addfilt ];
  end
  combine={combine{2:end}};
end
