function [rc, offset, err]=fit_thresholdlinear(x,y)
%FIT_THRESHOLDLINEAR fits threshold linear function to data without
%parameter search
%
%  [RC OFFSET]=FIT_THRESHOLDLINEAR(X,Y)
%
%
% 2006, Alexander Heimel
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

[rc,offset,err]=fit(x,y);

if length(x)<3
    % too few points to leave any out
    return
end

% now make sure that line is going down
if rc>0 
    [x,ind]=sort(-x);
    x=-x;
    y=y(ind);
end



% now leave more and more points out at the end,
% fit a line through the remaining points and see
% if this improves the fit
for i=length(x)-1:-1:2
    [trc,toffset,terr]=fit(x(1:i),y(1:i));
    terr=terr+y(i+1:end)*y(i+1:end)';
    if trc==0
      tcutoff=nan;
    else
      tcutoff= -toffset/ trc;
    end
    % make sure that new cutoff is between left out number and last one in
    if (rc<0 & tcutoff<x(i+1) & trc*rc>0 ) | (rc>0 & tcutoff>x(i+1) & trc*rc>0)
        if terr<err
            rc=trc;offset=toffset;terr=err;
        end
    end
end

if 0
  plot( x, y, 'ro');
  hold on
  xs=linspace( min(x),max(x),100);
  plot(xs, thresholdlinear(rc*xs+offset));
  hold off
end

function [rc,offset,err]=fit(x,y)
    xp=x-mean(x);   
    b=mean(y);
    rc=mean(xp .* y)/mean(xp.*xp);
    offset=b-rc*mean(x);
    yf=thresholdlinear(rc*x+offset);
    err=(y-yf) * (y-yf)';

