function [ev, ev_adj] = explained_variance( data, fit, n_fitpar)
%EXPLAINED_VARIANCE computes explained variance (R2) and adjusted R2
%
%  [EV, EV_ADJ] = EXPLAINED_VARIANCE(DATA, FIT, N_FITPAR)
%
% 2020, Alexander Heimel

ev = 1 -  sum( (fit(:) - data(:)).^2)/numel(data)/std(data(:))^2;

if nargin>2 && ~isempty(n_fitpar)
    ev_adj = 1 - (1-ev)*(numel(data)-1)/(numel(data)-n_fitpar-1);
end
