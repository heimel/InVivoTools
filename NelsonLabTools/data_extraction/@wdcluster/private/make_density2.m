function make_density2(x,maxNumDiv,nsigma,sigma)

global f;
global K;

xmax = max(x);	% 1x4
xmin = min(x);

% sigma*nsigma for grid size
dx  = sigma*nsigma;
dim = ceil( (xmax - xmin)./dx) + 1	% 1x4
dim = (dim > maxNumDiv)*maxNumDiv + (dim <= maxNumDiv).*dim;

dim2 = dim + 6; % expand for addition
f = zeros(dim2);

idx = -3:3;
[x1,x2,x3,x4] = ndgrid(idx);
g = exp(-(x1.^2+x2.^2+x3.^2+x4.^2));

dxtmp = (xmax - xmin)./(dim-1);
dx = (dx > dxtmp).*dx + (dx <= dxtmp).*dxtmp;	% take larger one

I    = ones(size(x,1),1);
% K    = floor((x - xmin(I,:))./dx(I,:)) + 1 + 3;
K    = round((x - xmin(I,:))./dx(I,:)) + 1 + 3;

for i=1:size(x,1)
	st = K(i,:) - 3;
	ed = K(i,:) + 3;
	f(st(1):ed(1),st(2):ed(2),st(3):ed(3),st(4):ed(4)) =...
	f(st(1):ed(1),st(2):ed(2),st(3):ed(3),st(4):ed(4))+g;
end
