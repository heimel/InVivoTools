function l=lgncontrast(c)

%Movshon et al. 2005
%l=b+k*log( 1 + c/c50)

%VanHooser et al. 2003
%c50=0.35;
%n=1;
%l=c.^n./(c50.^n+c.^n);

%linear
l=c;