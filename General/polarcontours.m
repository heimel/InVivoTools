function polarcontours(r,t,z,n)
%POLARCONTOURS polar contour where colour is set by color at center of voronoid
%
% POLARCONTOURS(R,T,Z,[N])
% 
%   see CONTOURF 
%
% 2019, Alexander Heimel

if nargin<4
    n = [];
end

xp = r.* cos(t);
yp = r.* sin(t);

ns = 500;
xc = linspace(-1,1,ns);
yc = linspace(-1,1,ns);
[X,Y] = meshgrid(xc,yc);
zc = zeros(size(X));
for i=1:length(xc)
    for j = 1:length(yc)
        x = xc(i);
        y = yc(j);
        d = (xp-x).^2 + (yp-y).^2;
        [~,ind] = min(d(:));
        zc(j,i) = z(ind);
    end
end

if isempty(n)
    contourf(X,Y,zc);
else
    contourf(X,Y,zc,n);
end
axis square image off
c = get(gca,'children');
set(c,'linestyle','none');
set(gca,'ydir','reverse') % to fit with movie


