function A = cksmeasureddata(thedir, name, ref, desc_long, desc_brief);

%  CKSMEASOBJ = CKSMEASUREDDATA(THEDIR, NAME, REF)
%
%  Creates a new object for reading raw data in the cks format.  It needs the
%  directory that the data live in, the name of the record, and the reference
%  of the record.

   if exist(thedir)~=7,
       error([thedir ' does not exist.']);
   end;

   d = dir(thedir);
   
   md = measureddata([], desc_long, desc_brief);

   g = struct('thedir',thedir,'name',name, 'ref', ref,'tint',[],'dirlist',[],...
          'dirnames',[],'acq',[],'ckslen',10,'olddirlist',[]);

   A = class(g,'cksmeasureddata',md);

   [dummy,A] = get_intervals(A);

