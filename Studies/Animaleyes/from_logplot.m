function x=from_logplot(lx, from, base, unit) 
%FROM_LOGPLOT converts measured distant to value on logplot
%  
%  X=FROM_LOGPLOT(LX, FROM, BASE, UNIT) 
%    LX measured distance from FROM
%    BASE is base of logplot, UNIT is distance
%    from BASE to BASE^2
  
  x=from*base.^(lx/unit);
