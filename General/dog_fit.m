function par = dog_fit(x,y,options,xo)
%DOG_FIT fits difference of gaussians
%
%    PAR = DOG_FIT(X,Y,[OPTIONS],[XO])
%
%    PAR = [ R0 RE SE RI SI ]
%    OPTIONS can be empty (default) or 'zerobaseline', in which case it 
%       fits with R0 set to 0, and thus for x->infinity, y->0
%    XO is an optional PAR to start the fit. This can speed up the fitting
%       or avoid wrong fits
%
%    R0 is baseline response
%    RE is maximum response of positive gaussian
%    SE is standard deviation of positive gaussian
%    RI is maximum response of negative gaussian
%    SI is standard deviation of negative gaussian
%
%  The found parameters can be used as:
%     r = dog(par,x)
%
%  See DOG and DOG_ERROR functions for implementation of the difference 
%  of gaussians and the nudges used for fitting.
%
%
% 200X-2019, Alexander Heimel

if nargin<3 || isempty(options)
    options = '';
end

% starting values
if nargin<4 || isempty(xo)
    [~,ind] = max(x);
    r0 = y(ind); %min(y);
    re = max(y)-r0;
    se = max(x)/2;
    ri = re+r0;
    si = min(x)/2;
    xo = [r0 re se ri si];
end

search_options = optimset('fminsearch');
search_options.TolFun = 1e-4;
search_options.TolX = 1e-4;
search_options.MaxFunEvals = 6*300;
search_options.Display = 'off';

switch lower(options)
    case 'zerobaseline'       
        xo(1) = 0;
        par = fminsearch(@(par) dog_error([0 par(2:5)],x,y),xo,search_options);
        par(1) = 0;
    otherwise
        par = fminsearch(@(par) dog_error(par,x,y),xo,search_options);
end

if par(2)<0 || par(4)<0 || par(3) > 10 * max(x)  
    logmsg(['Failed to fit difference of gaussians. par = ' mat2str(par)] );
    par = NaN(size(par));
end




