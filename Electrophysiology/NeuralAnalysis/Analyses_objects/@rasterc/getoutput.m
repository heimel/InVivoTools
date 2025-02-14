function [computations] = getoutput(ra,normalize)

%  Part of the NeuralAnalysis package
%
%  [COMPUTATIONS] = GETOUTPUT(RASTEROBJ,[NORMALIZE])
%
%  Returns a structure containing the computations of the RASTER object
%  RASTEROBJ.  The fields are as follows:
%
%  rast          |   a two dimensional matrix containing x,y pairs where x
%                |     is the time of a spike following the yth trigger
%  bins          |   the bin centers for the PSTH
%  counts        |   the spike count for each bin
%  variation     |   the standard deviation of each bin
%
%  If NORMALIZE is given and is 1, then counts and variation are normalized by
%  the number of triggers and the bin size.
%
%  See also:  RASTER, COMPUTE

computations = ra.computations;
 % this will fail now
if nargin==2&normalize==1,
  f = (length(ra.input.triggers)*ra.RAparams.res);
  for k=1:length(k),
    computations.counts{k} = computations.counts{k}/f;
    computation.variation{k} = computations.variations{k}/f;
  end;
end;
