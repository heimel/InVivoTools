%This function replaces a 0 by log10(1) and everything else by log10(in)  
function out = mylog(in)
  if (in <=0) out = log10(1); else out = log10(in); end
