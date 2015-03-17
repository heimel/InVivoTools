function hsquare=heritability_var(means, stds, counts)
%HERITABILITY function for homozygous populations given the means, stds, n
%
%   h=heritability_var(means, stds, counts)
%   just calculated formula myself, no guarantees as to correctness
%
% 2007, Alexander Heimel
%

if nargin==1 
  % values given, but should calculate using stds
  % otherwise just use HERITABILITY
  r_n=means;
  means=nan*zeros(length(r_n),1);
  stds=nan*zeros(length(r_n),1);
  counts=zeros(length(r_n),1);
  for s=1:length(r_n);
    counts(s)=length(r_n{s});
    if counts(s)>0
      means(s)=mean(r_n{s});
      if counts(s)>1
        stds(s)=std(r_n{s});
      end
    end
  end;
end


varmeans=nanvar(means); % variance in means
vars=stds.^2; % variance per strain
ind=find(counts>1); % only use stds where they exist



hsquare=(varmeans - 1/length(ind)*sum( vars(ind)./counts(ind))) / ...
  (varmeans + 1/length(ind)*sum( vars(ind)));

