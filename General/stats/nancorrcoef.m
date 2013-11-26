function [r,n,p,t_statistic,dof]=nancorrcoef(x,y)
%NANCORRCOEF two dimensional correlation coefficient ignoring NaN's
%
%  [R,N,P,T,DF]=NANCORRCOEF(X,Y)
%      R is correlation coefficient
%      N is number points where both are not NaN
%      P is significance with respect to null-hypothesis (chi-squared test)
%      T_STATISTIC is t-statistic
%      DOF is degrees of freedom
%
% Alexander Heimel?
%
  r=NaN;
  p=NaN;
  
  if size(x)~=size(y) & size(x)==size(y')
    y=y';
  end
  
  
  ind=find( ~isnan(x) & ~isnan(y));
  n=length(ind);
  
  if n<2
    return
  end
  
  
  c=corrcoef( x(ind),y(ind) );
  r=c(1,2);
  
  if abs(r)==1
    r=r*0.9999999;
  end
   
  
  t_statistic=r*sqrt( (n-2)/(1-r^2));
  dof = n -2 ;
  
  p=tcdf( -abs(t_statistic),dof)*2;
