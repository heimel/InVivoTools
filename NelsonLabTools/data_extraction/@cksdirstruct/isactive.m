function b = isactive(cksds, dirname)

%  B = ISACTIVE(MYCKSDIRSTRUCT, DIRNAME)
%
%  Returns 1 if 'DIRNAME' is an active directory in the CKSDIRSTRUCT
%  MYCKSDIRSTRUCT.  DIRNAME may also be a cell list, in which case b will
%  be a 0/1 vector of the same length as the cell list.
b = zeros(length(dirname),1);
if ischar(dirname),
  [dummy,g]=intersect(cksds.active_dir_list,dirname);
  b=~isempty(g);
else,
  for i=1:length(dirname),
     [dummy,g]=intersect(cksds.active_dir_list,dirname{i});
     b(i)=~isempty(g);
  end;
end;
