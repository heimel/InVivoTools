function [tau,r, err]=fit_exponential(x,y)
%FIT_EXPONENTIAL fits exponential function to data
%
%  [TAU,R,ERR]=FIT_EXPONENTIAL(X,Y)
%
% only works for y = r exp(-t/tau) without offset
%
% 2009, Alexander Heimel
%

if max(y)<0
    signy = -1;
else 
    signy = 1;
end

y = signy*y;

%rectify y
y=thresholdlinear(y);

% remove nan from x & y
ind=find( ~isnan(x) & ~isnan(y) & y>0);
x=x(ind);
y=y(ind);

% sort x-values
[x,ind]=sort(x);
y=y(ind);

[rc,offset,err]=fit(x,log(y));

tau=1/rc;
r=exp(offset)*signy;


function [rc,offset,err]=fit(x,y)
    xp=x-mean(x);   
    b=mean(y);
    rc=mean(xp .* y)/mean(xp.*xp);
    offset=b-rc*mean(x);
    yf=rc*x+offset;
    err=(y-yf) * (y-yf)';

