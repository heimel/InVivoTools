function [h2,p]=heritability( r )
%HERITABILITY calculates heritability of feature
%
%   H2=HERITABILITY( R )
%      R cell list of vectors, each containing trait measurements for a
%      single strain, i.e R={ [2.1 2.2 2.0], [1.9 1.8 1.6], [4.3 2.0 3.1]}
%
%    adapted from Heritability_v2.xls of Maarten Loos
%    which is based on paper of Ilses et al. JN 2004, which got it from earlier
%    papers
% 
%  [H2,P]=HERITABILITY( R )
%      calculates p-value using HERITABILITY_SHUFFLE
%
% 2006, Alexander Heimel
%

if nargout==2
  [h2,p]=heritability_shuffle(r,[],0);
  return
end

%remove NaNs
for s=1:length(r)
  r{s}=r{s}(find(~isnan(r{s})));
end

% remove strains where only a single or no sample is known
% (doesn't seem to make a lot of difference)
if 0 % option turned off
  nr={};
  for s=1:length(r)
    if length(find(~isnan(r{s})))>1
      nr{end+1}=r{s};
    end
  end
  r=nr;
end

trait_average=mean( [r{:}]);
n_mice=length( [r{:}]);
n_strains=0;
sumsquaresbetween=0;
sumsquareswithin=0;
sumsquarenumbers=0;
strain_average=[];
for s=1:length(r)
  if ~isempty( r{s})
    n_strains=n_strains+1;
    strain_average(s)=mean( r{s} );
    sumsquarenumbers=sumsquarenumbers+...
      length(r{s})^2;
    sumsquaresbetween=sumsquaresbetween+...
      length( r{s}) *( strain_average(s) - trait_average)^2;
    sumsquareswithin=sumsquareswithin+...
      sum( ( r{s}-strain_average(s)).^2 );
  end
end

k = (n_mice - (sumsquarenumbers/n_mice))/ (n_strains-1);
F= ( sumsquaresbetween/ (n_strains-1))/...
  ( sumsquareswithin/ (n_mice-n_strains));

h2= (F-1)/(F + 2*k -1);


