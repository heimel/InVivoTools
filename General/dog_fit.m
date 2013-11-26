function par = dog_fit(x,y)
%DOG_FIT fits difference of gaussians
%
%    PAR=DOG_FIT(X,Y)
%
%    PAR = [ R0 RE SE RI SI ]
%
%    R0 is baseline response
%    RE is maximum response of positive gaussian
%    SE is standard deviation of positive gaussian
%    RI is maximum response of negative gaussian
%    SI is standard deviation of negative gaussian

search_options=optimset('fminsearch');
%	search_options.TolFun=1e-3;
%	search_options.TolX=1e-3;
%	search_options.MaxFunEvals='300*numberOfVariables';
%	search_options.Display='off';

% starting values
r0=min(y);
re=max(y)-r0;
se=max(x)/2;
ri=re;
si=max(x)/4;
xo=[r0 re se ri si];

% search
options=optimset;
options.MaxFunEvals=4000;
options.MaxIter=4000;
%eval('[par,fval,exitflag] = fminsearch(@(par) dog_error(par,x,y),xo,options);');
[par,fval,exitflag] = fminsearch(@(par) dog_error(par,x,y),xo,options);

