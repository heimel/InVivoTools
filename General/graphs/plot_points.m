function hp = plot_points(x,r,spaced)
%PLOT_POINTS plots points in bar plot, helper function for IVT_GRAPH
%
%  HP = PLOT_POINTS(X, R, SPACED)
%
%     SPACED = 0, not spaced
%              1, spaced, skipping NaNs
%              2, spaced, not skippping nans?
%              3, randomly spaced as close as possible to central axis
%
% 200X-2017, Alexander Heimel

rnonnan=r(~isnan(r));
if length(r)==1
    spaced = 0; % to center
end
options = 'ok';

if ~isempty(rnonnan)
    switch(spaced)
        case 0
            hp = plot(x(:),r(:),options);
        case 1 % show spaced
            w = 0.3;
            hp = plot(x+linspace(-w,w,length(rnonnan)),rnonnan,'ok');
        case 2 % show spaced keeping relatively position of points in place
            w = 0.3;
            hp = plot(x+linspace(-w,w,length(r)),r,'ok');
        case 3 % randomly spaced as close as possible to central axis
            x = x + spacepoints( r);
            hp = plot(x,r,'ok');
        otherwise
            disp( ['Option spaced=' num2str(spaced) ' is unknown.']);
    end
end




function x = spacepoints( y,dmin,yl,xl,xw)
% Y is a single column vector
% DMIN is minimum distance
% YL is ylimit of axis
% XL is xlimit of axis
% XW is
%

maxsteps = 1000;

scurr = rng; % store current random seed
rng(0); % make plot reproducible

if nargin<5 || isempty(xw)
    xw = 0.8;
end


if nargin<4 || isempty(xl)
    xl = xlim;
end
if nargin<3 || isempty(yl)
    yl = ylim;
end
if nargin<2 || isempty(dmin)
    dmin = 0.03;
end

if size(y,2)>size(y,1)
    y = y';
end

[y,ind] = sort(y);
y = (y - yl(1))/ (yl(2)-yl(1));

n = length(y);

my = repmat(y,1,n);
dy = my - my'; % y distance matrix
jx = rand(n,1)+0.5;  % jitter vector

eps = 0.0001 * (xl(2)-xl(1));
x = ones(n,1);
x(2:2:end) = -1;
x = eps*x.*rand(n,1);

touching = true;
steps = 0;

while touching && steps<maxsteps
    mx = repmat(x,1,n);
    dx = mx - mx';
    d = sqrt(dx.^2 + dy.^2);
    t = (d<dmin);
    touching = sum(t(:))-n; % subtracting diagonal
    left = (dx>0);
    right = (dx<0);
    forceleft = sum( t.*left,2);
    forceright = sum( t.*right,2);
    force =  forceleft - forceright;
    jx = [jx(2:end); jx(1)];
    if ~t(1,end) % first a nd last are not touching
        x(2:end-1) = x(2:end-1) + 0.08*force(2:end-1).*jx(2:end-1)*dmin;
    else
        x = x + 0.5*force.*jx*dmin;
    end
    steps = steps + 1;
end

if steps == maxsteps
    x  = x / max(abs(x))*xw/2;
end

x(ind) = x;
rng(scurr); % re-set random seed



