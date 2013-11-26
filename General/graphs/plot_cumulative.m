function [cf_mean,histbin_centers,h]=plot_cumulative( r,bins,color,showerrors,prefax,remove_nan )
%PLOT_CUMULATIVE plots cumulative histogram of cell list of vectors
%
%  [CF_MEAN,HISTBIN_CENTERS,H]=PLOT_CUMULATIVE(R, BINS)
%
%   R is cell list of vectors
%   BINS works as second argument in HIST
%
% 2007, Alexander Heimel

if nargin<6;remove_nan=[];end
if isempty(remove_nan)
	remove_nan=0;
end
if nargin<5;prefax=[];end
if nargin<4;showerrors=[];end
if isempty(showerrors)
	showerrors=1;
end
if nargin<3
  color='b';
end
if nargin<2;bins=[];end
if isempty(bins)
	bins=10;
end

if ~iscell(r)
  r={r};
end

if remove_nan
	for i=1:length(r)
		r{i}=r{i}(~isnan(r{i}));
	end
end

r_pooled=[r{:}];
[n,histbin_centers]=hist(r_pooled,bins );

for c=1:length(r)
  n_hist(:,c)=hist(r{c},histbin_centers);
  f_hist(:,c)=n_hist(:,c)/length(r{c}); % compute fraction
  r_min(c)=min(r{c});
end
cf=cumsum(f_hist);
cf_mean=mean(cf,2);

hold on;
if ischar(color)
  tempcolor=color;
else
  tempcolor='b';
end

h=plot([mean(r_min); histbin_centers'],[mean(zeros(1,length(r)));cf_mean],tempcolor);
%h=plot([ histbin_centers'],[cf_mean],tempcolor);
if ~ischar(color)
  set(h,'Color',color)
end

if isempty(prefax)
	ax=axis;
	axis( [ax([1 2]) 0 1]);
end

if ~isempty(prefax)
  if length(prefax)==2
    axis( [ prefax 0 1]);
  else
    axis(prefax);
  end
end

ax=axis;
if length(r)>1 && showerrors==1
  cf_sem=sem(cf,2);
  errind=fix(linspace(findclosest(histbin_centers,ax(1)),...
    findclosest(histbin_centers,ax(2)),7));
  errind=errind(2:end-1);
  errorbar(histbin_centers(errind),cf_mean(errind),cf_sem(errind),['.' color]);
end
hold off;
