function [data_out,t_out] = data2intervals(data, t, intervals)

%  DATA2INTERVALS - Identify data recorded during specified intervals
%
%   [DATA_OUT,T_OUT] = DATA2INTERVALS(DATA, T, INTERVALS)
%
%  This identifies data observations that were recorded in specified time
%  intervals.  The input observations DATA are expected to be a cell list
%  of M vectors; each vector is assumed to reflect a different element such
%  as a cell.  T is also a cell list of M vectors, and each value in T should
%  reflect the time of an observation in DATA.
%
%  INTERVALS should be a Nx2 matrix of time intervals, such as
%    INTERVALS = [ t11 t12; t21 t22; t31 t32 ; ...];
%
%  DATA_OUT is a cell list of size N x M.  Each element DATA_OUT{i,p}
%    contains all observations in DATA{p} that occured during the 
%    interval [interval(i,1) ... interval(i,2)].
%
%  T_OUT is a cell list of size N x M.  Each element T{i,p} contains the
%    time of all observation in DATA_OUT{i,p}.
%  

data_out = {}; t_out = {};

for i=1:length(data),
	for j=1:size(intervals,1),
		inds = find(t{i}>=intervals(j,1)&t{i}<=intervals(j,2));
		data_out{j,i} = data{i}(inds);
		t_out{j,i} = t{i}(inds);
	end;
end;
