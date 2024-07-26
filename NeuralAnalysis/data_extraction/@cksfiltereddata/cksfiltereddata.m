function A = cksmeasureddata(thedir, name, ref, filtertype, filterarg, desc_long, desc_brief);

%  CKSFILTOBJ = CKSFILTEREDDATA(THEDIR, NAME, REF, FILTERTYPE, FILTERARG,...
%              DESC_LONG, DESC_BRIEF)
%
%  Creates a new object for reading filtered data in the cks format.  It needs the
%  directory that the data live in, the name of the record, and the reference
%  of the record.
%
%  FILTERTYPE describes the type of filter to be used, and FILTERARG (FA)is the argument
%  for the filter.
%    0=> no filtering
%    1=> convolution, FA is argument to matlab function conv
%    2=> cheby1, FA is low and high cut off
%    3=> spike removal with linear interpolation
%        FA is struct:
%        t0  -  time before a spike to remove
%        t1  -  time after a spike to remove
%        spiketimes - a list of spiketimes

   if exist(thedir)~=7,
       error([thedir ' does not exist.']);
   end;

   d = dir(thedir);
   
   md = cksmeasureddata(thedir,name, ref, desc_long, desc_brief);

   g = struct('thedir',thedir,'name',name, 'ref', ref,'filtermethod',filtertype,...
          'filterarg',filterarg,'tint',[],'dirlist',[],'dirnames',[],'acq',[],...
		  'ckslen',10,'olddirlist',[]);

   A = class(g,'cksfiltereddata',md);

   [dummy,A] = get_intervals(A);

