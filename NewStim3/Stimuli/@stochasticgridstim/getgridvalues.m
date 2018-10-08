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

if isstruct(SGSparams.randState)
    switch SGSparams.randState.Type
        case 'twister'
            rng_twister(SGSparams.randState.Seed);
        otherwise
            logmsg('Random number generator not uniformly implemented for Matlab and Octave');
            rng(SGSparams.randState); 
    end
else
    logmsg('Reverse correlation for these stimuli is Matlab/Octave dependent.');
    try
        rng(SGSparams.randState(1),'v5uniform'); % Changed on 2015-06-23
    catch  % on octave rng is not implemented yet
        rand('state',SGSparams.randState); %#ok<RAND>
    end
end

% zero the output
V = zeros(XY,SGSparams.N);

for i=1:SGSparams.N
    f = rand(XY,1) * ones(1,length(SGSparams.dist));
    [I,J] = find(f>pls & f<=phs);
    [~,is] = sort(I);
    V(:,i) = J(is);
end


