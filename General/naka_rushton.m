function [rm,b,n,explained_variance,c50,r_at_c50] = naka_rushton(c,data,xo,verbose)
% NAKA_RUSHTON Naka-Rushton fit (for contrast curves)
%
%  [RM,B,EXPLAINED_VARIANCE,C50] = NAKA_RUSHTON(C,DATA,[XO])
%
%  Finds the best fit to the Naka-Rushton function
%    R(c) = Rm*c./(b+c)
%  where C is contrast (0-1), Rm is the maximum response, and b is the
%  half-maximum contrast.
%
%   Optional XO is starting point for fitting.
%
%  [RM,B,N] = NAKA_RUSHTON(C,DATA)
%
%  Finds the best fit to the Naka-Rushton function
%    R(c) = Rm*c.^n ./(b^n + c.^n)
%  where C is contrast (0-1), Rm is the maximum response, and b is the
%  half-maximum contrast.
%
%  C50 is half max contrast based on fit.
%
%
%  References:
%    Naka_Rushton fit was first described in
%    Naka, Rushton, J.Physiol. London 185: 536-555, 1966
%    and used to fit contrast data of cortical cells in
%    Albrecht and Hamilton, J. Neurophys. 48: 217-237, 1982
%
% 200X-2019, Alexander Heimel

if nargin<3
    xo = [];
end
if nargin<4 || isempty(verbose)
    verbose = false;
end

rescaled = false;

if max(c)<=1 && min(c)>0.01
    c = [0.01 c];
    data = [0 data];
elseif min(c)>1 % will rescale
    c = [1 c];
    data = [0 data];
    c = c/100;
    rescaled = true;
end

% clip at maximum to remove supersaturation data
if 0 
    [m,ind] = max(data);
    data(ind:end) = m;
end

if isempty(xo)
    % initial conditions
    xo = [ max(data(:)) 0.4];
    if nargout>2
        xo(3) = 2;  % n (exponent)
    end
end

options = optimset;
options.MaxFunEvals = 10000;
options.MaxIter = 10000;
options.TolFun = 1e-2;
options.TolX = 1e-2;

x = fminsearch(@(x) naka_rushton_err(x,c,data),xo,options);

rm = x(1);
b = x(2);
if length(x)>2
    n = x(3);
else 
    n = 1;
end

if rm<0
    rm = max(abs(data(:)))*10^-8;
    b = 10*max(c);
end

% explained variance explained: https://en.wikipedia.org/wiki/Coefficient_of_determination
fit = rm* (c.^n)./ (b^n+c.^n);
explained_variance = 1 -  sum( (fit - data).^2)/length(data)/std(data)^2;

% compute c50
cn = linspace(0,1,1000);
r = rm*(cn.^n)./ (b^n+cn.^n);
ind = find(r>r(end)/2,1);
c50 = cn(ind);
r_at_c50 = r(ind);
if rescaled
    c50 = c50 * 100;
end

if verbose
    figure; 
    plot(c,data,'+');
    hold on
    cn = (0:0.01:1);
    r = rm* (cn.^n)./ (b^n+cn.^n) ; % without spont
    plot(cn,r);
    plot([c50 c50],[0 r_at_c50],'m');
    xlabel('Contrast');
end

