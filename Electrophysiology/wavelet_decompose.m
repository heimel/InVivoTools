% WAVELET_DECOMPOSE  Decompose a signal upto a certain scale with a given wavelet


function [approximations, details] = wavelet_decompose(signal, scale, wavelet)

sig_length = length(signal);

approximations = zeros(sig_length, scale);
details = zeros(sig_length, scale);

[C,L] = wavedec(signal, scale, wavelet);

for i=1:scale,
  approximations(:,i) = wrcoef('a', C, L, wavelet, i);
  details(:,i) = wrcoef('d', C, L, wavelet, i);
end

