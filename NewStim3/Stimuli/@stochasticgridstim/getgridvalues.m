function [V] = getgridvalues(SGSstim)
%  stochasticgridstim/getgridvalues
%
%  [V] = GETGRIDVALUES(SGSSTIM)
%
%  Returns the value of each grid point at each frame in an (X*Y)xT matrix,
%  where X and Y are the dimensions of the grid (see GETGRID) and T is the
%  number of frames.

  SGSparams = SGSstim.SGSparams;

  [X,Y] = getgrid(SGSstim);

  XY = X*Y;

  probs = cumsum(SGSparams.dist(1:end))'; probs = probs ./ probs(end);
  phs = ones(XY,1) * probs;
  pls = [ zeros(XY,1) phs(:,1:end-1)];

  rand('state',SGSparams.randState);

  % zero the output
  V = zeros(XY,SGSparams.N);

  for i=1:SGSparams.N,
	f = rand(XY,1) * ones(1,length(SGSparams.dist));
	[I,J] = find(f>pls & f<=phs);
	[y,is] = sort(I);
        V(:,i) = J(is);
  end;
