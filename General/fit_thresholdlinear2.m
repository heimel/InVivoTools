function [rc, offset]=fit_thresholdlinear2(x,y,sigma,rc0,offset0)
%FIT_THRESHOLDLINEAR2 fits threshold linear function to data
%
%  [RC OFFSET]=FIT_THRESHOLDLINEAR2(X,Y,SIGMA,RC0,OFFSET0)
%
%
% 2005, Alexander Heimel
%

  
  if nargin<5
    offset0=0;
  end 
  if nargin<4
    p=polyfit(x,y,1);
    p(1)=p(1)*1;
    rc0=p(1);
    offset0=p(2);
  end
  if nargin<3
    sigma=ones(size(y));
  end

  
  min_err=inf;
  err=min_err;
  min_par=[];
  for i=1:20
    rc=rc0*(1.5*rand(1))^5;
    offset=offset0*(1.5*rand(1))^5;
  
    search_options=optimset('fminsearch');
    search_options.TolFun=1e-15;
    search_options.TolX=1e-2;
    %search_options.MaxFunEvals='100*numberofvariables';
    search_options.Display='off';
    [fit_par,fx,exitflag]=fminsearch('thresholdlinear_error',[rc offset],...
			      search_options,...
			      x,y,sigma);
    err=thresholdlinear_error([fit_par(1) fit_par(2)],x,y);
    if err<min_err
      min_par=fit_par;
      min_err=err;
    end
      
  end  
 rc=min_par(1);
 offset=min_par(2);


