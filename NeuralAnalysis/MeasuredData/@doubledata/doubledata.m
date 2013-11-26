function A = doubledata(intervals, data, t, desc_long, desc_brief)

% DOUBLEDATA
%
% DOUBLEDATA is a measureddata object for processing double data.

md = measureddata(intervals,desc_long,desc_brief);

if ~eqlen([size(data,1) 1],size(t)),
  error(['t must be data_len x 1 (is ' mat2str(size(t)) '), '...
        'data must be t_len x N (is ' mat2str(size(data)) ').']);
end;

data = struct('data',data,'time',t);

A = class(data,'doubledata',md);
