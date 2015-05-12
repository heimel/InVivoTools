function [h2,p]=heritability_shuffle(r,n_shuffles,show_figure)
%HERITABILITY_SHUFFLE calculates heritability and compares with shuffled data
%
%   [H2,P]=HERITABILITY_SHUFFLE( R )
%   [H2,P]=HERITABILITY_SHUFFLE( R, N_SHUFFLES)
%   [H2,P]=HERITABILITY_SHUFFLE( R, N_SHUFFLES, SHOW_FIGURE)
%      R cell list of vectors, each containing trait measurements for a
%      single strain, i.e R={ [2.1 2.2 2.0], [1.9 1.8 1.6], [4.3 2.0 3.1]}
%      N_SHUFFLES is the number of permutations used. Default N_SHUFFLES = 1000 
%      if SHOW_FIGURE == 1, a histogram of the shuffled heritability scores 
%      are shown. Default SHOW_FIGURE = 0 
%
%   H2 is heritability in the narrow sense. Heritability is calculated
%   using HERITABILITY
%   P is p-value   
%
% 2007, Alexander Heimel
%

% fill-in missing arguments
if nargin<3;show_figure=[];end
if nargin<2;n_shuffles=[];end

% set defaults
if isempty(show_figure)
  show_figure=0;
end
if isempty(n_shuffles)
  n_shuffles=1000;
end

%remove NaNs (is also done in HERITABILITY)
for s=1:length(r)
  r{s}=r{s}(find(~isnan(r{s})));
end

% calculate true heritability
h2=heritability(r);

% set fixed seed for random routines, to get reproducable output
% this is not better than variable output, but perhaps less confusing
% to the user. 
rand('state',5489)

% define shuffled heritability vector
h2_shuffled=nan*zeros(1,n_shuffles);
all_values=[ r{:}]; % flatten list of strain values
for shuffle=1:n_shuffles
  % take all values and shuffle them
  [temp,shuffle_ind]=sort(rand(length(all_values),1)); % make a permutation
  all_values=all_values(shuffle_ind);
  % redistribute them without changing the number of values per strain
  i=1;
  for s=1:length(r) % loop over groups
    for m=1:length(r{s}) 
      r{s}(m)=all_values(i);
      i=i+1;
    end
  end
  % values after shuffle
  h2_shuffled(shuffle)=heritability(r);
end
p=length(find(h2_shuffled>h2))/n_shuffles;

if show_figure
  figure
  hist(h2_shuffled,ceil(n_shuffles/10));
  hold on
  ax=axis;
  ax(2)=max( h2*1.1,ax(2));
  axis(ax);
  line( [h2 h2],[ax(3) ax(4)]);
  xlabel('Heritability');
  ylabel('Count');
end


