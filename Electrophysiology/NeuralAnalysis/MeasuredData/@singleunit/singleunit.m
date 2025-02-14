function A = singleunit(intervals, desc_long, desc_brief)

  sd = spikedata(intervals, desc_long, desc_brief);
   % this is an abstract class, so we have to create a dummy variable...grr...
  data = struct('abstract',1);

  A = class(data,'singleunit',sd);

end;
