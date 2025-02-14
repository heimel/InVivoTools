%function [m,c] = sd_calcCov(ex)

dt = 3.1807627469e-05;
degree = size(ex,2);
smooth = floor(160/(dt*1000));
%skip = max(1,floor(160/(dt*1000)));
skip = max(1,floor((0.160/dt*1000));
thp = 0.999999;
th = chi2inv(thp,degree);
merge = floor(0.160/(dt*1000));
win = ceil(800/(1000*dt))+ceil(4000/(1000*dt))+1;

nmean = mean(ex);
e = ex - nmean(ones(size(ex,1),1),:); % remove mean
nstd = std(e);
e = e./(nstd(ones(size(ex,1),1),:));  % normalize
e = sum(e'.^2); % energy

%e = movingavr(e,smooth);
est = peakPos2(e,th,skip,merge);
length(est),
indx = zeros(size(ex,1),1);
for i=1:length(est)
        st = max(1, est(i)-win);
        ed = min(size(ex,1), est(i)+win);
        indx(st:ed) = nan;
end

indx = find(~isnan(indx));

m = mean(ex(indx,:));
c = cov(ex(indx,:));

