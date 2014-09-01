function sc_cv_twophotondata( n_cells, n_samples )
%SC_CV_TWOPHOTONDATA calculates the cv of equally distributed orientation preferences 
%  
%
% 2014, Alexander

if nargin<2
    n_samples = [];
end
if isempty(n_samples)
    n_samples = 10000;
end
if nargin<1
    n_cells = [];
end
if isempty(n_cells)
    n_cells = 10;
end
cv = nan(n_samples,1);
for s=1:n_samples
   % prefs = floor(rand(n_cells,1)*4)*45/180*pi;
  prefs = floor(rand(n_cells,1)*180)/180*pi;
    cv(s) = circ_var(prefs*2);
end

figure;
hist(cv)
logmsg([ 'Mean CV = ' num2str(mean(cv)) ', std = ' num2str(std(cv))]);