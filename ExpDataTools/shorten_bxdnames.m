function names=shorten_bxdnames( names )
%SHORTEN_BXDNAMES replaces full BXD name by 2-letter code
%
% 2007, Alexander Heimel

if ~iscell(names)
  names={names};
end

for i=1:length(names)
  group=names{i};
  k=findstr(group,'BXD-');
  if ~isempty(k)
    group=group(k+4:end);
  end
  k=findstr(group,'C57');
  if ~isempty(k)
    group='B6';
  end
  k=findstr(group,'DBA');
  if ~isempty(k)
    group='D2';
  end
  names{i}=group;
end

