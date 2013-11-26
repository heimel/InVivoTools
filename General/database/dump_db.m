function s = dump_db( db, h)
%DUMP_DB produces a semi-colon separated representation of db
%
%  S = DUMP_DB( DB )
%  S = DUMP_DB( DB , H )
%
%  2006-2013, Alexander Heimel
%

if nargin<2 % no figure given
  s=struct2char(db);
  if ~iscell(s)
    s={s};
  end

  for i=1:length(s)
    disp(s{i})
  end
else
  figure(h);axis off
  s=struct2char(db,';');
  if ~iscell(s)
    s={s};
  end
  for i=1:length(s)
    disp(s{i})
  end
  text(0,1,s,'VerticalAlignment','top')
end
