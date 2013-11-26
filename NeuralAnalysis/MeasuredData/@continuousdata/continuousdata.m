function A = continuousdata(intervals, desc_long, desc_brief)

%  CONTINUOUSDATA
%
%  CONTINUOUSDATA is an abstract descendent of MEASUREDDATA.
%  If an object is a descendent of CONTINUOUSDATA, then its
%  data will have been continuously measured.

  md = measureddata(intervals,desc_long,desc_brief);
  data = struct('abstract',1);
  A = class(data,'continuousdata',md);
