% Resolution: number of point the estimated curve has to be fitted do, I
% don't feel like annoying the rest of the show with the actual params at
% this point.
%
% This file works on a single-channel basis

function [log_i50 max_response xfit yfit] = erg_analysis_fit(stims, bwaveamplitudes, resolution)
  y=bwaveamplitudes; 
  x=stims;
  x=x/max(x);

  b=median(x);
  n=1;
  m=2;
  rm=max(y(:))*(b^m+max(x)^m)/max(x)^n;

  [rm,b,n,m,exitflag] = naka_rushton(x,y,[rm b n n]);

  if exitflag~=1
    disp('no convergence');
    log_i50 = 0;
    xfit=logspace(log10(min(x)),log10(max(x)),resolution);
    brob = robustfit(x,y);
    yfit = brob(1)+brob(2)*xfit;
    xfit = xfit * max(stims);
    max_response=max(yfit);
    return;
   end

   xfit=logspace(log10(min(x)),log10(max(x)),resolution);
   yfit=rm * xfit.^n./(b^m + xfit.^m);
   xfit = xfit * max(stims);
   [maxyfit,ind]=max(yfit);
   i50=xfit(find(yfit>maxyfit/2,1));
   log_i50=log10(i50);
   max_response=maxyfit; 
  