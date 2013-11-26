function [exponent,r, err]=fit_powerlaw(x,y)
%FIT_POWERLAW fits powerlaw function to data
%
%  [EXPONENT,R,ERR]=FIT_POWERLAW(X,Y)
%
%
% 2009, Alexander Heimel
%

%rectify y
y=thresholdlinear(y);

% remove nan from x & y
ind=find( ~isnan(x) & ~isnan(y));
x=x(ind);
y=y(ind);

% sort x-values
[x,ind]=sort(x);
y=y(ind);

[rc,offset,err]=fit(log(x),log(y));

exponent=rc;
r=exp(offset);


function [rc,offset,err]=fit(x,y)
    xp=x-mean(x);   
    b=mean(y);
    rc=mean(xp .* y)/mean(xp.*xp);
    offset=b-rc*mean(x);
    yf=rc*x+offset;
    err=(y-yf) * (y-yf)';

