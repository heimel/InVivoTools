function g=contrastmod( c,n, k, sigma)
%CONTRASTMOD g= (c.^n )/ (sigma^n + k^n * c.^n);
%
%  g=contrastmod( c,n, k, sigma)


g= (c.^n )./ (sigma^n + k^n * c.^n);


