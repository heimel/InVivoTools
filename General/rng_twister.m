function state = rng_twister(seed)
%RNG_TWISTER sets octave and matlab random number seed to agree
%
%  STATE = RNG_TWISTER(SEED)
%
%  from https://stackoverflow.com/questions/13735096/python-vs-octave-random-generator
%
% Adapted by Alexander Heimel, 2018
%

if nargin<1
    seed = uint32(now);
end

if ~exist ('OCTAVE_VERSION', 'builtin')  % Matlab
    state = rng(seed,'twister');
else % Octave
    staten = uint32(zeros(625,1));
    staten(1) = uint32(seed);
    for i=1:623
        tmp = uint64(1812433253)*uint64(bitxor(staten(i),bitshift(staten(i),-30)))+i;
        staten(i+1) = uint32(bitand(tmp,uint64(intmax('uint32'))));
    end
    staten(625) = 1;
    rand('state',staten); %#ok<RAND>
    state.Type = 'twister';
    state.Seed = seed;
    state.State = staten;
end



