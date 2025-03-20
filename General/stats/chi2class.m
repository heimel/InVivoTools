function [p,chi2,E] = chi2class(D)
% CHI2CLASS - Tests whether observations are distributed equally among classes
%
%    [ P,CHI2,E ] = CHI2CLASS( D )
%
%       D is the number of observations for each class in two or more
%       groups
%
%       e.g. 40 females have blond hair, 10 females have brown hair
%            20 males have blond hair, 20 males have brown hair
%            is intelligence equally shared out over males and females?
%            d = [40 10;20 20]; p = chi2class( d )
%
%       if D is a single column, it tests whether the distribution is
%       equally distributed over all the classes
%
% 200X-2020, Alexander Heimel (?)

if length(D) == numel(D) % i.e. single column
    D = D(:)'; % column vector
    D(2,:) = 100000 * ones(1,length(D));
end

%remove zero rows;
ind = ~any(D,2);
D(ind,:) = [];

% remove zero columns;
ind = ~any(D);
D(:,ind) = [];

[c,r] = size(D);
rsum = sum(D,2); %sum(D')';
csum = sum(D);
T = sum(sum(D));
df = (r-1)*(c-1);
E = repmat(csum,c,1).*repmat(rsum,1,r)/T;
chi2 = sum(sum((D-E).*(D-E)./E));
p = 1-chi2cdf(chi2,df);
