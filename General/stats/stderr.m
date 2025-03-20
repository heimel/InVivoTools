function [se] = stderr(data)
%  STDERR - Standard error of a vector of data
%
%  SE = STDERR(DATA);
%
%  SE = std(DATA)./repmat(sqrt(size(DATA,1)),1,size(DATA,2));

se = std(data)./repmat(sqrt(size(data,1)),1,size(data,2));
